// tela_formulario_avaliacao.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaFormularioAvaliacao extends StatefulWidget {
  const TelaFormularioAvaliacao({super.key});

  @override
  State<TelaFormularioAvaliacao> createState() => _TelaFormularioAvaliacaoState();
}

class _TelaFormularioAvaliacaoState extends State<TelaFormularioAvaliacao> {
  final _formKey = GlobalKey<FormState>();
  
  // Variáveis para guardar os valores dos campos
  String? _genero;
  String? _cursoSelecionado;
  double _infraestruturaNota = 3.0;
  final _feedbackController = TextEditingController();
  bool _isLoading = false;

  final List<String> _cursos = [
    'Sistemas de Informação', 
    'Engenharia Agronômica', 
    'Medicina Veterinária', 
    'Zootecnia', 
    'Administração'
  ];
  
  final List<String> _generos = [
    'Masculino',
    'Feminino',
    'Não-binário',
    'Prefiro não informar'
  ];

  Future<void> _enviarFormulario() async {
    if (!(_formKey.currentState?.validate() ?? false) || _genero == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios.')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // Obter o usuário logado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Usuário não autenticado.");
      }

      // Salvar dados no Cloud Firestore - na coleção principal para admin ver
      await FirebaseFirestore.instance
          .collection('avaliacoes')
          .add({
            'genero': _genero,
            'curso': _cursoSelecionado,
            'nota_infra': _infraestruturaNota,
            'feedback': _feedbackController.text,
            'data_envio': FieldValue.serverTimestamp(),
            'userId': user.uid,
            'userEmail': user.email,
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avaliação enviada com sucesso!')),
        );
        Navigator.pop(context);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
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
                    // 1. Gênero (Radio)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Radio<String>(
                          value: 'Masculino',
                          groupValue: _genero,
                          onChanged: (value) => setState(() => _genero = value),
                        ),
                        const Text('Masculino'),
                        const SizedBox(width: 16),
                        Radio<String>(
                          value: 'Feminino',
                          groupValue: _genero,
                          onChanged: (value) => setState(() => _genero = value),
                        ),
                        const Text('Feminino'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'NaoInformado',
                          groupValue: _genero,
                          onChanged: (value) => setState(() => _genero = value),
                        ),
                        const Text('Prefiro não dizer'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. Curso (DropdownButtonFormField)
                    const Text('Qual o seu curso?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _cursoSelecionado,
                      hint: const Text('Selecione o curso'),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      items: _cursos.map((String curso) {
                        return DropdownMenuItem<String>(
                          value: curso,
                          child: Text(curso),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _cursoSelecionado = value),
                      validator: (value) => value == null ? 'Por favor, selecione um curso.' : null,
                    ),
                    const SizedBox(height: 20),

                    // 3. Infraestrutura (Slider)
                    const Text('Infraestrutura adequada para aprendizado?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Slider(
                      value: _infraestruturaNota,
                      min: 1,
                      max: 5,
                      divisions: 4, // 4 divisões = 5 pontos (1, 2, 3, 4, 5)
                      label: _infraestruturaNota.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _infraestruturaNota = value;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1 - Muito ruim', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        Text('3', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        Text('5 - Excelente', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // 4. Feedback (TextField)
                    const Text('Missão e Valores', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Deixe aqui seu comentário ou sugestão (Opcional)', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _feedbackController,
                      decoration: InputDecoration(
                        hintText: 'Digite seu feedback...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      maxLines: 5,
                      // Sem validador, pois é opcional
                    ),
                    const SizedBox(height: 30),

                    // 5. Botão Enviar
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _enviarFormulario,
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
