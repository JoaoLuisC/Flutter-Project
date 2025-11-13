import 'package:flutter/material.dart';
import 'package:avaliacao_instituicao/services/usuario_service.dart';
import 'package:avaliacao_instituicao/tela_home.dart';
import 'package:avaliacao_instituicao/tela_home_professor.dart';
import 'package:avaliacao_instituicao/tela_dashboard_admin.dart';
import 'package:avaliacao_instituicao/tela_configuracoes.dart';
import 'package:avaliacao_instituicao/tela_meus_pokemons_v2.dart';
import 'package:avaliacao_instituicao/tela_gerenciar_usuarios.dart';
import 'package:avaliacao_instituicao/tela_logout.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final UsuarioService _usuarioService = UsuarioService();
  bool _isAdmin = false;
  bool _isProfessor = false;
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _verificarTipoUsuario();
  }

  Future<void> _verificarTipoUsuario() async {
    bool admin = await _usuarioService.isAdmin();
    bool professor = await _usuarioService.isProfessor();
    setState(() {
      _isAdmin = admin;
      _isProfessor = professor;
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Telas para aluno
  List<Widget> _telasAluno() {
    return [
      const TelaHome(),
      const TelaMeusPokemonsV2(),
      const TelaLogout(),
      const TelaConfiguracoes(),
    ];
  }

  // Telas para professor
  List<Widget> _telasProfessor() {
    return [
      const TelaHomeProfessor(),
      const TelaLogout(),
      const TelaConfiguracoes(),
    ];
  }

  // Telas para admin
  List<Widget> _telasAdmin() {
    return [
      const TelaDashboardAdmin(),
      const TelaGerenciarUsuarios(),
      const TelaLogout(),
      const TelaConfiguracoes(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final telas = _isAdmin 
        ? _telasAdmin() 
        : _isProfessor 
            ? _telasProfessor() 
            : _telasAluno();

    return Scaffold(
      body: telas[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF403AFF),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: _isAdmin
              ? const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_rounded, size: 28),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people_rounded, size: 28),
                    label: 'Usuários',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.logout_rounded, size: 28),
                    label: 'Sair',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_rounded, size: 28),
                    label: 'Configurações',
                  ),
                ]
              : _isProfessor
                  ? const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.school_rounded, size: 28),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.logout_rounded, size: 28),
                        label: 'Sair',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.settings_rounded, size: 28),
                        label: 'Configurações',
                      ),
                    ]
                  : const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_rounded, size: 28),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.catching_pokemon_rounded, size: 28),
                        label: 'Pokémons',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.logout_rounded, size: 28),
                        label: 'Sair',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.settings_rounded, size: 28),
                        label: 'Configurações',
                      ),
                    ],
        ),
      ),
    );
  }
}
