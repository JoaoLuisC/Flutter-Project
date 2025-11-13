// tela_gerenciar_usuarios.dart
import 'package:flutter/material.dart';
import 'package:avaliacao_instituicao/models/usuario_model.dart';
import 'package:avaliacao_instituicao/services/usuario_service.dart';
import 'package:avaliacao_instituicao/tela_cadastro_usuario.dart';
import 'package:avaliacao_instituicao/tela_editar_usuario.dart';

class TelaGerenciarUsuarios extends StatefulWidget {
  final String? filtroTipo;
  
  const TelaGerenciarUsuarios({super.key, this.filtroTipo});

  @override
  State<TelaGerenciarUsuarios> createState() => _TelaGerenciarUsuariosState();
}

class _TelaGerenciarUsuariosState extends State<TelaGerenciarUsuarios> {
  final UsuarioService _usuarioService = UsuarioService();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _verificarAdmin();
  }

  Future<void> _verificarAdmin() async {
    bool admin = await _usuarioService.isAdmin();
    setState(() => _isAdmin = admin);
  }

  void _confirmarExclusao(UsuarioModel usuario) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tem certeza que deseja excluir o usuário "${usuario.nome}"?'),
            const SizedBox(height: 16),
            const Text(
              'Serão excluídos:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Text('• Todos os dados do Firestore', style: TextStyle(fontSize: 13)),
            const Text('• Avaliações e quizzes', style: TextStyle(fontSize: 13)),
            const Text('• Pokémons conquistados', style: TextStyle(fontSize: 13)),
            if (usuario.tipoUsuario == 'professor')
              const Text('• Quizzes criados', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            const Text(
              '🔒 A conta será desativada e o usuário não poderá mais fazer login.',
              style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await _excluirUsuario(usuario.id, usuario.email);
            },
            child: const Text('Excluir Dados'),
          ),
        ],
      ),
    );
  }

  Future<void> _excluirUsuario(String userId, String userEmail) async {
    try {
      final result = await _usuarioService.excluirUsuarioCompleto(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✅ Usuário desativado e dados excluídos!'),
                const SizedBox(height: 4),
                Text(
                  'Email: $userEmail',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                const Text(
                  'O usuário não poderá mais fazer login no sistema.',
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
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
                    widget.filtroTipo == null 
                        ? 'Gerenciar\nUsuários'
                        : 'Gerenciar\n${widget.filtroTipo == "aluno" ? "Alunos" : "Professores"}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Lista de usuários
          Expanded(
            child: StreamBuilder<List<UsuarioModel>>(
              stream: _usuarioService.listarUsuarios(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<UsuarioModel> usuarios = snapshot.data ?? [];
                
                // Filtrar por tipo de usuário se filtroTipo foi especificado
                if (widget.filtroTipo != null) {
                  usuarios = usuarios.where((u) => u.tipoUsuario == widget.filtroTipo).toList();
                }

                if (usuarios.isEmpty) {
                  return Center(
                    child: Text('Nenhum usuário ${widget.filtroTipo ?? ''} cadastrado.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    UsuarioModel usuario = usuarios[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: usuario.tipoUsuario == 'admin'
                              ? Colors.orange
                              : usuario.tipoUsuario == 'professor'
                              ? Colors.purple
                              : const Color(0xFF403AFF),
                          child: Icon(
                            usuario.tipoUsuario == 'admin'
                                ? Icons.admin_panel_settings
                                : usuario.tipoUsuario == 'professor'
                                ? Icons.school
                                : Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          usuario.nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(usuario.email),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: usuario.tipoUsuario == 'admin'
                                    ? Colors.orange.shade100
                                    : usuario.tipoUsuario == 'professor'
                                    ? Colors.purple.shade100
                                    : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                usuario.tipoUsuario == 'admin'
                                    ? 'Administrador'
                                    : usuario.tipoUsuario == 'professor'
                                    ? 'Professor'
                                    : 'Aluno',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: usuario.tipoUsuario == 'admin'
                                      ? Colors.orange.shade900
                                      : usuario.tipoUsuario == 'professor'
                                      ? Colors.purple.shade900
                                      : Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: _isAdmin
                            ? PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'editar',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Editar'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'excluir',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 20, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Excluir', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'editar') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TelaEditarUsuario(usuario: usuario),
                                      ),
                                    );
                                  } else if (value == 'excluir') {
                                    _confirmarExclusao(usuario);
                                  }
                                },
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelaCadastroUsuario(),
                  ),
                );
              },
              backgroundColor: const Color(0xFF403AFF),
              icon: const Icon(Icons.person_add),
              label: const Text('Novo Usuário'),
            )
          : null,
    );
  }
}
