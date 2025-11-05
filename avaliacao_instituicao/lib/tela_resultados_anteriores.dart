// tela_resultados_anteriores.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaResultadosAnteriores extends StatefulWidget {
  const TelaResultadosAnteriores({super.key});

  @override
  State<TelaResultadosAnteriores> createState() => _TelaResultadosAnterioresState();
}

class _TelaResultadosAnterioresState extends State<TelaResultadosAnteriores> {
  late final Stream<QuerySnapshot> _resultadosStream;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    if (userId != null) {
      _resultadosStream = FirebaseFirestore.instance
          .collection('resultados_quiz')
          .doc(userId)
          .collection('tentativas')
          .orderBy('data_envio', descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Meus Resultados')),
        body: const Center(child: Text('Erro: Usuário não encontrado.')),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Header roxo com título
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF403AFF),
                  Color(0xFF000000),
                ],
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
                    'Meus Resultados\ndo Quiz',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          // Corpo com lista de resultados
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _resultadosStream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erro ao carregar resultados.'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'Você ainda não respondeu nenhum quiz.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    
                    // Formatando a data
                    String dataFormatada = (data['data_envio'] as Timestamp)
                                             .toDate()
                                             .toLocal()
                                             .toString()
                                             .substring(0, 16);

                    int acertos = data['acertos'] ?? 0;
                    int total = data['total_perguntas'] ?? 10;
                    double porcentagem = (acertos / total) * 100;

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF403AFF),
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
                          'Pontuação: $acertos de $total',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text('Porcentagem: ${porcentagem.toStringAsFixed(1)}%'),
                            const SizedBox(height: 4),
                            Text(
                              'Respondido em: $dataFormatada',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
