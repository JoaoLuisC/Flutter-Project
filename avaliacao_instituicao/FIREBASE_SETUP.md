# 🔥 Configuração do Firebase - Projeto Avaliação Institucional

## ✅ O que foi feito:

### 1. **Pacotes Instalados**
- ✅ `firebase_core` - Core do Firebase
- ✅ `firebase_auth` - Autenticação
- ✅ `cloud_firestore` - Banco de dados NoSQL

### 2. **Arquivos Criados/Modificados**

#### ✨ Novos Arquivos:
- ✅ `lib/tela_registro.dart` - Tela para criar nova conta
- ✅ `lib/tela_resultados_anteriores.dart` - Exibe histórico de quiz

#### 🔄 Arquivos Modificados:
- ✅ `lib/main.dart` - Inicialização do Firebase + AuthCheck
- ✅ `lib/tela_login.dart` - Login com Firebase Auth
- ✅ `lib/tela_home.dart` - Botão de logout + resultados
- ✅ `lib/tela_formulario_avaliacao.dart` - Salva no Firestore
- ✅ `lib/tela_quiz.dart` - Salva resultados no Firestore

### 3. **Funcionalidades Implementadas**

#### 🔐 Autenticação:
- ✅ Login com email/senha
- ✅ Registro de novos usuários
- ✅ Logout
- ✅ Verificação automática de login (StreamBuilder)

#### 💾 Banco de Dados (Firestore):
- ✅ Salvar avaliações do formulário
- ✅ Salvar resultados do quiz
- ✅ Listar resultados anteriores do usuário

---

## 🚀 PRÓXIMOS PASSOS - Configuração do Firebase

### Passo 1: Criar Projeto no Firebase Console

1. Acesse: https://console.firebase.google.com/
2. Clique em **"Adicionar projeto"**
3. Nome do projeto: `avaliacao-instituicao` (ou outro nome)
4. Desabilite o Google Analytics (opcional)
5. Clique em **"Criar projeto"**

### Passo 2: Configurar Firebase Authentication

1. No Firebase Console, vá em **Authentication**
2. Clique em **"Começar"**
3. Em **"Sign-in method"**, habilite **"Email/Password"**
4. Salve

### Passo 3: Configurar Cloud Firestore

1. No Firebase Console, vá em **Firestore Database**
2. Clique em **"Criar banco de dados"**
3. Escolha **"Iniciar no modo de teste"** (para desenvolvimento)
4. Escolha uma localização (ex: `southamerica-east1`)
5. Clique em **"Ativar"**

### Passo 4: Adicionar o App Web ao Firebase

1. No Firebase Console, clique no ícone **Web** (`</>`)
2. Nome do app: `Avaliação Institucional Web`
3. **Marque a opção** "Configure Firebase Hosting"
4. Clique em **"Registrar app"**
5. **COPIE** as configurações que aparecem (você vai precisar!)

Exemplo do que você vai copiar:
```javascript
const firebaseConfig = {
  apiKey: "AIza...",
  authDomain: "seu-projeto.firebaseapp.com",
  projectId: "seu-projeto",
  storageBucket: "seu-projeto.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abc123"
};
```

### Passo 5: Configurar no Projeto Flutter (Web)

Como você está usando o Flutter Web, precisa adicionar as configurações manualmente:

1. Abra o arquivo: `web/index.html`

2. Encontre a seção `<body>` e **ANTES** da linha `<script src="flutter_bootstrap.js">`, adicione:

```html
<!-- Firebase Configuration -->
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore-compat.js"></script>

<script>
  // Cole aqui suas configurações do Firebase
  const firebaseConfig = {
    apiKey: "SUA_API_KEY_AQUI",
    authDomain: "seu-projeto.firebaseapp.com",
    projectId: "seu-projeto-id",
    storageBucket: "seu-projeto.appspot.com",
    messagingSenderId: "123456789",
    appId: "1:123456789:web:abc123"
  };
  
  // Initialize Firebase
  firebase.initializeApp(firebaseConfig);
</script>
```

### Passo 6: Configurar Regras do Firestore (Segurança)

1. No Firebase Console, vá em **Firestore Database** > **Regras**
2. Substitua as regras por:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir leitura/escrita apenas para usuários autenticados
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Regras específicas para coleções
    match /usuarios/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /avaliacoes/{userId}/respostas/{respostaId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /resultados_quiz/{userId}/tentativas/{tentativaId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

3. Clique em **"Publicar"**

---

## 🧪 Testando o App

### 1. Executar o App

```bash
flutter run -d chrome
```

### 2. Criar uma Conta

1. Na tela de login, clique em **"Não tem uma conta? Registre-se"**
2. Preencha: Nome, Email e Senha
3. Clique em **"Criar Conta"**

### 3. Fazer Login

1. Use o email e senha criados
2. Você será redirecionado para a Home

### 4. Testar Funcionalidades

- ✅ Preencher o Formulário de Avaliação
- ✅ Responder o Quiz
- ✅ Ver Resultados Anteriores
- ✅ Fazer Logout

---

## 📊 Estrutura do Firestore

### Coleções Criadas:

```
firestore/
├── usuarios/
│   └── {userId}/
│       ├── nome
│       ├── email
│       └── data_criacao
│
├── avaliacoes/
│   └── {userId}/
│       └── respostas/
│           └── {respostaId}/
│               ├── genero
│               ├── curso
│               ├── nota_infra
│               ├── feedback
│               └── data_envio
│
└── resultados_quiz/
    └── {userId}/
        └── tentativas/
            └── {tentativaId}/
                ├── acertos
                ├── total_perguntas
                └── data_envio
```

---

## 🐛 Troubleshooting

### Erro: "Firebase not defined"
- Verifique se você adicionou os scripts no `web/index.html`

### Erro: "Missing or insufficient permissions"
- Verifique as regras do Firestore
- Certifique-se de estar logado

### Erro ao fazer login: "invalid-credential"
- Verifique se o email e senha estão corretos
- Verifique se habilitou Email/Password no Authentication

---

## 📱 Próximas Melhorias (Opcional)

- [ ] Adicionar recuperação de senha
- [ ] Adicionar foto de perfil
- [ ] Exportar resultados para PDF
- [ ] Gráficos de desempenho
- [ ] Notificações

---

## 🎉 Pronto!

Seu app agora está totalmente integrado com Firebase! 🚀

Qualquer dúvida, consulte a documentação oficial:
- Firebase: https://firebase.google.com/docs
- FlutterFire: https://firebase.flutter.dev/
