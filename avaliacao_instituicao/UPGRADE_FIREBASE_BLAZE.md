# Como Ativar Exclusão Completa de Contas (Firebase Authentication)

## Status Atual

✅ **Funcionalidade Implementada:**
- Exclusão completa de dados do Firestore
- Exclusão de avaliações, quizzes, pokémons
- Exclusão de quizzes criados por professores
- Exclusão em cascata de todos os dados relacionados

⚠️ **Limitação Atual:**
- A conta do Firebase Authentication **NÃO** é deletada
- Isso é uma limitação de segurança do Firebase
- Para deletar contas do Auth, é necessário **Firebase Admin SDK**

---

## Como Funciona Atualmente

Quando você deleta um usuário:
1. ✅ Todos os dados são removidos do Firestore
2. ❌ A conta permanece no Firebase Authentication
3. ℹ️ O usuário NÃO consegue fazer login útil (sem dados no Firestore)

**É seguro?** Sim! Sem dados no Firestore, a conta do Auth é inútil.

---

## Opção 1: Ativar Firebase Functions (Deletar Conta do Auth)

### Passo 1: Upgrade para Plano Blaze

1. Acesse: https://console.firebase.google.com/project/avaliacao-instituicao/usage/details
2. Clique em "Fazer upgrade para Blaze"
3. **Custo:** Gratuito até 2 milhões de chamadas/mês
4. **Requer:** Cartão de crédito cadastrado

### Passo 2: Deploy da Cloud Function

A função já está criada em `functions/index.js`. Para fazer deploy:

```bash
cd "c:\Users\marci\Documents\joao luis\Flutter-Project\avaliacao_instituicao"
firebase deploy --only functions
```

### Passo 3: Atualizar o Código Flutter

1. Adicionar dependência no `pubspec.yaml`:
```yaml
dependencies:
  cloud_functions: ^5.1.3
```

2. Atualizar `lib/services/usuario_service.dart`:
```dart
import 'package:cloud_functions/cloud_functions.dart';

class UsuarioService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  
  Future<void> excluirUsuarioCompleto(String userId) async {
    // 1. Deletar Firestore
    await excluirUsuario(userId);
    
    // 2. Deletar Auth via Cloud Function
    final callable = _functions.httpsCallable('deleteUser');
    await callable.call({'userId': userId});
  }
}
```

3. Rodar `flutter pub get`

---

## Opção 2: Deletar Manualmente no Console Firebase

Se você não quer ativar o plano Blaze, pode deletar manualmente:

1. Acesse: https://console.firebase.google.com/project/avaliacao-instituicao/authentication/users
2. Encontre o usuário pelo email
3. Clique nos 3 pontos (...) → "Delete account"

---

## Opção 3: Continuar Como Está

**Recomendado para desenvolvimento e pequenos projetos:**

- Os dados do Firestore são deletados ✅
- A conta do Auth fica "órfã" (sem utilidade) ⚠️
- O usuário não consegue fazer login útil ✅
- Solução simples e gratuita ✅

---

## Comparação das Opções

| Característica | Opção 1 (Functions) | Opção 2 (Manual) | Opção 3 (Atual) |
|----------------|---------------------|------------------|-----------------|
| **Custo** | Gratuito até 2M/mês | Gratuito | Gratuito |
| **Setup** | 10 minutos | 0 minutos | 0 minutos |
| **Automático** | ✅ Sim | ❌ Não | ✅ Sim (parcial) |
| **Auth Deletado** | ✅ Sim | ✅ Sim | ❌ Não |
| **Firestore Deletado** | ✅ Sim | ✅ Sim | ✅ Sim |
| **Requer Cartão** | ✅ Sim | ❌ Não | ❌ Não |
| **Seguro** | ✅✅✅ | ✅✅✅ | ✅✅ Sim |

---

## Recomendação

**Para desenvolvimento/MVP:** Use a Opção 3 (atual)
**Para produção:** Use a Opção 1 (Firebase Functions)

A implementação atual é segura e suficiente para a maioria dos casos!
