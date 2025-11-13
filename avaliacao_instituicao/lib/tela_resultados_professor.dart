import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaResultadosProfessor extends StatefulWidget {
  final String quizId;
  final String tituloQuiz;

  const TelaResultadosProfessor({
    super.key,
    required this.quizId,
    required this.tituloQuiz,
  });

  @override
  State<TelaResultadosProfessor> createState() => _TelaResultadosProfessorState();
}

class _TelaResultadosProfessorState extends State<TelaResultadosProfessor> {
  String _ordenacao = 'data_recente';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF403AFF), Color(0xFF000000)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Resultados\n${widget.tituloQuiz}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Estatísticas
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('resultados_quiz_professores')
                      .where('quizId', isEqualTo: widget.quizId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final resultados = snapshot.data?.docs ?? [];
                    final totalAlunos = resultados.length;
                    
                    if (totalAlunos == 0) {
                      return const Text(
                        'Nenhuma resposta ainda',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      );
                    }

                    int somaAcertos = 0;
                    int somaTotal = 0;
                    
                    for (var doc in resultados) {
                      final data = doc.data() as Map<String, dynamic>;
                      somaAcertos += (data['acertos'] as int? ?? 0);
                      somaTotal += (data['total'] as int? ?? 10);
                    }

                    final mediaGeral = somaTotal > 0 
                        ? (somaAcertos / somaTotal) * 100 
                        : 0.0;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                '$totalAlunos',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Alunos',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          Column(
                            children: [
                              Text(
                                '${mediaGeral.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Média',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Filtro de ordenação
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: DropdownButtonFormField<String>(
              value: _ordenacao,
              decoration: const InputDecoration(
                labelText: 'Ordenar por',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'data_recente', child: Text('Data: Mais Recente')),
                DropdownMenuItem(value: 'maior_nota', child: Text('Maior Nota')),
                DropdownMenuItem(value: 'menor_nota', child: Text('Menor Nota')),
              ],
              onChanged: (valor) {
                setState(() => _ordenacao = valor!);
              },
            ),
          ),

          // Lista de resultados
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('resultados_quiz_professores')
                  .where('quizId', isEqualTo: widget.quizId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                var resultados = snapshot.data?.docs ?? [];

                if (resultados.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Nenhum aluno respondeu este quiz ainda.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                // Ordenar
                resultados.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;

                  switch (_ordenacao) {
                    case 'maior_nota':
                      return (dataB['acertos'] as int).compareTo(dataA['acertos'] as int);
                    case 'menor_nota':
                      return (dataA['acertos'] as int).compareTo(dataB['acertos'] as int);
                    case 'data_recente':
                    default:
                      final timestampA = dataA['data_envio'] as Timestamp?;
                      final timestampB = dataB['data_envio'] as Timestamp?;
                      if (timestampA == null || timestampB == null) return 0;
                      return timestampB.compareTo(timestampA);
                  }
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: resultados.length,
                  itemBuilder: (context, index) {
                    final doc = resultados[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final alunoNome = data['alunoNome'] ?? 'Anônimo';
                    final alunoEmail = data['alunoEmail'] ?? '';
                    final acertos = data['acertos'] ?? 0;
                    final total = data['total'] ?? 10;
                    final porcentagem = (acertos / total) * 100;
                    final dataEnvio = data['data_envio'] as Timestamp?;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: porcentagem >= 70
                              ? Colors.green
                              : porcentagem >= 50
                                  ? Colors.orange
                                  : Colors.red,
                          radius: 30,
                          child: Text(
                            '$acertos',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        title: Text(
                          alunoNome,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alunoEmail),
                            const SizedBox(height: 4),
                            Text(
                              'Pontuação: $acertos/$total (${porcentagem.toStringAsFixed(1)}%)',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (dataEnvio != null)
                              Text(
                                'Respondido em: ${dataEnvio.toDate().toString().substring(0, 16)}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: porcentagem >= 70
                                ? Colors.green
                                : porcentagem >= 50
                                    ? Colors.orange
                                    : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${porcentagem.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
