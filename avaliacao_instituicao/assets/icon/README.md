# 🎨 Ícone do Aplicativo

## 📋 Como Criar o Ícone

### Requisitos:
- Imagem quadrada de alta resolução (recomendado: 1024x1024 pixels)
- Formato PNG com fundo transparente ou colorido
- Nome do arquivo: `app_icon.png`

---

## 🎨 Sugestões de Design

### Opção 1: Design Minimalista
```
Fundo: Gradiente roxo (#403AFF) → preto (#000000)
Elemento central: Ícone de estrela ⭐ + documento 📝
Bordas: Arredondadas
Estilo: Flat design
```

### Opção 2: Design com Letras
```
Fundo: Roxo sólido (#403AFF)
Texto: "AI" (Avaliação Institucional)
Fonte: Bold, Sans-serif
Cor do texto: Branco
```

### Opção 3: Design com Ícones
```
Fundo: Gradiente como tela de login
Ícones: 📋 (formulário) + ✓ (check)
Círculo branco ao redor
Sombra suave
```

---

## 🛠️ Ferramentas Recomendadas

### Gratuitas Online:
1. **Icon Kitchen** - https://icon.kitchen/
   - Upload sua imagem
   - Gera para todas as plataformas automaticamente
   
2. **Canva** - https://www.canva.com/
   - Templates prontos
   - Editor visual fácil
   
3. **Figma** - https://www.figma.com/
   - Profissional e gratuito
   - Colaboração em tempo real

### Desktop:
- GIMP (gratuito)
- Adobe Photoshop
- Adobe Illustrator
- Inkscape (gratuito)

---

## 📐 Especificações Técnicas

### Tamanhos Necessários (gerados automaticamente):

**Android:**
- 192x192 (xxxhdpi)
- 144x144 (xxhdpi)
- 96x96 (xhdpi)
- 72x72 (hdpi)
- 48x48 (mdpi)

**iOS:**
- 1024x1024 (App Store)
- 180x180 (iPhone)
- 167x167 (iPad Pro)
- 152x152 (iPad)
- 120x120 (iPhone)
- 87x87
- 80x80
- 76x76
- 60x60
- 58x58
- 40x40
- 29x29
- 20x20

**Web:**
- 512x512
- 192x192
- 32x32 (favicon)

**Windows:**
- 256x256
- 128x128
- 64x64
- 48x48
- 32x32
- 16x16

---

## 📝 Passo a Passo

### 1. Criar o Ícone
Escolha uma das opções acima e crie sua imagem em 1024x1024 pixels.

### 2. Salvar Neste Diretório
Salve o arquivo como `app_icon.png` nesta pasta:
```
avaliacao_instituicao/assets/icon/app_icon.png
```

### 3. Gerar Ícones para Todas as Plataformas

Abra o terminal no diretório do projeto e execute:

```powershell
# Instalar/atualizar dependências
flutter pub get

# Gerar ícones
flutter pub run flutter_launcher_icons
```

### 4. Verificar Resultado

Os ícones serão gerados nos seguintes locais:
- Android: `android/app/src/main/res/mipmap-*/`
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Web: `web/icons/`
- Windows: `windows/runner/resources/`

### 5. Testar

Execute o app para ver o novo ícone:

```powershell
flutter run -d chrome
```

---

## 🎨 Template Rápido (CSS/SVG)

Se quiser criar um ícone simples programaticamente, aqui está um exemplo SVG:

```svg
<svg width="1024" height="1024" xmlns="http://www.w3.org/2000/svg">
  <!-- Fundo com gradiente -->
  <defs>
    <linearGradient id="grad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#403AFF;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#000000;stop-opacity:1" />
    </linearGradient>
  </defs>
  
  <rect width="1024" height="1024" rx="180" fill="url(#grad)"/>
  
  <!-- Ícone de estrela -->
  <text x="512" y="650" 
        font-family="Arial" 
        font-size="400" 
        fill="white" 
        text-anchor="middle">⭐</text>
  
  <!-- Texto AI -->
  <text x="512" y="400" 
        font-family="Arial, sans-serif" 
        font-size="280" 
        font-weight="bold"
        fill="white" 
        text-anchor="middle">AI</text>
</svg>
```

Salve como `icon.svg`, abra em navegador e tire screenshot, ou converta para PNG usando ferramentas online.

---

## ⚠️ Dicas Importantes

### ✅ Fazer:
- Usar cores contrastantes
- Manter design simples e reconhecível
- Testar em diferentes tamanhos
- Usar ícones vetoriais quando possível
- Manter proporções quadradas

### ❌ Evitar:
- Texto muito pequeno (ilegível em 48x48)
- Muitos detalhes (se perdem em tamanhos pequenos)
- Bordas muito finas
- Cores muito similares
- Imagens com baixa resolução

---

## 🔄 Atualizar Ícone

Se já tiver gerado uma vez e quiser atualizar:

1. Substitua `app_icon.png` pelo novo arquivo
2. Execute novamente:
```powershell
flutter pub run flutter_launcher_icons
```
3. Limpe o build:
```powershell
flutter clean
flutter pub get
```
4. Execute o app:
```powershell
flutter run
```

---

## 📚 Recursos Adicionais

### Paleta de Cores do App:
- Roxo Principal: `#403AFF`
- Preto: `#000000`
- Branco: `#FFFFFF`
- Laranja (Admin): `#FF9800`

### Inspiração:
- Google Material Icons
- Apple SF Symbols
- Flaticon
- Icons8

---

## 🎯 Exemplo Prático

Se não quiser criar um ícone complexo agora, use este simples:

1. Acesse: https://icon.kitchen/
2. Escolha "Text Icon"
3. Digite: "AI" ou "📝"
4. Cor de fundo: `#403AFF`
5. Baixe como PNG 1024x1024
6. Salve como `app_icon.png` nesta pasta
7. Execute `flutter pub run flutter_launcher_icons`

**Pronto! Ícone criado em 2 minutos!** ✨

---

## 📧 Suporte

Se tiver problemas:
1. Verifique se o arquivo está em `assets/icon/app_icon.png`
2. Confirme que é PNG e quadrado
3. Execute `flutter clean` antes de regenerar
4. Consulte: https://pub.dev/packages/flutter_launcher_icons
