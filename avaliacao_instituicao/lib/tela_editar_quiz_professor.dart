import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaEditarQuizProfessor extends StatefulWidget {
  final String quizId;
  
  const TelaEditarQuizProfessor({super.key, required this.quizId});

  @override
  State<TelaEditarQuizProfessor> createState() => _TelaEditarQuizProfessorState();
}

class _TelaEditarQuizProfessorState extends State<TelaEditarQuizProfessor> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  IconData _iconeEscolhido = Icons.quiz;
  bool _isLoading = true;
  bool _isSaving = false;
  
  final List<PerguntaQuizProfessor> _perguntas = [];

  final List<IconData> _iconesDisponiveis = [
    Icons.quiz,
    Icons.science,
    Icons.calculate,
    Icons.language,
    Icons.public,
    Icons.sports_soccer,
    Icons.palette,
    Icons.psychology,
    Icons.biotech,
    Icons.computer,
    Icons.music_note,
  ];

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
        _tituloController.text = data['titulo'] ?? '';
        
        // Carregar ícone como codePoint
        final iconeData = data['icone'];
        if (iconeData != null) {
          if (iconeData is int) {
            _iconeEscolhido = IconData(iconeData, fontFamily: 'MaterialIcons');
          } else if (iconeData is String) {
            // Compatibilidade com formato antigo
            _iconeEscolhido = Icons.quiz;
          }
        }
        
        final perguntasData = data['perguntas'] as List<dynamic>? ?? [];
        _perguntas.clear();
        for (var p in perguntasData) {
          _perguntas.add(PerguntaQuizProfessor.fromMap(p));
        }
        
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar quiz: $e'), backgroundColor: Colors.red),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _salvarQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar perguntas
    for (int i = 0; i < _perguntas.length; i++) {
      if (_perguntas[i].enunciado.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preencha o enunciado da pergunta ${i + 1}')),
        );
        return;
      }
      for (int j = 0; j < 4; j++) {
        if (_perguntas[i].opcoes[j].isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Preencha a opção ${String.fromCharCode(65 + j)} da pergunta ${i + 1}')),
          );
          return;
        }
      }
      if (_perguntas[i].respostaCorreta == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selecione a resposta correta da pergunta ${i + 1}')),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('quizzes_professores')
          .doc(widget.quizId)
          .update({
        'titulo': _tituloController.text.trim(),
        'icone': _iconeEscolhido.codePoint,
        'perguntas': _perguntas.map((p) => p.toMap()).toList(),
        'dataAtualizacao': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz atualizado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar Quiz'),
          backgroundColor: const Color(0xFF403AFF),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Quiz'),
        backgroundColor: const Color(0xFF403AFF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _salvarQuiz,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título do Quiz',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Digite um título' : null,
            ),
            const SizedBox(height: 16),

            // Seletor de ícone
            const Text('Selecione um ícone:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _iconesDisponiveis.map((icone) {
                final selecionado = icone == _iconeEscolhido;
                return GestureDetector(
                  onTap: () => setState(() => _iconeEscolhido = icone),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selecionado
                          ? const Color(0xFF403AFF)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selecionado
                            ? const Color(0xFF403AFF)
                            : Colors.grey.shade400,
                      ),
                    ),
                    child: Icon(
                      icone,
                      color: selecionado ? Colors.white : Colors.black54,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Perguntas
            const Text(
              '10 Perguntas (ABCD)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            ..._perguntas.asMap().entries.map((entry) {
              int index = entry.key;
              PerguntaQuizProfessor pergunta = entry.value;
              return _buildPerguntaCard(index, pergunta);
            }).toList(),

            const SizedBox(height: 24),
            if (_isSaving)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: _salvarQuiz,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Salvar Alterações', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerguntaCard(int index, PerguntaQuizProfessor pergunta) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pergunta ${index + 1}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: pergunta.enunciado,
              decoration: const InputDecoration(
                labelText: 'Enunciado',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) => pergunta.enunciado = value,
            ),
            const SizedBox(height: 12),
            ...List.generate(4, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Radio<int>(
                      value: i,
                      groupValue: pergunta.respostaCorreta,
                      onChanged: (value) {
                        setState(() => pergunta.respostaCorreta = value!);
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: pergunta.opcoes[i],
                        decoration: InputDecoration(
                          labelText: 'Opção ${String.fromCharCode(65 + i)}',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) => pergunta.opcoes[i] = value,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }
}

class PerguntaQuizProfessor {
  String enunciado;
  List<String> opcoes;
  int respostaCorreta;

  PerguntaQuizProfessor({
    required this.enunciado,
    required this.opcoes,
    required this.respostaCorreta,
  });

  Map<String, dynamic> toMap() {
    return {
      'enunciado': enunciado,
      'opcoes': opcoes,
      'respostaCorretaIndex': respostaCorreta,
    };
  }

  factory PerguntaQuizProfessor.fromMap(Map<String, dynamic> map) {
    return PerguntaQuizProfessor(
      enunciado: map['enunciado'] ?? '',
      opcoes: List<String>.from(map['opcoes'] ?? []),
      respostaCorreta: map['respostaCorretaIndex'] ?? map['respostaCorreta'] ?? -1,
    );
  }
}
