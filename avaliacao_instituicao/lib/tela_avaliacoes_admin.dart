import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TelaAvaliacoesAdmin extends StatefulWidget {
  const TelaAvaliacoesAdmin({super.key});

  @override
  State<TelaAvaliacoesAdmin> createState() => _TelaAvaliacoesAdminState();
}

class _TelaAvaliacoesAdminState extends State<TelaAvaliacoesAdmin> {
  String? _cursoFiltro;
  String? _generoFiltro;
  
  final List<String> _cursos = [
    'Todos',
    'Sistemas de Informação', 
    'Engenharia Agronômica', 
    'Medicina Veterinária', 
    'Zootecnia', 
    'Administração'
  ];
  
  final List<String> _generos = [
    'Todos',
    'Masculino',
    'Feminino',
    'Não-binário',
    'Prefiro não informar'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
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
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Avaliações Recebidas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _cursoFiltro,
                        decoration: const InputDecoration(
                          labelText: 'Curso',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          isDense: true,
                        ),
                        isExpanded: true,
                        items: _cursos.map((curso) {
                          return DropdownMenuItem(
                            value: curso == 'Todos' ? null : curso,
                            child: Text(
                              curso,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _cursoFiltro = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _generoFiltro,
                        decoration: const InputDecoration(
                          labelText: 'Gênero',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          isDense: true,
                        ),
                        isExpanded: true,
                        items: _generos.map((genero) {
                          return DropdownMenuItem(
                            value: genero == 'Todos' ? null : genero,
                            child: Text(
                              genero,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _generoFiltro = value);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de avaliações
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getAvaliacoesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma avaliação encontrada'),
                  );
                }

                final avaliacoes = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: avaliacoes.length,
                  itemBuilder: (context, index) {
                    final avaliacao = avaliacoes[index].data() as Map<String, dynamic>;
                    return _buildAvaliacaoCard(avaliacao);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getAvaliacoesStream() {
    Query query = FirebaseFirestore.instance
        .collection('avaliacoes')
        .orderBy('data_envio', descending: true);

    if (_cursoFiltro != null) {
      query = query.where('curso', isEqualTo: _cursoFiltro);
    }

    if (_generoFiltro != null) {
      query = query.where('genero', isEqualTo: _generoFiltro);
    }

    return query.snapshots();
  }

  Widget _buildAvaliacaoCard(Map<String, dynamic> avaliacao) {
    final data = avaliacao['data_envio'] as Timestamp?;
    final dataFormatada = data != null 
        ? DateFormat('dd/MM/yyyy HH:mm').format(data.toDate())
        : 'Data não disponível';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  avaliacao['genero'] == 'Masculino' 
                      ? Icons.male 
                      : avaliacao['genero'] == 'Feminino'
                          ? Icons.female
                          : Icons.person,
                  color: const Color(0xFF403AFF),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        avaliacao['curso'] ?? 'Curso não informado',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        avaliacao['genero'] ?? 'Gênero não informado',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getNotaColor((avaliacao['nota_infra'] ?? 0).toDouble()),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(avaliacao['nota_infra'] ?? 0).toDouble().toStringAsFixed(1)} ⭐',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Feedback:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              avaliacao['feedback'] ?? 'Sem feedback',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              dataFormatada,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getNotaColor(double nota) {
    if (nota >= 4.5) return Colors.green;
    if (nota >= 3.5) return Colors.orange;
    return Colors.red;
  }
}
