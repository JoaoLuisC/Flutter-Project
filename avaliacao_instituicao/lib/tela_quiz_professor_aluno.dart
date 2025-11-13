import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:avaliacao_instituicao/tela_resultado_pokemon.dart';

class TelaQuizProfessorAluno extends StatefulWidget {
  final String quizId;
  final String titulo;

  const TelaQuizProfessorAluno({
    super.key,
    required this.quizId,
    required this.titulo,
  });

  @override
  State<TelaQuizProfessorAluno> createState() => _TelaQuizProfessorAlunoState();
}

class _TelaQuizProfessorAlunoState extends State<TelaQuizProfessorAluno> {
  int _currentQuestionIndex = 0;
  List<int?> _respostas = [];
  List<Map<String, dynamic>> _perguntas = [];
  bool _isLoading = true;
  bool _quizFinalizado = false;

  @override
  void initState() {
    super.initState();
    _carregarQuiz();
  }

  Future<void> _carregarQuiz() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('quizzes_professores')
          .doc(widget.quizId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final perguntasData = data['perguntas'] as List<dynamic>;
        
        setState(() {
          _perguntas = perguntasData.map((p) => Map<String, dynamic>.from(p)).toList();
          _respostas = List<int?>.filled(_perguntas.length, null);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar quiz: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _responder(int opcaoIndex) {
    setState(() {
      _respostas[_currentQuestionIndex] = opcaoIndex;
    });
  }

  void _proximaPergunta() {
    if (_respostas[_currentQuestionIndex] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma resposta!')),
      );
      return;
    }

    if (_currentQuestionIndex < _perguntas.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _finalizarQuiz();
    }
  }

  void _voltarPergunta() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _finalizarQuiz() async {
    // Verificar se todas as perguntas foram respondidas
    if (_respostas.any((resposta) => resposta == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, responda todas as perguntas!')),
      );
      return;
    }

    setState(() => _quizFinalizado = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Calcular acertos
    int acertos = 0;
    for (int i = 0; i < _perguntas.length; i++) {
      // Suporta tanto 'respostaCorreta' quanto 'respostaCorretaIndex'
      final respostaCorretaIndex = _perguntas[i]['respostaCorretaIndex'] ?? _perguntas[i]['respostaCorreta'];
      if (_respostas[i] == respostaCorretaIndex) {
        acertos++;
      }
    }

    final pontuacaoPerfeita = acertos == _perguntas.length && _perguntas.length == 10;

    try {
      // Buscar dados do usuário
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      
      final userData = userDoc.data();
      final alunoNome = userData?['nome'] ?? 'Aluno';
      final alunoEmail = userData?['email'] ?? user.email ?? '';

      // Buscar dados do professor que criou o quiz
      final quizDoc = await FirebaseFirestore.instance
          .collection('quizzes_professores')
          .doc(widget.quizId)
          .get();
      
      final quizData = quizDoc.data();
      final professorId = quizData?['professorId'] ?? '';

      // Salvar resultado na coleção de resultados dos professores
      await FirebaseFirestore.instance.collection('resultados_quiz_professores').add({
        'quizId': widget.quizId,
        'tituloQuiz': widget.titulo,
        'alunoId': user.uid,
        'alunoNome': alunoNome,
        'alunoEmail': alunoEmail,
        'professorId': professorId,
        'acertos': acertos,
        'total': _perguntas.length,
        'timestamp': Timestamp.now(),
      });

      // Salvar também na coleção do aluno (para aparecer em "Meus Resultados")
      await FirebaseFirestore.instance
          .collection('resultados_quiz')
          .doc(user.uid)
          .collection('tentativas')
          .add({
        'quiz_tipo': 'professor_${widget.quizId}',
        'quiz_titulo': widget.titulo,
        'acertos': acertos,
        'total_perguntas': _perguntas.length,
        'pontuacao_perfeita': pontuacaoPerfeita,
        'data_envio': Timestamp.now(),
        'userId': user.uid,
      });

      if (mounted) {
        // Navegar para tela de resultado com Pokémon
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TelaResultadoPokemon(
              pontuacao: acertos,
              totalPerguntas: _perguntas.length,
              pontuacaoPerfeita: pontuacaoPerfeita,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar resultado: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.titulo),
          backgroundColor: const Color(0xFF403AFF),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final perguntaAtual = _perguntas[_currentQuestionIndex];
    final opcoes = List<String>.from(perguntaAtual['opcoes']);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: const Color(0xFF403AFF),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progresso
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Questão ${_currentQuestionIndex + 1} de ${_perguntas.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${(((_currentQuestionIndex + 1) / _perguntas.length) * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF403AFF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _perguntas.length,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF403AFF)),
                ),
              ],
            ),
          ),

          // Pergunta e Opções
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Enunciado
                  Text(
                    perguntaAtual['enunciado'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Opções
                  ...opcoes.asMap().entries.map((entry) {
                    int index = entry.key;
                    String opcao = entry.value;
                    bool isSelected = _respostas[_currentQuestionIndex] == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _responder(index),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF403AFF) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF403AFF) : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? const Color(0xFF403AFF) : Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  opcao,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // Botões de Navegação
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _voltarPergunta,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Anterior'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _proximaPergunta,
                    icon: Icon(
                      _currentQuestionIndex == _perguntas.length - 1
                          ? Icons.check
                          : Icons.arrow_forward,
                    ),
                    label: Text(
                      _currentQuestionIndex == _perguntas.length - 1
                          ? 'Finalizar'
                          : 'Próxima',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF403AFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
