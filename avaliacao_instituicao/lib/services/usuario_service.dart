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
        'ativo': true,
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
      // 1. Excluir dados relacionados primeiro
      await _excluirDadosRelacionados(userId);

      // 2. Excluir documento do Firestore
      await _firestore.collection('usuarios').doc(userId).delete();

      // Nota: A conta do Firebase Auth não pode ser excluída diretamente
      // sem reautenticação do usuário. Isso requer Firebase Admin SDK.
      // Por enquanto, apenas removemos os dados do Firestore.

      return 'Usuário excluído com sucesso!';
    } catch (e) {
      throw 'Erro ao excluir usuário: $e';
    }
  }

  // Método auxiliar para excluir dados relacionados
  Future<void> _excluirDadosRelacionados(String userId) async {
    try {
      // Excluir avaliações institucionais
      final avaliacoesSnapshot = await _firestore
          .collection('avaliacoes')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (var doc in avaliacoesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Excluir resultados de quiz do sistema
      final resultadosQuizDoc = await _firestore
          .collection('resultados_quiz')
          .doc(userId)
          .get();
      
      if (resultadosQuizDoc.exists) {
        // Excluir subcoleção de tentativas
        final tentativas = await resultadosQuizDoc.reference
            .collection('tentativas')
            .get();
        
        for (var doc in tentativas.docs) {
          await doc.reference.delete();
        }
        
        // Excluir documento principal
        await resultadosQuizDoc.reference.delete();
      }

      // Excluir pokémons conquistados
      final pokemonsSnapshot = await _firestore
          .collection('quiz_resultados')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (var doc in pokemonsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Excluir respostas de quizzes de professores
      final respostasQuizzesProfSnapshot = await _firestore
          .collection('resultados_quiz_professores')
          .where('alunoId', isEqualTo: userId)
          .get();
      
      for (var doc in respostasQuizzesProfSnapshot.docs) {
        await doc.reference.delete();
      }

      // Se o usuário for professor, excluir seus quizzes criados
      final quizzesCriadosSnapshot = await _firestore
          .collection('quizzes_professores')
          .where('professorId', isEqualTo: userId)
          .get();
      
      for (var doc in quizzesCriadosSnapshot.docs) {
        // Excluir também os resultados dos alunos nesse quiz
        final resultadosQuiz = await _firestore
            .collection('resultados_quiz_professores')
            .where('quizId', isEqualTo: doc.id)
            .get();
        
        for (var resultado in resultadosQuiz.docs) {
          await resultado.reference.delete();
        }
        
        // Excluir o quiz
        await doc.reference.delete();
      }
    } catch (e) {
      throw 'Erro ao excluir dados relacionados: $e';
    }
  }

  // Excluir usuário e desativar conta
  Future<Map<String, dynamic>> excluirUsuarioCompleto(String userId) async {
    try {
      // 1. Marcar usuário como desativado ANTES de deletar dados
      await _firestore.collection('usuarios').doc(userId).update({
        'ativo': false,
        'desativadoEm': FieldValue.serverTimestamp(),
      });
      
      // 2. Deletar dados do Firestore
      await _excluirDadosRelacionados(userId);
      
      // 3. Deletar documento do usuário
      await _firestore.collection('usuarios').doc(userId).delete();
      
      return {
        'success': true,
        'firestoreDeleted': true,
        'accountDisabled': true,
        'message': 'Usuário desativado e dados removidos com sucesso.'
      };
    } catch (e) {
      throw 'Erro ao excluir usuário: $e';
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

  // Verificar se usuário atual é professor
  Future<bool> isProfessor() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    DocumentSnapshot doc = await _firestore
        .collection('usuarios')
        .doc(userId)
        .get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data['tipoUsuario'] == 'professor';
    }
    return false;
  }

  // Buscar usuário atual
  Future<UsuarioModel?> buscarUsuarioAtual() async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return buscarUsuarioPorId(userId);
  }

  // Adicionar amigo por código
  Future<void> adicionarAmigo(String codigoAmizade) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    // Buscar usuário pelo código de amizade
    final querySnapshot = await _firestore
        .collection('usuarios')
        .where('codigoAmizade', isEqualTo: codigoAmizade)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Código de amizade não encontrado');
    }

    final amigoDoc = querySnapshot.docs.first;
    final amigoId = amigoDoc.id;

    if (amigoId == userId) {
      throw Exception('Você não pode adicionar a si mesmo');
    }

    // Adicionar amigo na lista do usuário atual
    await _firestore.collection('usuarios').doc(userId).update({
      'amigos': FieldValue.arrayUnion([amigoId]),
    });

    // Adicionar usuário atual na lista do amigo
    await _firestore.collection('usuarios').doc(amigoId).update({
      'amigos': FieldValue.arrayUnion([userId]),
    });
  }

  // Remover amigo
  Future<void> removerAmigo(String amigoId) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado');

    // Remover amigo da lista do usuário atual
    await _firestore.collection('usuarios').doc(userId).update({
      'amigos': FieldValue.arrayRemove([amigoId]),
    });

    // Remover usuário atual da lista do amigo
    await _firestore.collection('usuarios').doc(amigoId).update({
      'amigos': FieldValue.arrayRemove([userId]),
    });
  }
}
