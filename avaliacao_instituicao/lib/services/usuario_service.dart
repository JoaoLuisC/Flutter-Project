// services/usuario_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario_model.dart';

class UsuarioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // CREATE - Criar novo usuário (apenas admin pode criar)
  Future<String> criarUsuario({
    required String nome,
    required String email,
    required String senha,
    required String tipoUsuario,
  }) async {
    try {
      // 1. Criar usuário no Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // 2. Salvar dados no Firestore
      await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
        'nome': nome,
        'email': email,
        'tipoUsuario': tipoUsuario,
        'data_criacao': Timestamp.now(),
        'data_atualizacao': null,
      });

      return 'Usuário criado com sucesso!';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw 'Este email já está em uso.';
      } else if (e.code == 'weak-password') {
        throw 'A senha é muito fraca.';
      } else if (e.code == 'invalid-email') {
        throw 'Email inválido.';
      }
      throw 'Erro ao criar usuário: ${e.message}';
    } catch (e) {
      throw 'Erro inesperado: $e';
    }
  }

  // READ - Listar todos os usuários
  Stream<List<UsuarioModel>> listarUsuarios() {
    return _firestore
        .collection('usuarios')
        .orderBy('data_criacao', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UsuarioModel.fromFirestore(doc))
          .toList();
    });
  }

  // READ - Buscar usuário por ID
  Future<UsuarioModel?> buscarUsuarioPorId(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('usuarios')
          .doc(userId)
          .get();

      if (doc.exists) {
        return UsuarioModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Erro ao buscar usuário: $e';
    }
  }

  // UPDATE - Atualizar dados do usuário
  Future<String> atualizarUsuario({
    required String userId,
    required String nome,
    required String email,
    required String tipoUsuario,
  }) async {
    try {
      await _firestore.collection('usuarios').doc(userId).update({
        'nome': nome,
        'email': email,
        'tipoUsuario': tipoUsuario,
        'data_atualizacao': Timestamp.now(),
      });

      // Atualizar email no Firebase Auth também
      User? user = _auth.currentUser;
      if (user != null && user.uid == userId && user.email != email) {
        await user.updateEmail(email);
      }

      return 'Usuário atualizado com sucesso!';
    } catch (e) {
      throw 'Erro ao atualizar usuário: $e';
    }
  }

  // DELETE - Excluir usuário
  Future<String> excluirUsuario(String userId) async {
    try {
      // 1. Excluir documento do Firestore
      await _firestore.collection('usuarios').doc(userId).delete();

      // 2. Excluir dados relacionados (avaliações e quiz)
      await _excluirDadosRelacionados(userId);

      // Nota: Não é possível excluir o usuário do Firebase Auth diretamente
      // sem reautenticação. Isso deve ser feito via Firebase Admin SDK ou
      // o próprio usuário deve estar logado.

      return 'Usuário excluído com sucesso!';
    } catch (e) {
      throw 'Erro ao excluir usuário: $e';
    }
  }

  // Método auxiliar para excluir dados relacionados
  Future<void> _excluirDadosRelacionados(String userId) async {
    // Excluir avaliações
    QuerySnapshot avaliacoes = await _firestore
        .collection('avaliacoes')
        .doc(userId)
        .collection('respostas')
        .get();
    
    for (var doc in avaliacoes.docs) {
      await doc.reference.delete();
    }

    // Excluir resultados de quiz
    QuerySnapshot quizzes = await _firestore
        .collection('resultados_quiz')
        .doc(userId)
        .collection('tentativas')
        .get();
    
    for (var doc in quizzes.docs) {
      await doc.reference.delete();
    }
  }

  // Verificar se usuário atual é admin
  Future<bool> isAdmin() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    DocumentSnapshot doc = await _firestore
        .collection('usuarios')
        .doc(userId)
        .get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data['tipoUsuario'] == 'admin';
    }
    return false;
  }

  // Buscar usuário atual
  Future<UsuarioModel?> buscarUsuarioAtual() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return buscarUsuarioPorId(userId);
  }
}
