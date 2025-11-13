import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TelaRelatorioAdmin extends StatefulWidget {
  const TelaRelatorioAdmin({super.key});

  @override
  State<TelaRelatorioAdmin> createState() => _TelaRelatorioAdminState();
}

class _TelaRelatorioAdminState extends State<TelaRelatorioAdmin> {
  bool _isLoading = true;
  
  // Estatísticas gerais
  int _totalUsuarios = 0;
  int _totalAlunos = 0;
  int _totalProfessores = 0;
  int _totalAdmins = 0;
  
  // Estatísticas de quizzes
  int _totalQuizzesProfessores = 0;
  int _totalRespostasQuizzes = 0;
  int _totalRespostasQuizzesProfessores = 0;
  double _mediaAcertos = 0;
  double _mediaAcertosProfessores = 0;
  
  // Estatísticas de Pokémons
  int _totalPokemons = 0;
  int _pontuacoesPerfeitas = 0;
  
  // Estatísticas de avaliações
  int _totalAvaliacoes = 0;
  
  @override
  void initState() {
    super.initState();
    _carregarEstatisticas();
  }

  Future<void> _carregarEstatisticas() async {
    setState(() => _isLoading = true);

    try {
      // Usuários
      final usuarios = await FirebaseFirestore.instance.collection('usuarios').get();
      _totalUsuarios = usuarios.docs.length;
      _totalAlunos = usuarios.docs.where((d) => d.data()['tipoUsuario'] == 'aluno').length;
      _totalProfessores = usuarios.docs.where((d) => d.data()['tipoUsuario'] == 'professor').length;
      _totalAdmins = usuarios.docs.where((d) => d.data()['tipoUsuario'] == 'admin').length;

      // Quizzes de professores
      final quizzesProfessores = await FirebaseFirestore.instance
          .collection('quizzes_professores')
          .get();
      _totalQuizzesProfessores = quizzesProfessores.docs.length;

      // Respostas de quizzes de professores
      final resultadosQuizzesProfessores = await FirebaseFirestore.instance
          .collection('resultados_quiz_professores')
          .get();
      
      _totalRespostasQuizzesProfessores = resultadosQuizzesProfessores.docs.length;
      
      int totalAcertosProfessores = 0;
      int totalPerguntasProfessores = 0;
      
      for (var doc in resultadosQuizzesProfessores.docs) {
        final data = doc.data();
        totalAcertosProfessores += (data['acertos'] as int? ?? 0);
        totalPerguntasProfessores += (data['total'] as int? ?? 10);
      }

      if (totalPerguntasProfessores > 0) {
        _mediaAcertosProfessores = (totalAcertosProfessores / totalPerguntasProfessores) * 100;
      }

      // Respostas de quizzes do sistema
      final resultadosQuizzes = await FirebaseFirestore.instance
          .collection('resultados_quiz')
          .get();
      
      int totalAcertos = 0;
      int totalPerguntas = 0;
      
      for (var doc in resultadosQuizzes.docs) {
        final tentativas = await doc.reference.collection('tentativas').get();
        _totalRespostasQuizzes += tentativas.docs.length;
        
        for (var tentativa in tentativas.docs) {
          final data = tentativa.data();
          totalAcertos += (data['acertos'] as int? ?? 0);
          totalPerguntas += (data['total_perguntas'] as int? ?? 10);
        }
      }

      if (totalPerguntas > 0) {
        _mediaAcertos = (totalAcertos / totalPerguntas) * 100;
      }

      // Pokémons
      final pokemons = await FirebaseFirestore.instance
          .collection('quiz_resultados')
          .get();
      _totalPokemons = pokemons.docs.length;
      _pontuacoesPerfeitas = pokemons.docs
          .where((d) => d.data()['pontuacao_perfeita'] == true)
          .length;

      // Avaliações
      final avaliacoes = await FirebaseFirestore.instance
          .collection('avaliacoes')
          .get();
      _totalAvaliacoes = avaliacoes.docs.length;

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar estatísticas: $e')),
        );
      }
    }
  }

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
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Relatório Completo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _carregarEstatisticas,
                ),
              ],
            ),
          ),

          // Conteúdo
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Data do relatório
                        Center(
                          child: Text(
                            'Gerado em: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Usuários
                        _buildSectionTitle('👥 Usuários'),
                        _buildStatCard('Total de Usuários', _totalUsuarios.toString(), Colors.blue),
                        _buildStatCard('Alunos', _totalAlunos.toString(), Colors.green),
                        _buildStatCard('Professores', _totalProfessores.toString(), Colors.purple),
                        _buildStatCard('Administradores', _totalAdmins.toString(), Colors.orange),
                        
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),

                        // Quizzes
                        _buildSectionTitle('📝 Quizzes do Sistema'),
                        _buildStatCard('Total de Respostas', _totalRespostasQuizzes.toString(), Colors.teal),
                        _buildStatCard(
                          'Média de Acertos',
                          '${_mediaAcertos.toStringAsFixed(1)}%',
                          _mediaAcertos >= 70 ? Colors.green : _mediaAcertos >= 50 ? Colors.orange : Colors.red,
                        ),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),

                        // Quizzes dos Professores
                        _buildSectionTitle('🎯 Quizzes dos Professores'),
                        _buildStatCard('Quizzes Criados', _totalQuizzesProfessores.toString(), Colors.indigo),
                        _buildStatCard('Respostas de Alunos', _totalRespostasQuizzesProfessores.toString(), Colors.blue),
                        _buildStatCard(
                          'Média de Acertos',
                          '${_mediaAcertosProfessores.toStringAsFixed(1)}%',
                          _mediaAcertosProfessores >= 70 ? Colors.green : _mediaAcertosProfessores >= 50 ? Colors.orange : Colors.red,
                        ),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),

                        // Pokémons
                        _buildSectionTitle('🎮 Pokémons'),
                        _buildStatCard('Pokémons Conquistados', _totalPokemons.toString(), Colors.amber),
                        _buildStatCard('Pontuações Perfeitas (10/10)', _pontuacoesPerfeitas.toString(), Colors.yellow[800]!),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),

                        // Avaliações Institucionais
                        _buildSectionTitle('📋 Formulários de Avaliação'),
                        _buildStatCard('Total de Avaliações', _totalAvaliacoes.toString(), Colors.cyan),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),

                        // Resumo
                        _buildSectionTitle('📊 Resumo Geral'),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF403AFF), Color(0xFF000000)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _buildSummaryRow('Engajamento Total', '${_totalRespostasQuizzes + _totalRespostasQuizzesProfessores + _totalAvaliacoes} ações'),
                              _buildSummaryRow('Quizzes Respondidos', '${_totalRespostasQuizzes + _totalRespostasQuizzesProfessores} respostas'),
                              _buildSummaryRow('Pontuações Perfeitas', '$_pontuacoesPerfeitas (${_totalRespostasQuizzes > 0 ? ((_pontuacoesPerfeitas / _totalRespostasQuizzes) * 100).toStringAsFixed(1) : "0"}%)'),
                              _buildSummaryRow('Média Geral de Acertos', '${((_mediaAcertos + _mediaAcertosProfessores) / 2).toStringAsFixed(1)}%'),
                              _buildSummaryRow('Atividade por Usuário', _totalUsuarios > 0 ? '${((_totalRespostasQuizzes + _totalRespostasQuizzesProfessores + _totalAvaliacoes) / _totalUsuarios).toStringAsFixed(1)} ações' : '0'),
                            ],
                          ),
                        ),


                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        title: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
