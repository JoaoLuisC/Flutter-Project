# 🧪 Guia de Testes - Integração API de Pokémons

## 📋 Preparação para Testes

### Pré-requisitos:
- ✅ Flutter instalado e configurado
- ✅ Dependências instaladas (`flutter pub get`)
- ✅ Conexão com internet ativa
- ✅ Firebase configurado (opcional para teste da API)

---

## 🎯 Teste 1: Verificar Modelo de Dados

### Objetivo:
Testar se o `PokemonModel` está corretamente estruturado.

### Passos:
1. Abra o arquivo: `lib/models/pokemon_model.dart`
2. Verifique se possui todos os campos necessários
3. Confirme método `fromJson()` presente

### Resultado Esperado:
✅ Modelo com 11 campos (number, name, type, total, hp, attack, defense, spAtk, spDef, speed, imageUrl)

---

## 🎯 Teste 2: Serviço de API

### Objetivo:
Testar requisição HTTP para a API de Pokémons.

### Teste Manual via Navegador:
1. Abra: https://www.canalti.com.br/api/pokemons.json
2. Verifique se carrega um JSON com lista de Pokémons
3. Confirme estrutura dos dados

### Resultado Esperado:
```json
[
  {
    "Number": 1,
    "Name": "Bulbasaur",
    "Type": ["Grass", "Poison"],
    "Total": 318,
    "HP": 45,
    ...
  },
  ...
]
```

---

## 🎯 Teste 3: Integração no App

### Cenário A - Pontuação Alta (≥90%)

#### Passos:
1. Execute o app: `flutter run -d chrome`
2. Faça login (ou crie conta)
3. Navegue para "Quiz de conhecimento"
4. Responda 9 ou 10 perguntas corretamente
5. Clique em "Enviar Quiz"

#### Resultado Esperado:
- ✅ Loading aparece durante requisição
- ✅ Tela de Pokémons abre automaticamente
- ✅ Exibe mensagem: "🏆 Excelente! Você é um Mestre Pokémon!"
- ✅ Mostra 10 Pokémons mais fortes
- ✅ Cards coloridos por tipo
- ✅ Imagens dos Pokémons aparecem

### Cenário B - Pontuação Média (70-89%)

#### Passos:
1. Responda 7-8 perguntas corretamente
2. Envie o quiz

#### Resultado Esperado:
- ✅ Mensagem: "⭐ Muito Bem! Continue treinando!"
- ✅ Exibe 8 Pokémons aleatórios

### Cenário C - Pontuação Baixa (50-69%)

#### Passos:
1. Responda 5-6 perguntas corretamente
2. Envie o quiz

#### Resultado Esperado:
- ✅ Mensagem: "👍 Bom trabalho! Você está evoluindo!"
- ✅ Exibe 6 Pokémons aleatórios

### Cenário D - Pontuação Muito Baixa (<50%)

#### Passos:
1. Responda 0-4 perguntas corretamente
2. Envie o quiz

#### Resultado Esperado:
- ✅ Mensagem: "💪 Continue se esforçando! Todo mestre começou assim!"
- ✅ Exibe 4 Pokémons aleatórios

---

## 🎯 Teste 4: Tratamento de Erros

### Cenário E - Sem Internet

#### Passos:
1. Desconecte a internet
2. Responda o quiz e envie

#### Resultado Esperado:
- ✅ Loading aparece
- ✅ Após timeout, exibe mensagem de erro
- ✅ Botão "Tentar Novamente" disponível
- ✅ Ao reconectar e clicar, carrega os Pokémons

### Cenário F - API Indisponível

#### Simulação:
1. Temporariamente mude a URL da API para inválida
2. Execute o teste

#### Resultado Esperado:
- ✅ Erro capturado
- ✅ Mensagem amigável exibida
- ✅ Opção de retry

---

## 🎯 Teste 5: Interface Visual

### Checklist de Elementos:

#### Header:
- [ ] Gradiente roxo → preto presente
- [ ] Título "Resultado do Quiz"
- [ ] Pontuação exibida corretamente (ex: "8 / 10")
- [ ] Mensagem motivacional apropriada

#### Grid de Pokémons:
- [ ] 2 colunas no layout
- [ ] Cards com bordas arredondadas
- [ ] Cores diferentes por tipo de Pokémon
- [ ] Imagens carregam corretamente
- [ ] Fallback (ícone) funciona se imagem falhar

#### Card Individual:
- [ ] Número do Pokémon (ex: #001)
- [ ] Nome do Pokémon
- [ ] Tipos (badges coloridos)
- [ ] Stats: Total, HP, Attack

#### Botão Voltar:
- [ ] Presente no final da página
- [ ] Largura total
- [ ] Retorna para home ao clicar

---

## 🎯 Teste 6: Performance

### Métricas:

#### Tempo de Carregamento:
1. Iniciar cronômetro ao enviar quiz
2. Parar quando Pokémons aparecerem

**Tempo Esperado:** < 3 segundos (depende da internet)

#### Fluidez:
- [ ] Scroll suave no grid
- [ ] Sem travamentos
- [ ] Imagens carregam progressivamente

---

## 🎯 Teste 7: Cores por Tipo

Verifique se cada tipo tem cor apropriada:

| Tipo | Cor Esperada | Hex |
|------|-------------|-----|
| Grass | Verde | #78C850 |
| Fire | Vermelho/Laranja | #F08030 |
| Water | Azul | #6890F0 |
| Electric | Amarelo | #F8D030 |
| Psychic | Rosa | #F85888 |
| Ice | Ciano | #98D8D8 |
| Dragon | Roxo escuro | #7038F8 |
| Dark | Marrom | #705848 |
| Fairy | Rosa claro | #EE99AC |
| Normal | Cinza | #A8A878 |

### Teste:
1. Complete quiz com pontuação alta
2. Observe cores dos cards
3. Confirme que correspondem aos tipos

---

## 🎯 Teste 8: Dados Salvos no Firestore

### Verificação:

1. Complete o quiz
2. Abra Firebase Console
3. Navegue para Firestore Database
4. Verifique coleção: `resultados_quiz/{userId}/tentativas`

#### Dados Esperados no Documento:
```javascript
{
  acertos: 8,
  total_perguntas: 10,
  data_envio: Timestamp,
  userId: "xK9mP2nQ..."
}
```

---

## 🎯 Teste 9: Navegação

### Fluxo Completo:

```
Login
  ↓
Home
  ↓
Quiz de conhecimento
  ↓
Responder 10 perguntas
  ↓
Enviar Quiz
  ↓
[API REQUEST] ← NOVO!
  ↓
Tela de Pokémons ← NOVO!
  ↓
Voltar para Home
```

#### Checklist:
- [ ] Todas as transições funcionam
- [ ] Não há navegação quebrada
- [ ] Botão voltar retorna à home
- [ ] Dados persistem no Firestore

---

## 🎯 Teste 10: Responsividade

### Desktop (Chrome):
- [ ] Grid 2 colunas
- [ ] Cards bem dimensionados
- [ ] Imagens nítidas

### Tablet (simulado):
- [ ] Layout adapta
- [ ] Texto legível
- [ ] Botões clicáveis

### Mobile (simulado):
- [ ] Grid mantém 2 colunas
- [ ] Scroll vertical funciona
- [ ] Touch funciona

---

## 📊 Relatório de Teste

### Template:

```
Data: __/__/____
Testador: _____________

✅ Modelo PokemonModel: [ ] OK [ ] FALHOU
✅ API acessível: [ ] OK [ ] FALHOU
✅ Pontuação 90%+: [ ] OK [ ] FALHOU
✅ Pontuação 70-89%: [ ] OK [ ] FALHOU
✅ Pontuação 50-69%: [ ] OK [ ] FALHOU
✅ Pontuação <50%: [ ] OK [ ] FALHOU
✅ Tratamento de erros: [ ] OK [ ] FALHOU
✅ Interface visual: [ ] OK [ ] FALHOU
✅ Performance: [ ] OK [ ] FALHOU
✅ Cores por tipo: [ ] OK [ ] FALHOU
✅ Salvamento Firestore: [ ] OK [ ] FALHOU
✅ Navegação: [ ] OK [ ] FALHOU
✅ Responsividade: [ ] OK [ ] FALHOU

Observações:
_________________________________
_________________________________
_________________________________
```

---

## 🐛 Problemas Conhecidos e Soluções

### Problema: "Failed host lookup"
**Causa:** Sem internet ou URL incorreta
**Solução:** Verificar conexão, testar URL no navegador

### Problema: Imagens não aparecem
**Causa:** URLs inválidas na API
**Solução:** Código já tem fallback para ícone padrão

### Problema: Cards sem cor
**Causa:** Tipo de Pokémon não mapeado
**Solução:** Retorna cor padrão (#A8A878)

### Problema: Loading infinito
**Causa:** Timeout na requisição
**Solução:** Implementar timeout de 10s (já implementado implicitamente)

---

## ✅ Checklist Final de Integração

Antes de apresentar, confirme:

- [ ] API retorna dados corretamente
- [ ] Todos os cenários de pontuação testados
- [ ] Tratamento de erro funciona
- [ ] Interface visual aprovada
- [ ] Performance aceitável (<3s)
- [ ] Cores dos tipos corretas
- [ ] Firestore salva resultados
- [ ] Navegação fluida
- [ ] Responsivo em diferentes tamanhos
- [ ] Sem erros no console

---

## 🎬 Script de Demonstração

### Para Apresentação (1-2 minutos):

```
[1] "Agora vou demonstrar a integração com API externa"

[2] "Responderei o quiz rapidamente" 
    → Responder 9 perguntas corretamente

[3] "Ao enviar, o sistema faz uma requisição HTTP"
    → Clicar em "Enviar Quiz"
    
[4] "A API retorna dados em tempo real"
    → Mostrar loading

[5] "E exibe Pokémons como recompensa visual!"
    → Mostrar tela de Pokémons
    
[6] "A quantidade varia conforme a pontuação"
    → Explicar sistema 90%=10, 70%=8, etc.
    
[7] "Cada card tem informações detalhadas"
    → Scroll pelo grid
    → Apontar: número, nome, tipo, stats
    
[8] "As cores mudam baseadas no tipo do Pokémon"
    → Mostrar cards de tipos diferentes

[9] "E tudo é salvo no Firebase para histórico"
    → Mencionar integração Firestore

[10] "Voltar para home"
     → Clicar em botão voltar
```

**Tempo total:** ~90 segundos

---

## 🎉 Pronto para Testar!

Execute todos os testes acima antes da apresentação para garantir que tudo funcione perfeitamente!

**Boa sorte! 🚀**
