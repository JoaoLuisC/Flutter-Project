// tela_home.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:avaliacao_instituicao/services/usuario_service.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  final UsuarioService _usuarioService = UsuarioService();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _verificarAdmin();
  }

  Future<void> _verificarAdmin() async {
    bool admin = await _usuarioService.isAdmin();
    setState(() {
      _isAdmin = admin;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // O AuthCheck na main.dart cuidará da navegação
  }

  @override
  Widget build(BuildContext context) {
    // Estilo dos botões da Home
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF403AFF),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 22),
      minimumSize: const Size(double.infinity, 64), // Botões ainda maiores
      textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
    );

    return Scaffold(
      body: Column(
        children: [
          // Header roxo com título
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
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
            child: const Text(
              'Avaliação\nInstitucional',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
          // Corpo com fundo branco
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Bem-vindo(a) à plataforma de\nAvaliação do Aluno',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16, 
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(), // Empurra os botões para o meio
                  
                  // Botão Formulário
                  ElevatedButton(
                    style: buttonStyle,
                    onPressed: () {
                      Navigator.pushNamed(context, '/formulario');
                    },
                    child: const Text('Formulário de Avaliação', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
                  
                  // Botão Quiz
                  ElevatedButton(
                    style: buttonStyle,
                    onPressed: () {
                      Navigator.pushNamed(context, '/quiz');
                    },
                    child: const Text('Quiz de conhecimento', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
                  
                  // Botão Resultados
                  ElevatedButton(
                    style: buttonStyle.copyWith(
                      backgroundColor: WidgetStateProperty.all(Colors.black87),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/resultados');
                    },
                    child: const Text('Resultados Anteriores', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
                  
                  // Botão Gerenciar Usuários (apenas para admin)
                  if (_isAdmin) ...[
                    ElevatedButton.icon(
                      style: buttonStyle.copyWith(
                        backgroundColor: WidgetStateProperty.all(Colors.orange),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/gerenciar-usuarios');
                      },
                      icon: const Icon(Icons.admin_panel_settings),
                      label: const Text('Gerenciar Usuários', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Botão Logout
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair', style: TextStyle(fontSize: 16)),
                  ),
                  
                  const Spacer(), // Empurra a frase para baixo
                  
                  const Text(
                    'Sua opinião é fundamental para a\nconstruirmos uma instituição cada vez melhor',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12, 
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
