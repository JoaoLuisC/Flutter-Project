# Guia: Firebase Admin SDK para Deletar Contas

## Opção 1: Cloud Functions (Recomendado)

### 1. Instalar Firebase CLI
```bash
npm install -g firebase-tools
```

### 2. Fazer Login
```bash
firebase login
```

### 3. Inicializar Functions
```bash
cd "c:\Users\marci\Documents\joao luis\Flutter-Project\avaliacao_instituicao"
firebase init functions
```
- Escolha: Use an existing project
- Selecione seu projeto
- Linguagem: JavaScript ou TypeScript
- ESLint: Sim
- Install dependencies: Sim

### 4. Criar a Cloud Function

Arquivo: `functions/index.js`

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Função para deletar usuário (apenas admins podem chamar)
exports.deleteUser = functions.https.onCall(async (data, context) => {
  // Verificar se quem está chamando é admin
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Usuário não autenticado'
    );
  }

  // Buscar dados do usuário que está chamando a função
  const callerDoc = await admin.firestore()
    .collection('usuarios')
    .doc(context.auth.uid)
    .get();

  if (!callerDoc.exists || callerDoc.data().tipoUsuario !== 'admin') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Apenas administradores podem deletar usuários'
    );
  }

  const { userId } = data;

  if (!userId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'userId é obrigatório'
    );
  }

  try {
    // Deletar conta do Firebase Authentication
    await admin.auth().deleteUser(userId);
    
    return { success: true, message: 'Usuário deletado com sucesso' };
  } catch (error) {
    console.error('Erro ao deletar usuário:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Erro ao deletar usuário: ${error.message}`
    );
  }
});
```

### 5. Deploy da Function
```bash
firebase deploy --only functions
```

### 6. Adicionar no Flutter (pubspec.yaml)
```yaml
dependencies:
  cloud_functions: ^5.1.3
```

### 7. Atualizar usuario_service.dart

```dart
import 'package:cloud_functions/cloud_functions.dart';

class UsuarioService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Método completo que deleta TUDO (Firestore + Auth)
  Future<void> excluirUsuarioCompleto(String userId) async {
    // 1. Deletar dados do Firestore
    await excluirUsuario(userId);
    
    // 2. Chamar Cloud Function para deletar Auth
    try {
      final callable = _functions.httpsCallable('deleteUser');
      final result = await callable.call({'userId': userId});
      print('Usuário deletado do Auth: ${result.data}');
    } catch (e) {
      print('Erro ao deletar do Auth (não crítico): $e');
      // Se falhar aqui, pelo menos os dados do Firestore foram removidos
    }
  }
}
```

---

## Opção 2: Implementação Simples SEM Admin SDK

Se você não quer configurar Cloud Functions agora, pode usar esta abordagem mais simples:

### Adicionar botão de "Desativar Conta" em vez de deletar

```dart
// No tela_gerenciar_usuarios.dart
Future<void> _desativarUsuario(String userId) async {
  try {
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .update({'ativo': false, 'desativadoEm': FieldValue.serverTimestamp()});
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuário desativado com sucesso!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
    );
  }
}
```

### Bloquear login de usuários desativados

```dart
// No tela_login.dart, após autenticar:
final userDoc = await FirebaseFirestore.instance
    .collection('usuarios')
    .doc(user.uid)
    .get();

if (userDoc.data()?['ativo'] == false) {
  await FirebaseAuth.instance.signOut();
  throw Exception('Conta desativada. Entre em contato com o administrador.');
}
```

---

## Comparação das Opções

| Recurso | Cloud Functions | Desativar Conta |
|---------|----------------|-----------------|
| Complexidade | Média | Baixa |
| Requer Node.js | Sim | Não |
| Deleta Auth | Sim | Não |
| Custo | Gratuito até 2M chamadas/mês | Gratuito |
| Setup | ~30 minutos | ~5 minutos |
| Segurança | Máxima | Boa |

---

## Recomendação

**Para produção:** Use Cloud Functions (Opção 1)
**Para desenvolvimento/MVP:** Use Desativar Conta (Opção 2)

A Opção 2 é mais simples e já resolve o problema de forma segura, pois:
- Os dados do Firestore são deletados
- O usuário não consegue fazer login (conta desativada)
- Você pode reativar se necessário
- Não precisa configurar nada extra
