import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaCriarQuizProfessor extends StatefulWidget {
  const TelaCriarQuizProfessor({super.key});

  @override
  State<TelaCriarQuizProfessor> createState() => _TelaCriarQuizProfessorState();
}

class _TelaCriarQuizProfessorState extends State<TelaCriarQuizProfessor> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  IconData _iconeEscolhido = Icons.quiz;
  bool _isLoading = false;
  
  List<PerguntaQuizProfessor> _perguntas = [];

  final List<IconData> _iconesDisponiveis = [
    Icons.quiz,
    Icons.science,
    Icons.computer,
    Icons.code,
    Icons.smartphone,
    Icons.cloud,
    Icons.security,
    Icons.psychology,
    Icons.functions,
    Icons.abc,
  ];

  @override
  void initState() {
    super.initState();
    // Inicializar com 10 perguntas vazias
    _perguntas = List.generate(10, (index) => PerguntaQuizProfessor());
  }

  @override
  void dispose() {
    _tituloController.dispose();
    for (var pergunta in _perguntas) {
      pergunta.dispose();
    }
    super.dispose();
  }

  Future<void> _salvarQuiz() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Converter perguntas para Map
      List<Map<String, dynamic>> perguntasData = _perguntas.map((p) => {
        'enunciado': p.enunciadoController.text.trim(),
        'opcoes': [
          p.opcaoAController.text.trim(),
          p.opcaoBController.text.trim(),
          p.opcaoCController.text.trim(),
          p.opcaoDController.text.trim(),
        ],
        'respostaCorretaIndex': p.respostaCorreta,
      }).toList();

      // Salvar no Firestore
      await FirebaseFirestore.instance.collection('quizzes_professores').add({
        'titulo': _tituloController.text.trim(),
        'icone': _iconeEscolhido.codePoint,
        'professorId': user.uid,
        'professorEmail': user.email,
        'perguntas': perguntasData,
        'ativo': true,
        'dataCriacao': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Quiz criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao criar quiz: $e'),
            backgroundColor: Colors.red,
          ),
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
                const Expanded(
                  child: Text(
                    'Criar Novo Quiz',
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

          // Formulário
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
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
                        value?.trim().isEmpty ?? true ? 'Digite o título' : null,
                  ),
                  
                  const SizedBox(height: 20),

                  // Seletor de Ícone
                  const Text(
                    'Escolha um ícone:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _iconesDisponiveis.map((icone) {
                      final selecionado = icone == _iconeEscolhido;
                      return InkWell(
                        onTap: () => setState(() => _iconeEscolhido = icone),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: selecionado
                                ? const Color(0xFF403AFF)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selecionado
                                  ? const Color(0xFF403AFF)
                                  : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            icone,
                            color: selecionado ? Colors.white : Colors.grey[700],
                            size: 32,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),

                  // 10 Perguntas
                  const Text(
                    'Perguntas (10 obrigatórias):',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  ..._perguntas.asMap().entries.map((entry) {
                    final index = entry.key;
                    final pergunta = entry.value;
                    return _buildPerguntaCard(index + 1, pergunta);
                  }).toList(),

                  const SizedBox(height: 32),

                  // Botão Salvar
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _salvarQuiz,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isLoading ? 'Salvando...' : 'Criar Quiz'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
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

  Widget _buildPerguntaCard(int numero, PerguntaQuizProfessor pergunta) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pergunta $numero',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Enunciado
            TextFormField(
              controller: pergunta.enunciadoController,
              decoration: const InputDecoration(
                labelText: 'Enunciado',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) =>
                  value?.trim().isEmpty ?? true ? 'Digite o enunciado' : null,
            ),
            const SizedBox(height: 12),

            // Opções
            _buildOpcaoField('A', pergunta.opcaoAController, 0, pergunta),
            const SizedBox(height: 8),
            _buildOpcaoField('B', pergunta.opcaoBController, 1, pergunta),
            const SizedBox(height: 8),
            _buildOpcaoField('C', pergunta.opcaoCController, 2, pergunta),
            const SizedBox(height: 8),
            _buildOpcaoField('D', pergunta.opcaoDController, 3, pergunta),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcaoField(
    String letra,
    TextEditingController controller,
    int index,
    PerguntaQuizProfessor pergunta,
  ) {
    return Row(
      children: [
        Radio<int>(
          value: index,
          groupValue: pergunta.respostaCorreta,
          onChanged: (value) {
            setState(() {
              pergunta.respostaCorreta = value!;
            });
          },
        ),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Opção $letra',
              border: const OutlineInputBorder(),
              fillColor: pergunta.respostaCorreta == index
                  ? Colors.green.withOpacity(0.1)
                  : null,
              filled: pergunta.respostaCorreta == index,
            ),
            validator: (value) =>
                value?.trim().isEmpty ?? true ? 'Preencha a opção $letra' : null,
          ),
        ),
      ],
    );
  }
}

class PerguntaQuizProfessor {
  final enunciadoController = TextEditingController();
  final opcaoAController = TextEditingController();
  final opcaoBController = TextEditingController();
  final opcaoCController = TextEditingController();
  final opcaoDController = TextEditingController();
  int respostaCorreta = 0;

  void dispose() {
    enunciadoController.dispose();
    opcaoAController.dispose();
    opcaoBController.dispose();
    opcaoCController.dispose();
    opcaoDController.dispose();
  }
}
