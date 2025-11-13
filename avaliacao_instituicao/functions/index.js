/**
 * Cloud Functions para Avaliação Institucional
 * Função para deletar usuários do Firebase Authentication
 */

const {onCall} = require("firebase-functions/v2/https");
const {setGlobalOptions} = require("firebase-functions/v2");
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");

// Inicializar Firebase Admin
admin.initializeApp();

// Configurações globais
setGlobalOptions({maxInstances: 10});

/**
 * Cloud Function para deletar usuário do Firebase Authentication
 * Apenas administradores podem chamar esta função
 *
 * Uso no Flutter:
 * final callable = FirebaseFunctions.instance
 *     .httpsCallable('deleteUser');
 * await callable.call({'userId': 'user_id_aqui'});
 */
exports.deleteUser = onCall(async (request) => {
  const {auth, data} = request;

  // 1. Verificar se o usuário está autenticado
  if (!auth) {
    throw new Error("Não autenticado. Faça login para continuar.");
  }

  // 2. Verificar se quem está chamando é administrador
  try {
    const callerDoc = await admin.firestore()
        .collection("usuarios")
        .doc(auth.uid)
        .get();

    if (!callerDoc.exists) {
      throw new Error("Dados do usuário não encontrados.");
    }

    const callerData = callerDoc.data();
    if (callerData.tipoUsuario !== "admin") {
      throw new Error("Apenas administradores podem deletar.");
    }

    logger.info(`Admin ${auth.uid} solicitou exclusão`, {
      userId: data.userId,
    });
  } catch (error) {
    logger.error("Erro ao verificar permissões:", error);
    throw new Error(`Erro ao verificar permissões: ${error.message}`);
  }

  // 3. Validar parâmetros
  const {userId} = data;
  if (!userId || typeof userId !== "string") {
    throw new Error("O parâmetro userId é obrigatório.");
  }

  // 4. Não permitir que o admin delete a si mesmo
  if (userId === auth.uid) {
    throw new Error("Você não pode deletar sua própria conta.");
  }

  // 5. Deletar usuário do Firebase Authentication
  try {
    await admin.auth().deleteUser(userId);

    logger.info(`Usuário ${userId} deletado por ${auth.uid}`);

    return {
      success: true,
      message: "Conta deletada com sucesso.",
      userId: userId,
      deletedAt: new Date().toISOString(),
    };
  } catch (error) {
    logger.error("Erro ao deletar usuário:", error);

    // Tratar erros específicos do Firebase Auth
    if (error.code === "auth/user-not-found") {
      throw new Error("Usuário não encontrado no Authentication.");
    }

    throw new Error(`Erro ao deletar usuário: ${error.message}`);
  }
});

