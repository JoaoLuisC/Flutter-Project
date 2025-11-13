# Guia Completo: Configurar Android para Flutter

## Passo 1: Instalar Android Studio

### Download
1. Acesse: https://developer.android.com/studio
2. Baixe o instalador (cerca de 1 GB)
3. Execute o arquivo `.exe`

### Instalação
1. Clique "Next" em todas as telas
2. **MARQUE:** "Android SDK"
3. **MARQUE:** "Android Virtual Device (AVD)"
4. Escolha local de instalação (padrão: C:\Program Files\Android\Android Studio)
5. Aguarde instalação (~10-20 minutos)

### Primeira Execução
1. Abra Android Studio
2. Escolha "Standard Installation"
3. Aceite licenças
4. Aguarde download dos componentes (~3-4 GB)

---

## Passo 2: Configurar SDK no Flutter

Após instalar Android Studio, execute:

```powershell
# Verificar configuração
flutter doctor --android-licenses

# Aceitar todas as licenças (digite 'y' para cada uma)
```

Se o caminho do SDK não for detectado automaticamente:

```powershell
# Configurar manualmente (ajuste o caminho se necessário)
flutter config --android-sdk "C:\Users\marci\AppData\Local\Android\Sdk"
```

---

## Passo 3: Conectar Celular via USB

### No Celular:
1. **Ativar Modo Desenvolvedor:**
   - Configurações → Sobre o telefone
   - Tocar 7x em "Número da versão"
   - Vai aparecer "Você é um desenvolvedor!"

2. **Ativar Depuração USB:**
   - Configurações → Sistema → Opções do desenvolvedor
   - Ativar "Depuração USB"
   - (Opcional) Ativar "Instalar via USB"

3. **Conectar ao PC:**
   - Conecte o cabo USB
   - Aceite a permissão de depuração que aparecer no celular
   - Marque "Sempre permitir deste computador"

### No PC:
```powershell
# Verificar se o celular está conectado
flutter devices
```

Deve aparecer algo como:
```
Found 4 connected devices:
  SM-G973F (mobile) • ABC123DEF • android-arm64 • Android 13
  Windows (desktop) • windows • windows-x64 • Microsoft Windows
  Chrome (web) • chrome • web-javascript • Google Chrome
  Edge (web) • edge • web-javascript • Microsoft Edge
```

---

## Passo 4: Rodar no Celular

```powershell
cd "c:\Users\marci\Documents\joao luis\Flutter-Project\avaliacao_instituicao"
flutter run
```

O Flutter vai compilar e instalar o app no seu celular automaticamente.

---

## Alternativa: Gerar APK sem Celular Conectado

Se você quiser apenas gerar o APK para instalar manualmente:

```powershell
# Gerar APK release
flutter build apk --release

# APK gerado em:
# build\app\outputs\flutter-apk\app-release.apk
```

Copie o arquivo para o celular e instale manualmente.

---

## Troubleshooting

### "Unable to locate Android SDK"
```powershell
# Encontrar o SDK
dir "C:\Users\marci\AppData\Local\Android\Sdk"

# Se existir, configurar:
flutter config --android-sdk "C:\Users\marci\AppData\Local\Android\Sdk"

# Se não existir, abra Android Studio:
# Tools → SDK Manager → Install
```

### "Celular não aparece em flutter devices"
```powershell
# Instalar drivers ADB (Windows)
# 1. Baixe: https://developer.android.com/studio/run/win-usb
# 2. Instale o driver do fabricante do seu celular

# Reiniciar ADB
adb kill-server
adb start-server
adb devices

# Verificar novamente
flutter devices
```

### "Android license status unknown"
```powershell
flutter doctor --android-licenses
# Digite 'y' para aceitar todas as licenças
```

### Erro de compilação?
```powershell
# Limpar cache e rebuildar
flutter clean
flutter pub get
flutter run
```

---

## Verificação Final

Após instalar tudo, execute:

```powershell
flutter doctor -v
```

Deve mostrar:
- ✓ Flutter
- ✓ Android toolchain
- ✓ Chrome
- ✓ Connected device

---

## Comandos Úteis

```powershell
# Ver dispositivos conectados
flutter devices

# Rodar em dispositivo específico
flutter run -d <device-id>

# Ver logs do app
flutter logs

# Hot reload (enquanto app está rodando)
# Aperte 'r' no terminal

# Hot restart (recarregar completo)
# Aperte 'R' no terminal

# Parar o app
# Aperte 'q' no terminal
```

---

## Tempo Estimado

- Download Android Studio: 5-10 min (depende da internet)
- Instalação Android Studio: 10-20 min
- Download SDK e componentes: 15-30 min
- Configuração Flutter: 2-5 min
- **Total: ~45-60 minutos**

Depois de configurado uma vez, você poderá usar sempre!
