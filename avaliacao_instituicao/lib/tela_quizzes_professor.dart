import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:avaliacao_instituicao/tela_editar_quiz_professor.dart';
import 'package:avaliacao_instituicao/tela_resultados_professor.dart';

class TelaQuizzesProfessor extends StatefulWidget {
  const TelaQuizzesProfessor({super.key});

  @override
  State<TelaQuizzesProfessor> createState() => _TelaQuizzesProfessorState();
}

class _TelaQuizzesProfessorState extends State<TelaQuizzesProfessor> {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _excluirQuiz(String quizId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Quiz'),
        content: const Text('Tem certeza que deseja excluir este quiz? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await FirebaseFirestore.instance
            .collection('quizzes_professores')
            .doc(quizId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Quiz excluído com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erro ao excluir: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _alternarAtivo(String quizId, bool ativoAtual) async {
    try {
      await FirebaseFirestore.instance
          .collection('quizzes_professores')
          .doc(quizId)
          .update({'ativo': !ativoAtual});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!ativoAtual
                ? '✅ Quiz ativado!'
                : '⚠️ Quiz desativado!'),
            backgroundColor: !ativoAtual ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Erro: Usuário não autenticado')),
      );
    }

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
                    'Meus Quizzes',
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

          // Lista de Quizzes
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('quizzes_professores')
                  .where('professorId', isEqualTo: userId)
                  .orderBy('dataCriacao', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final quizzes = snapshot.data?.docs ?? [];

                if (quizzes.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Você ainda não criou nenhum quiz.\n\nClique em "Criar Quiz" na tela inicial para começar!',
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
                    
                    // Suportar ícone como int ou String (compatibilidade)
                    final iconeData = data['icone'];
                    int iconeCode;
                    if (iconeData is int) {
                      iconeCode = iconeData;
                    } else if (iconeData is String) {
                      // Converter String para codePoint (compatibilidade com formato antigo)
                      iconeCode = Icons.quiz.codePoint;
                    } else {
                      iconeCode = Icons.quiz.codePoint;
                    }
                    
                    final ativo = data['ativo'] ?? true;
                    final perguntas = data['perguntas'] as List? ?? [];
                    final dataCriacao = data['dataCriacao'] as Timestamp?;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: ativo
                                ? const Color(0xFF403AFF).withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            IconData(iconeCode, fontFamily: 'MaterialIcons'),
                            color: ativo ? const Color(0xFF403AFF) : Colors.grey,
                            size: 28,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                titulo,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: ativo ? null : TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ativo ? Colors.green : Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                ativo ? 'ATIVO' : 'INATIVO',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text('${perguntas.length} perguntas'),
                            if (dataCriacao != null)
                              Text(
                                'Criado em: ${dataCriacao.toDate().toString().substring(0, 16)}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  Icon(ativo ? Icons.visibility_off : Icons.visibility),
                                  const SizedBox(width: 8),
                                  Text(ativo ? 'Desativar' : 'Ativar'),
                                ],
                              ),
                              onTap: () => _alternarAtivo(quizId, ativo),
                            ),
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text('Editar Quiz'),
                                ],
                              ),
                              onTap: () {
                                Future.delayed(Duration.zero, () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TelaEditarQuizProfessor(quizId: quizId),
                                    ),
                                  );
                                });
                              },
                            ),
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.bar_chart, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Ver Resultados'),
                                ],
                              ),
                              onTap: () {
                                Future.delayed(Duration.zero, () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TelaResultadosProfessor(
                                        quizId: quizId,
                                        tituloQuiz: titulo,
                                      ),
                                    ),
                                  );
                                });
                              },
                            ),
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Excluir', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                              onTap: () => _excluirQuiz(quizId),
                            ),
                          ],
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
