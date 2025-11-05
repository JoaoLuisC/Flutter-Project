// tela_quiz.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Modelo para uma Pergunta do Quiz
class PerguntaQuiz {
  final String enunciado;
  final List<String> opcoes;
  final int respostaCorretaIndex;

  PerguntaQuiz({
    required this.enunciado,
    required this.opcoes,
    required this.respostaCorretaIndex,
  });
}

class TelaQuiz extends StatefulWidget {
  const TelaQuiz({super.key});

  @override
  State<TelaQuiz> createState() => _TelaQuizState();
}

class _TelaQuizState extends State<TelaQuiz> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Lista das 10 perguntas
  final List<PerguntaQuiz> _perguntas = [
    PerguntaQuiz(
      enunciado: '1- Qual dos temas abaixo reflete a principal missão da instituição?',
      opcoes: ['Formação de cidadãos críticos, corpo docente', 'Foco na retenção de talentos.'],
      respostaCorretaIndex: 0,
    ),
    PerguntaQuiz(
      enunciado: '2- De acordo com o regime geral, qual o mínimo de frequência exigida?',
      opcoes: ['75 % de presença', '60 % de presença'],
      respostaCorretaIndex: 0,
    ),
    PerguntaQuiz(
      enunciado: '3- Qual o nome do(a) Reitor(a) atual?',
      opcoes: ['Prof. Dr. A', 'Prof. Dra. B', 'Prof. Dr. C'],
      respostaCorretaIndex: 1, // Exemplo
    ),
    PerguntaQuiz(
      enunciado: '4- Onde se localiza a biblioteca central?',
      opcoes: ['Prédio A', 'Prédio B (Principal)', 'Prédio C'],
      respostaCorretaIndex: 1,
    ),
    PerguntaQuiz(
      enunciado: '5- Qual destes NÃO é um valor oficial da instituição?',
      opcoes: ['Ética', 'Inovação', 'Individualismo'],
      respostaCorretaIndex: 2,
    ),
    PerguntaQuiz(
      enunciado: '6- Qual o setor responsável por solicitações de estágio?',
      opcoes: ['Secretaria Acadêmica', 'Setor de Estágios', 'Coordenação do Curso'],
      respostaCorretaIndex: 1,
    ),
    PerguntaQuiz(
      enunciado: '7- O trancamento de matrícula deve ser feito em qual setor?',
      opcoes: ['Secretaria Acadêmica', 'Biblioteca', 'Financeiro'],
      respostaCorretaIndex: 0,
    ),
    PerguntaQuiz(
      enunciado: '8- Qual o ano de fundação da instituição?',
      opcoes: ['1980', '1995', '2005'],
      respostaCorretaIndex: 0, // Exemplo
    ),
    PerguntaQuiz(
      enunciado: '9- O sistema acadêmico oficial para notas e faltas é:',
      opcoes: ['Portal do Aluno', 'Google Classroom', 'Moodle'],
      respostaCorretaIndex: 0,
    ),
    PerguntaQuiz(
      enunciado: '10- Qual o principal canal de comunicação oficial com o aluno?',
      opcoes: ['Email institucional', 'WhatsApp do Coordenador', 'Instagram'],
      respostaCorretaIndex: 0,
    ),
  ];

  // Mapa para guardar as respostas do usuário
  final Map<int, int> _respostas = {};

  Future<void> _enviarQuiz() async {
    // Verifica se todas as perguntas foram respondidas
    if (_respostas.length < _perguntas.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, responda todas as perguntas.')),
      );
      return;
    }
    
    setState(() => _isLoading = true);

    // Lógica de verificação
    int acertos = 0;
    for (int i = 0; i < _perguntas.length; i++) {
      if (_respostas[i] == _perguntas[i].respostaCorretaIndex) {
        acertos++;
      }
    }
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Usuário não autenticado.");

      // Salvar resultado no Firestore
      await FirebaseFirestore.instance
          .collection('resultados_quiz')
          .doc(user.uid)
          .collection('tentativas')
          .add({
            'acertos': acertos,
            'total_perguntas': _perguntas.length,
            'data_envio': Timestamp.now(),
            'userId': user.uid,
          });

      // Mostrar resultado em um AlertDialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Resultado do Quiz'),
            content: Text('Você acertou $acertos de ${_perguntas.length} perguntas!\n\nSeu resultado foi salvo.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // Fecha o dialog
                  Navigator.of(context).pop(); // Volta para a Home
                },
                child: const Text('OK'),
              ),
            ],
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
          // Header roxo com título
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF403AFF), // Roxo
                  Color(0xFF000000), // Preto
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
                    'Formulário de\nAvaliação',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Para balancear o botão de voltar
              ],
            ),
          ),
          // Corpo com fundo branco
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gerar a lista de perguntas dinamicamente
                    ..._perguntas.asMap().entries.map((entry) {
                      int indexPergunta = entry.key;
                      PerguntaQuiz pergunta = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pergunta.enunciado,
                              style: const TextStyle(
                                fontSize: 15, 
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Gerar as opções de rádio
                            ...pergunta.opcoes.asMap().entries.map((entryOpcao) {
                              int indexOpcao = entryOpcao.key;
                              String textoOpcao = entryOpcao.value;

                              return Row(
                                children: [
                                  Radio<int>(
                                    value: indexOpcao,
                                    groupValue: _respostas[indexPergunta],
                                    onChanged: (value) {
                                      setState(() {
                                        _respostas[indexPergunta] = value as int;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      textoOpcao,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    }).toList(),
                    
                    const SizedBox(height: 30),
                    
                    // Botão Enviar
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _enviarQuiz,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Enviar', style: TextStyle(fontSize: 16)),
                              ),
                      ),
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
}
