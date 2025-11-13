import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avaliacao_instituicao/tela_quiz_especifico.dart';
import 'package:avaliacao_instituicao/tela_quiz_professor_aluno.dart';

class TelaSelecaoQuiz extends StatelessWidget {
  const TelaSelecaoQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
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
                    'Escolha um Quiz',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
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
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Quizzes do Sistema',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildQuizCard(
                  context,
                  'Banco de Dados',
                  'Teste seus conhecimentos sobre SQL, NoSQL e modelagem',
                  Icons.storage_rounded,
                  Colors.blue,
                  'banco_dados',
                  false,
                ),
                const SizedBox(height: 16),
                _buildQuizCard(
                  context,
                  'Flutter',
                  'Avalie seu domínio em desenvolvimento Flutter',
                  Icons.phone_android_rounded,
                  Colors.cyan,
                  'flutter',
                  false,
                ),
                const SizedBox(height: 16),
                _buildQuizCard(
                  context,
                  'Programação Web',
                  'HTML, CSS, JavaScript e frameworks modernos',
                  Icons.web_rounded,
                  Colors.orange,
                  'web',
                  false,
                ),
                const SizedBox(height: 16),
                _buildQuizCard(
                  context,
                  'Git & Controle de Versão',
                  'Comandos Git, branches e boas práticas',
                  Icons.code_rounded,
                  Colors.red,
                  'git',
                  false,
                ),
                const SizedBox(height: 16),
                _buildQuizCard(
                  context,
                  'Algoritmos e Estruturas',
                  'Lógica de programação e estruturas de dados',
                  Icons.functions_rounded,
                  Colors.purple,
                  'algoritmos',
                  false,
                ),
                const SizedBox(height: 32),
                
                // Quizzes dos Professores
                const Text(
                  'Quizzes dos Professores',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('quizzes_professores')
                      .where('ativo', isEqualTo: true)
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
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Nenhum quiz disponível no momento',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: quizzes.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final titulo = data['titulo']?.toString() ?? 'Quiz sem título';
                        final iconeCode = data['icone']?.toString() ?? 'science';
                        final perguntas = data['perguntas'] as List<dynamic>? ?? [];
                        
                        final iconMap = {
                          'science': Icons.science,
                          'calculate': Icons.calculate,
                          'language': Icons.language,
                          'public': Icons.public,
                          'sports_soccer': Icons.sports_soccer,
                          'palette': Icons.palette,
                          'psychology': Icons.psychology,
                          'biotech': Icons.biotech,
                          'computer': Icons.computer,
                          'music_note': Icons.music_note,
                        };

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildQuizCard(
                            context,
                            titulo,
                            '${perguntas.length} perguntas',
                            iconMap[iconeCode] ?? Icons.quiz,
                            Colors.green,
                            doc.id,
                            true,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(
    BuildContext context,
    String titulo,
    String descricao,
    IconData icone,
    Color cor,
    String quizId,
    bool isProfessor,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          if (isProfessor) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TelaQuizProfessorAluno(
                  quizId: quizId,
                  titulo: titulo,
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TelaQuizEspecifico(
                  quizId: quizId,
                  titulo: titulo,
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cor.withOpacity(0.1),
                cor.withOpacity(0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icone, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descricao,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: cor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
