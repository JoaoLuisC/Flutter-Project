// data/quizzes_data.dart
class PerguntaQuizData {
  final String enunciado;
  final List<String> opcoes; // Sempre 4 opções (A, B, C, D)
  final int respostaCorretaIndex;

  PerguntaQuizData({
    required this.enunciado,
    required this.opcoes,
    required this.respostaCorretaIndex,
  });
}

class QuizzesData {
  static Map<String, List<PerguntaQuizData>> getTodasPerguntas() {
    return {
      'banco_dados': _getBancoDadosPerguntas(),
      'flutter': _getFlutterPerguntas(),
      'web': _getWebPerguntas(),
      'git': _getGitPerguntas(),
      'algoritmos': _getAlgoritmosPerguntas(),
    };
  }

  static List<PerguntaQuizData> _getBancoDadosPerguntas() {
    return [
      PerguntaQuizData(
        enunciado: 'O que significa SQL?',
        opcoes: [
          'Structured Query Language',
          'Simple Query Language',
          'System Query Language',
          'Standard Query Language'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Qual comando é usado para criar uma tabela?',
        opcoes: ['CREATE TABLE', 'MAKE TABLE', 'NEW TABLE', 'BUILD TABLE'],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é uma chave primária?',
        opcoes: [
          'Identificador único de um registro',
          'Uma senha do banco',
          'Um tipo de índice',
          'Uma tabela secundária'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Qual banco de dados é NoSQL?',
        opcoes: ['MongoDB', 'MySQL', 'PostgreSQL', 'Oracle'],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é normalização?',
        opcoes: [
          'Organizar dados para reduzir redundância',
          'Backup de dados',
          'Encriptação',
          'Compressão de dados'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Qual comando remove registros de uma tabela?',
        opcoes: ['DELETE', 'REMOVE', 'DROP', 'CLEAR'],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é JOIN?',
        opcoes: [
          'Combinar dados de múltiplas tabelas',
          'Criar uma nova tabela',
          'Deletar registros',
          'Atualizar dados'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Qual tipo de dado armazena texto longo?',
        opcoes: ['TEXT', 'INT', 'DATE', 'BOOLEAN'],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que faz o comando SELECT?',
        opcoes: [
          'Consultar dados',
          'Inserir dados',
          'Deletar dados',
          'Criar tabelas'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é uma transação?',
        opcoes: [
          'Conjunto de operações atômicas',
          'Um tipo de tabela',
          'Um banco de dados',
          'Uma consulta complexa'
        ],
        respostaCorretaIndex: 0,
      ),
    ];
  }

  static List<PerguntaQuizData> _getFlutterPerguntas() {
    return [
      PerguntaQuizData(
        enunciado: 'Qual linguagem o Flutter usa?',
        opcoes: ['Dart', 'JavaScript', 'Kotlin', 'Swift'],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é um Widget no Flutter?',
        opcoes: [
          'Elemento visual da UI',
          'Um tipo de variável',
          'Um servidor',
          'Um banco de dados'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'StatefulWidget serve para?',
        opcoes: [
          'Widgets com estado mutável',
          'Widgets estáticos',
          'Animações apenas',
          'Layouts fixos'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Qual comando cria um novo projeto Flutter?',
        opcoes: ['flutter create', 'flutter new', 'flutter init', 'flutter start'],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é Hot Reload?',
        opcoes: [
          'Recarregar código sem reiniciar',
          'Compilar para produção',
          'Debugar erros',
          'Instalar dependências'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Qual widget organiza filhos em coluna?',
        opcoes: ['Column', 'Row', 'Stack', 'Grid'],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é pubspec.yaml?',
        opcoes: [
          'Arquivo de configuração do projeto',
          'Um widget',
          'Uma classe',
          'Um banco de dados'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'BuildContext serve para?',
        opcoes: [
          'Acessar informações da árvore de widgets',
          'Compilar o app',
          'Criar animações',
          'Gerenciar estado'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é setState()?',
        opcoes: [
          'Atualiza o estado do widget',
          'Cria um novo widget',
          'Deleta um widget',
          'Compila o código'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Qual plataforma Flutter NÃO suporta nativamente?',
        opcoes: ['PlayStation', 'Android', 'iOS', 'Web'],
        respostaCorretaIndex: 0,
      ),
    ];
  }

  static List<PerguntaQuizData> _getWebPerguntas() {
    return [
      PerguntaQuizData(
        enunciado: 'O que significa HTML?',
        opcoes: [
          'HyperText Markup Language',
          'High Tech Modern Language',
          'Home Tool Markup Language',
          'Hyper Transfer Markup Language'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Qual propriedade CSS altera a cor do texto?',
        opcoes: ['color', 'text-color', 'font-color', 'text-style'],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é JavaScript?',
        opcoes: [
          'Linguagem de programação para web',
          'Um framework CSS',
          'Um banco de dados',
          'Um editor de texto'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é React?',
        opcoes: [
          'Biblioteca JavaScript para UI',
          'Linguagem de programação',
          'Banco de dados',
          'Sistema operacional'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Para que serve a tag <div>?',
        opcoes: [
          'Container genérico',
          'Criar links',
          'Inserir imagens',
          'Fazer tabelas'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é CSS?',
        opcoes: [
          'Cascading Style Sheets',
          'Computer Style System',
          'Creative Style Sheets',
          'Code Style Standard'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Qual tag cria um link?',
        opcoes: ['<a>', '<link>', '<href>', '<url>'],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é DOM?',
        opcoes: [
          'Document Object Model',
          'Data Object Manager',
          'Digital Output Method',
          'Dynamic Object Model'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Qual método seleciona um elemento por ID?',
        opcoes: [
          'getElementById()',
          'selectById()',
          'getElement()',
          'findId()'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é responsividade?',
        opcoes: [
          'Adaptar layout a diferentes telas',
          'Velocidade do site',
          'Segurança do código',
          'Quantidade de usuários'
        ],
        respostaCorretaIndex: 0,
      ),
    ];
  }

  static List<PerguntaQuizData> _getGitPerguntas() {
    return [
      PerguntaQuizData(
        enunciado: 'O que faz o comando "git init"?',
        opcoes: [
          'Inicializa um repositório Git',
          'Faz commit',
          'Cria uma branch',
          'Deleta arquivos'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Como ver o histórico de commits?',
        opcoes: ['git log', 'git history', 'git show', 'git list'],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é uma branch?',
        opcoes: [
          'Ramificação do código',
          'Um tipo de commit',
          'Um servidor',
          'Um arquivo'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Como desfazer o último commit?',
        opcoes: ['git reset HEAD~1', 'git undo', 'git remove', 'git delete'],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que faz "git clone"?',
        opcoes: [
          'Copia um repositório remoto',
          'Cria um backup',
          'Deleta um repositório',
          'Renomeia arquivos'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Qual comando adiciona arquivos ao stage?',
        opcoes: ['git add', 'git stage', 'git include', 'git append'],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é merge?',
        opcoes: [
          'Unir branches',
          'Deletar branch',
          'Criar commit',
          'Ver histórico'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Como criar uma nova branch?',
        opcoes: [
          'git branch nome',
          'git create nome',
          'git new nome',
          'git make nome'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que faz "git push"?',
        opcoes: [
          'Envia commits para remoto',
          'Baixa commits',
          'Cria branch',
          'Deleta arquivos'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é um conflito de merge?',
        opcoes: [
          'Mudanças incompatíveis em branches',
          'Erro de sintaxe',
          'Arquivo deletado',
          'Branch inexistente'
        ],
        respostaCorretaIndex: 0,
      ),
    ];
  }

  static List<PerguntaQuizData> _getAlgoritmosPerguntas() {
    return [
      PerguntaQuizData(
        enunciado: 'O que é um array?',
        opcoes: [
          'Estrutura de dados indexada',
          'Um tipo de loop',
          'Uma função',
          'Uma variável booleana'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Qual estrutura é LIFO (Last In, First Out)?',
        opcoes: ['Pilha (Stack)', 'Fila (Queue)', 'Lista', 'Árvore'],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é recursão?',
        opcoes: [
          'Função que chama a si mesma',
          'Um tipo de loop',
          'Uma variável global',
          'Um array'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Complexidade O(n) significa?',
        opcoes: ['Linear', 'Constante', 'Exponencial', 'Logarítmica'],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é Binary Search?',
        opcoes: [
          'Busca binária em lista ordenada',
          'Busca em árvore',
          'Ordenação',
          'Busca linear'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Qual estrutura é FIFO?',
        opcoes: ['Fila (Queue)', 'Pilha (Stack)', 'Árvore', 'Grafo'],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é Big O notation?',
        opcoes: [
          'Medir complexidade de algoritmos',
          'Um tipo de variável',
          'Uma estrutura de dados',
          'Um padrão de projeto'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Bubble Sort é um algoritmo de?',
        opcoes: ['Ordenação', 'Busca', 'Inserção', 'Remoção'],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'O que é uma lista encadeada?',
        opcoes: [
          'Elementos ligados por ponteiros',
          'Array ordenado',
          'Pilha invertida',
          'Fila circular'
        ],
        respostaCorretaIndex: 0,
      ),
      PerguntaQuizData(
        enunciado: 'Qual a complexidade de busca em array não ordenado?',
        opcoes: ['O(n)', 'O(1)', 'O(log n)', 'O(n²)'],
        respostaCorretaIndex: 0,
      ),
    ];
  }
}
