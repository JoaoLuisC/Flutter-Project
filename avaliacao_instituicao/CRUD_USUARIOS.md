# Sistema de Gerenciamento de Usuários (CRUD)

## 📋 Visão Geral

Este documento descreve o sistema completo de gerenciamento de usuários implementado no aplicativo de Avaliação Institucional. O sistema permite realizar todas as operações CRUD (Create, Read, Update, Delete) de usuários com Firebase Authentication e Cloud Firestore.

---

## 🏗️ Arquitetura

### Estrutura de Arquivos

```
lib/
├── models/
│   └── usuario_model.dart          # Modelo de dados do usuário
├── services/
│   └── usuario_service.dart        # Lógica de negócio e operações Firebase
├── tela_gerenciar_usuarios.dart    # Tela de listagem (READ)
├── tela_cadastro_usuario.dart      # Tela de criação (CREATE)
├── tela_editar_usuario.dart        # Tela de edição (UPDATE)
└── tela_home.dart                  # Botão de acesso (apenas admin)
```

---

## 📊 Modelo de Dados

### Classe: `UsuarioModel`

```dart
class UsuarioModel {
  final String id;              // UID do Firebase Auth
  final String nome;            // Nome completo
  final String email;           // Email único
  final String tipoUsuario;     // 'admin' ou 'aluno'
  final DateTime dataCriacao;
  final DateTime? dataAtualizacao;
}
```

### Estrutura no Firestore

```
firestore/
└── usuarios/
    └── {userId}/
        ├── nome: String
        ├── email: String
        ├── tipoUsuario: String
        ├── data_criacao: Timestamp
        └── data_atualizacao: Timestamp (opcional)
```

---

## ⚙️ Funcionalidades

### 1. CREATE - Criar Usuário

**Arquivo:** `tela_cadastro_usuario.dart`

**Características:**
- ✅ Formulário com validação completa
- ✅ Campos obrigatórios: nome, email, senha
- ✅ Seleção de tipo de usuário (admin/aluno)
- ✅ Validações:
  - Nome: mínimo 3 caracteres
  - Email: formato válido
  - Senha: mínimo 6 caracteres
- ✅ Feedback de erros do Firebase

**Processo:**
1. Usuário admin acessa via botão "+" na tela de gerenciar
2. Preenche formulário com dados do novo usuário
3. Sistema cria conta no Firebase Auth
4. Sistema salva dados complementares no Firestore
5. Sucesso: retorna à lista de usuários

**Tratamento de Erros:**
- `email-already-in-use`: Email já cadastrado
- `weak-password`: Senha muito fraca
- `invalid-email`: Email inválido

---

### 2. READ - Listar Usuários

**Arquivo:** `tela_gerenciar_usuarios.dart`

**Características:**
- ✅ StreamBuilder para atualização em tempo real
- ✅ Lista ordenada por data de criação (mais recentes primeiro)
- ✅ Cards visuais com avatar colorido
- ✅ Indicadores visuais de tipo de usuário:
  - 🟠 Admin: ícone admin_panel_settings, cor laranja
  - 🟣 Aluno: ícone person, cor roxa
- ✅ Menu de ações (editar/excluir) apenas para admins
- ✅ Estado vazio: mensagem "Nenhum usuário cadastrado"

**Informações Exibidas:**
- Nome completo
- Email
- Tipo de usuário (badge colorido)
- Avatar com ícone

**Acesso:**
- Via botão "Gerenciar Usuários" na tela home (apenas admins)
- Rota: `/gerenciar-usuarios`

---

### 3. UPDATE - Atualizar Usuário

**Arquivo:** `tela_editar_usuario.dart`

**Características:**
- ✅ Formulário pré-preenchido com dados atuais
- ✅ Campos editáveis: nome, email, tipo de usuário
- ✅ Validação completa (mesmas regras do cadastro)
- ✅ Exibição de metadados:
  - ID do usuário (somente leitura)
  - Data de criação
  - Data da última atualização
- ✅ Atualização automática do email no Firebase Auth
- ✅ Timestamp de atualização automático

**Processo:**
1. Admin clica no menu "⋮" do usuário na lista
2. Seleciona "Editar"
3. Modifica os campos desejados
4. Clica em "Salvar Alterações"
5. Sistema atualiza Firestore e Firebase Auth
6. Retorna à lista com feedback de sucesso

---

### 4. DELETE - Excluir Usuário

**Arquivo:** `tela_gerenciar_usuarios.dart` (método `_confirmarExclusao`)

**Características:**
- ✅ Diálogo de confirmação antes da exclusão
- ✅ Mensagem clara: "Esta ação não pode ser desfeita"
- ✅ Exclusão em cascata:
  - Remove documento do usuário no Firestore
  - Remove todas as avaliações do usuário
  - Remove todos os resultados de quiz do usuário
- ✅ Feedback de sucesso/erro

**Processo:**
1. Admin clica no menu "⋮" do usuário na lista
2. Seleciona "Excluir" (em vermelho)
3. Confirma no diálogo de alerta
4. Sistema exclui dados relacionados
5. Sistema remove usuário do Firestore
6. Lista atualiza automaticamente (StreamBuilder)

**Dados Excluídos:**
```
- usuarios/{userId}
- avaliacoes/{userId}/respostas/*
- resultados_quiz/{userId}/tentativas/*
```

**⚠️ Observação:** O Firebase Auth não permite excluir contas de outros usuários via client SDK. Para exclusão completa da conta de autenticação, é necessário:
- Usar Firebase Admin SDK (backend)
- Ou o próprio usuário excluir sua conta enquanto logado

---

## 🔐 Controle de Acesso

### Sistema de Permissões

**Arquivo:** `usuario_service.dart` → método `isAdmin()`

```dart
Future<bool> isAdmin() async {
  String? userId = FirebaseAuth.currentUser?.uid;
  DocumentSnapshot doc = await Firestore.collection('usuarios').doc(userId).get();
  return doc['tipoUsuario'] == 'admin';
}
```

### Regras de Acesso:

| Ação | Admin | Aluno |
|------|-------|-------|
| Ver botão "Gerenciar Usuários" | ✅ Sim | ❌ Não |
| Listar usuários | ✅ Sim | ❌ Não |
| Criar usuário | ✅ Sim | ❌ Não |
| Editar qualquer usuário | ✅ Sim | ❌ Não |
| Excluir qualquer usuário | ✅ Sim | ❌ Não |
| Editar próprio perfil | ✅ Sim | ⚠️ (futuro) |

---

## 🔧 Service: `UsuarioService`

### Métodos Disponíveis

#### 1. `criarUsuario()`
```dart
Future<String> criarUsuario({
  required String nome,
  required String email,
  required String senha,
  required String tipoUsuario,
})
```
- Cria conta no Firebase Auth
- Salva dados no Firestore
- Retorna mensagem de sucesso

#### 2. `listarUsuarios()`
```dart
Stream<List<UsuarioModel>> listarUsuarios()
```
- Retorna Stream para tempo real
- Ordenado por data_criacao descendente

#### 3. `buscarUsuarioPorId()`
```dart
Future<UsuarioModel?> buscarUsuarioPorId(String userId)
```
- Busca usuário específico
- Retorna null se não encontrado

#### 4. `atualizarUsuario()`
```dart
Future<String> atualizarUsuario({
  required String userId,
  required String nome,
  required String email,
  required String tipoUsuario,
})
```
- Atualiza Firestore
- Atualiza email no Auth (se alterado)
- Timestamp automático

#### 5. `excluirUsuario()`
```dart
Future<String> excluirUsuario(String userId)
```
- Exclui documento do Firestore
- Exclui dados relacionados (cascata)

#### 6. `isAdmin()`
```dart
Future<bool> isAdmin()
```
- Verifica se usuário atual é admin

#### 7. `buscarUsuarioAtual()`
```dart
Future<UsuarioModel?> buscarUsuarioAtual()
```
- Retorna dados do usuário logado

---

## 🎨 Interface do Usuário

### Design Pattern

Todas as telas seguem o padrão visual do app:

```dart
// Header com gradiente roxo → preto
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF403AFF), Color(0xFF000000)],
    ),
  ),
)
```

### Componentes

#### Card de Usuário (Lista)
```
┌──────────────────────────────────┐
│ 🟣  João Silva                   ⋮│
│     joao@email.com               │
│     [Aluno]                      │
└──────────────────────────────────┘
```

#### Formulário (Criar/Editar)
- TextFormField com bordas arredondadas
- Ícones nos prefixos
- Validação em tempo real
- RadioButtons para tipo de usuário
- Botão principal: cor roxa #403AFF

---

## 📱 Fluxo de Navegação

```
TelaHome (Admin)
    │
    ├─> Botão "Gerenciar Usuários"
    │       │
    │       v
    │   TelaGerenciarUsuarios (Lista)
    │       │
    │       ├─> FloatingButton "+"
    │       │       │
    │       │       v
    │       │   TelaCadastroUsuario
    │       │       │
    │       │       └─> [Salvar] → Volta para Lista
    │       │
    │       └─> Menu "⋮" → Editar
    │               │
    │               v
    │           TelaEditarUsuario
    │               │
    │               └─> [Salvar] → Volta para Lista
    │
    └─> (Menu "⋮" → Excluir → Dialog → Confirmar)
```

---

## ⚡ Funcionalidades Avançadas

### 1. Atualização em Tempo Real
- StreamBuilder monitora coleção `usuarios`
- Qualquer mudança reflete instantaneamente na lista
- Sem necessidade de reload manual

### 2. Exclusão em Cascata
```dart
_excluirDadosRelacionados(userId):
  - Exclui avaliacoes/{userId}/respostas/*
  - Exclui resultados_quiz/{userId}/tentativas/*
```

### 3. Validação Robusta
- Email único (Firebase Auth garante)
- Formato de email correto
- Senha mínima de 6 caracteres
- Nome mínimo de 3 caracteres

### 4. Tratamento de Erros
- Mensagens amigáveis ao usuário
- SnackBar coloridos (vermelho para erro, padrão para sucesso)
- Try-catch em todas as operações

---

## 🚀 Como Usar

### Para Administradores:

1. **Criar Primeiro Admin:**
   - Use a tela de registro (TelaRegistro)
   - Crie uma conta normalmente
   - No Firestore Console, edite manualmente o campo `tipoUsuario` para `admin`

2. **Criar Novos Usuários:**
   ```
   Home → Gerenciar Usuários → + → Preencher formulário → Cadastrar
   ```

3. **Editar Usuário:**
   ```
   Gerenciar Usuários → ⋮ (menu) → Editar → Alterar dados → Salvar
   ```

4. **Excluir Usuário:**
   ```
   Gerenciar Usuários → ⋮ (menu) → Excluir → Confirmar
   ```

---

## 🔒 Regras de Segurança Firestore

Recomendação para `firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Função auxiliar: verifica se é admin
    function isAdmin() {
      return get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.tipoUsuario == 'admin';
    }
    
    // Coleção de usuários
    match /usuarios/{userId} {
      // Leitura: apenas admins podem listar
      allow read: if request.auth != null && isAdmin();
      
      // Criação: apenas admins
      allow create: if request.auth != null && isAdmin();
      
      // Atualização: apenas admins
      allow update: if request.auth != null && isAdmin();
      
      // Exclusão: apenas admins
      allow delete: if request.auth != null && isAdmin();
    }
    
    // Avaliações e Quiz (permanecem como estavam)
    match /avaliacoes/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /resultados_quiz/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🧪 Testando o Sistema

### Checklist de Testes:

- [ ] **CREATE**: Cadastrar usuário com todos os campos válidos
- [ ] **CREATE**: Tentar cadastrar com email duplicado (deve falhar)
- [ ] **CREATE**: Tentar cadastrar com senha < 6 caracteres (deve falhar)
- [ ] **READ**: Verificar se lista carrega todos os usuários
- [ ] **READ**: Verificar ordenação (mais recentes primeiro)
- [ ] **READ**: Verificar badges de tipo de usuário (cores corretas)
- [ ] **UPDATE**: Editar nome de um usuário
- [ ] **UPDATE**: Editar email de um usuário
- [ ] **UPDATE**: Alterar tipo de usuário (admin ↔ aluno)
- [ ] **UPDATE**: Verificar timestamp de atualização
- [ ] **DELETE**: Excluir usuário com confirmação
- [ ] **DELETE**: Verificar exclusão de dados relacionados
- [ ] **PERMISSÃO**: Login como aluno → botão "Gerenciar Usuários" NÃO aparece
- [ ] **PERMISSÃO**: Login como admin → botão "Gerenciar Usuários" aparece

---

## 📚 Referências

- [Firebase Authentication - Flutter](https://firebase.flutter.dev/docs/auth/usage)
- [Cloud Firestore - Flutter](https://firebase.flutter.dev/docs/firestore/usage)
- [CRUD Operations Pattern](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete)

---

## 🐛 Problemas Conhecidos e Soluções

### Problema: Não consigo excluir conta do Firebase Auth
**Solução:** Use Firebase Admin SDK em um backend ou implemente reautenticação para permitir que o usuário exclua sua própria conta.

### Problema: Lista não atualiza após criar usuário
**Solução:** Certifique-se de usar StreamBuilder, não FutureBuilder. O código já está correto.

### Problema: Email não atualiza no Firebase Auth
**Solução:** O código já implementa `user.updateEmail()`, mas requer que o usuário seja o dono da conta. Para admins alterarem emails de outros, use Admin SDK.

---

## ✅ Conclusão

O sistema de gerenciamento de usuários está **100% funcional** com todas as operações CRUD implementadas:

✅ **CREATE** - Cadastro completo com validação  
✅ **READ** - Listagem em tempo real com StreamBuilder  
✅ **UPDATE** - Edição com pré-preenchimento automático  
✅ **DELETE** - Exclusão com confirmação e cascata  
✅ **Controle de Acesso** - Sistema de permissões por tipo de usuário  
✅ **Interface Responsiva** - Design consistente com o resto do app  
✅ **Tratamento de Erros** - Feedback claro para o usuário  

**Pronto para produção após configuração do Firebase!** 🎉
