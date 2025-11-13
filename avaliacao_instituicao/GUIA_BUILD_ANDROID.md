# Guia: Buildar App Flutter no Android

## Opção 1: Instalar no Celular (USB)

### 1. Preparar o Celular
```
1. Ativar Modo Desenvolvedor:
   - Configurações → Sobre o telefone
   - Tocar 7x em "Número da versão"

2. Ativar Depuração USB:
   - Configurações → Opções do desenvolvedor
   - Ativar "Depuração USB"

3. Conectar USB no PC
   - Aceitar permissão no celular
```

### 2. Verificar Conexão
```bash
flutter devices
```
Deve aparecer seu celular na lista.

### 3. Rodar no Celular (Debug)
```bash
cd "c:\Users\marci\Documents\joao luis\Flutter-Project\avaliacao_instituicao"
flutter run
```
O Flutter vai detectar seu celular automaticamente.

### 4. Instalar APK (Release)
```bash
# Gerar APK de produção
flutter build apk --release

# Localização do APK:
# build\app\outputs\flutter-apk\app-release.apk
```

Copie o APK para o celular e instale manualmente.

---

## Opção 2: Gerar APK sem Celular Conectado

### 1. Build do APK
```bash
cd "c:\Users\marci\Documents\joao luis\Flutter-Project\avaliacao_instituicao"
flutter build apk --release
```

### 2. APK Gerado em:
```
build\app\outputs\flutter-apk\app-release.apk
```

### 3. Transferir APK
- Via cabo USB
- Via email/WhatsApp
- Via Google Drive

### 4. Instalar no Celular
- Abrir arquivo APK no celular
- Permitir "Fontes desconhecidas" se necessário
- Instalar

---

## Opção 3: App Bundle (Google Play Store)

### 1. Gerar App Bundle
```bash
flutter build appbundle --release
```

### 2. Bundle Gerado em:
```
build\app\outputs\bundle\release\app-release.aab
```

### 3. Publicar
Fazer upload do `.aab` no Google Play Console.

---

## Troubleshooting

### Celular não aparece?
```bash
# Windows - Instalar driver ADB
# Baixar: https://developer.android.com/studio/run/win-usb

# Verificar ADB
flutter doctor

# Reiniciar ADB
adb kill-server
adb start-server
flutter devices
```

### Erro de assinatura?
Para produção, você precisa criar uma keystore:
```bash
keytool -genkey -v -keystore c:\Users\marci\my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
```

---

## Comandos Úteis

```bash
# Ver dispositivos
flutter devices

# Rodar em dispositivo específico
flutter run -d <device-id>

# Limpar build
flutter clean

# Ver logs
flutter logs

# Build para diferentes arquiteturas
flutter build apk --release --split-per-abi
```

---

## Tamanhos de Build

- **Debug APK**: ~50-100 MB
- **Release APK**: ~15-30 MB
- **App Bundle**: ~15-25 MB (Google Play otimiza por dispositivo)
