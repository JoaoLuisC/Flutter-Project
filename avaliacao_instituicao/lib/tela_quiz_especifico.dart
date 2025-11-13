import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:avaliacao_instituicao/tela_resultado_pokemon.dart';
import 'package:avaliacao_instituicao/data/quizzes_data.dart';

class TelaQuizEspecifico extends StatefulWidget {
  final String quizId;
  final String titulo;

  const TelaQuizEspecifico({
    super.key,
    required this.quizId,
    required this.titulo,
  });

  @override
  State<TelaQuizEspecifico> createState() => _TelaQuizEspecificoState();
}

class _TelaQuizEspecificoState extends State<TelaQuizEspecifico> {
  int _currentQuestionIndex = 0;
  List<int?> _respostas = [];
  List<PerguntaQuizData> _perguntas = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _perguntas = QuizzesData.getTodasPerguntas()[widget.quizId] ?? [];
    _respostas = List<int?>.filled(_perguntas.length, null);
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

    setState(() => _isLoading = true);

    // Calcular acertos
    int acertos = 0;
    for (int i = 0; i < _perguntas.length; i++) {
      if (_respostas[i] == _perguntas[i].respostaCorretaIndex) {
        acertos++;
      }
    }
    
    // Verificar pontuação perfeita (10/10)
    final pontuacaoPerfeita = acertos == _perguntas.length && _perguntas.length == 10;
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Usuário não autenticado.");

      // Salvar resultado no Firestore
      await FirebaseFirestore.instance
          .collection('resultados_quiz')
          .doc(user.uid)
          .collection('tentativas')
          .add({
            'quiz_tipo': widget.quizId,
            'quiz_titulo': widget.titulo,
            'acertos': acertos,
            'total_perguntas': _perguntas.length,
            'pontuacao_perfeita': pontuacaoPerfeita,
            'data_envio': Timestamp.now(),
            'userId': user.uid,
          });

      // Navegar para tela de Pokémons com a pontuação
      if (mounted) {
        setState(() => _isLoading = false);
        
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
          SnackBar(content: Text('Erro ao salvar: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
                Expanded(
                  child: Text(
                    'Quiz: ${widget.titulo}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          
          // Progress bar and question
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bar
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pergunta ${_currentQuestionIndex + 1} de ${_perguntas.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF403AFF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${((_currentQuestionIndex + 1) / _perguntas.length * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Question
                  Text(
                    _perguntas[_currentQuestionIndex].enunciado,
                    style: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Options
                  ..._perguntas[_currentQuestionIndex].opcoes.asMap().entries.map((entry) {
                    int indexOpcao = entry.key;
                    String textoOpcao = entry.value;
                    bool isSelected = _respostas[_currentQuestionIndex] == indexOpcao;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: () => _responder(indexOpcao),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF403AFF).withOpacity(0.1) : Colors.white,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF403AFF) : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? const Color(0xFF403AFF) : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF403AFF) : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  textoOpcao,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isSelected ? const Color(0xFF403AFF) : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _voltarPergunta,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF403AFF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Anterior',
                        style: TextStyle(fontSize: 16, color: Color(0xFF403AFF)),
                      ),
                    ),
                  ),
                
                if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _proximaPergunta,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF403AFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _currentQuestionIndex < _perguntas.length - 1 ? 'Próxima' : 'Finalizar',
                            style: const TextStyle(fontSize: 16, color: Colors.white),
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
