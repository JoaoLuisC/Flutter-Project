import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:avaliacao_instituicao/tela_resultados_professor.dart';

class TelaSelecaoResultadosProfessor extends StatelessWidget {
  const TelaSelecaoResultadosProfessor({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Selecione um Quiz\npara Ver Resultados',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
          ),

          // Lista de quizzes
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('quizzes_professores')
                  .where('professorId', isEqualTo: user?.uid)
                  .orderBy('dataCriacao', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar quizzes: ${snapshot.error}'),
                  );
                }

                final quizzes = snapshot.data?.docs ?? [];

                if (quizzes.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Você ainda não criou nenhum quiz.\nCrie um quiz primeiro para ver os resultados!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final doc = quizzes[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final quizId = doc.id;
                    final titulo = data['titulo'] ?? 'Quiz sem título';
                    
                    // Suportar ícone como int ou String
                    final iconeData = data['icone'];
                    int iconeCode;
                    if (iconeData is int) {
                      iconeCode = iconeData;
                    } else if (iconeData is String) {
                      iconeCode = Icons.quiz.codePoint;
                    } else {
                      iconeCode = Icons.quiz.codePoint;
                    }
                    
                    final perguntas = data['perguntas'] as List? ?? [];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF403AFF).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            IconData(iconeCode, fontFamily: 'MaterialIcons'),
                            color: const Color(0xFF403AFF),
                            size: 28,
                          ),
                        ),
                        title: Text(
                          titulo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text('${perguntas.length} perguntas'),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF403AFF),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaResultadosProfessor(
                                quizId: quizId,
                                tituloQuiz: titulo,
                              ),
                            ),
                          );
                        },
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
