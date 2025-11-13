import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avaliacao_instituicao/tela_relatorio_admin.dart';
import 'package:avaliacao_instituicao/tela_gerenciar_usuarios.dart';

class TelaDashboardAdmin extends StatefulWidget {
  const TelaDashboardAdmin({super.key});

  @override
  State<TelaDashboardAdmin> createState() => _TelaDashboardAdminState();
}

class _TelaDashboardAdminState extends State<TelaDashboardAdmin> {
  int _totalUsuarios = 0;
  int _totalAlunos = 0;
  int _totalProfessores = 0;
  int _totalAvaliacoes = 0;
  int _totalQuizzes = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Contar usuários
      final usuariosSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .get();
      
      _totalUsuarios = usuariosSnapshot.docs.length;
      _totalAlunos = usuariosSnapshot.docs.where((d) => d.data()['tipoUsuario'] == 'aluno').length;
      _totalProfessores = usuariosSnapshot.docs.where((d) => d.data()['tipoUsuario'] == 'professor').length;
      
      // Contar avaliações
      final avaliacoesSnapshot = await FirebaseFirestore.instance
          .collection('avaliacoes')
          .get();
      
      // Contar quizzes respondidos
      final quizzesSnapshot = await FirebaseFirestore.instance
          .collection('quiz_resultados')
          .get();

      setState(() {
        _totalAvaliacoes = avaliacoesSnapshot.docs.length;
        _totalQuizzes = quizzesSnapshot.docs.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header roxo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
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
            child: const Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Text(
                  'Dashboard Admin',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Conteúdo
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _carregarDados,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Visão Geral',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Cards de estatísticas
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Alunos',
                                  _totalAlunos.toString(),
                                  Icons.school,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'Professores',
                                  _totalProfessores.toString(),
                                  Icons.psychology,
                                  Colors.purple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Avaliações',
                                  _totalAvaliacoes.toString(),
                                  Icons.assignment,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'Quizzes',
                                  _totalQuizzes.toString(),
                                  Icons.quiz,
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Ações rápidas
                          const Text(
                            'Ações Rápidas',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildActionButton(
                            'Ver Avaliações Recebidas',
                            Icons.assignment_outlined,
                            () {
                              Navigator.pushNamed(context, '/avaliacoes-admin');
                            },
                          ),
                          const SizedBox(height: 12),
                          
                          _buildActionButton(
                            'Gerenciar Alunos',
                            Icons.school,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TelaGerenciarUsuarios(filtroTipo: 'aluno'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          
                          _buildActionButton(
                            'Gerenciar Professores',
                            Icons.person_pin,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TelaGerenciarUsuarios(filtroTipo: 'professor'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          
                          _buildActionButton(
                            'Relatório Completo',
                            Icons.analytics,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TelaRelatorioAdmin(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        elevation: 0,
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF403AFF)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
