// tela_resultados_anteriores.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaResultadosAnteriores extends StatefulWidget {
  const TelaResultadosAnteriores({super.key});

  @override
  State<TelaResultadosAnteriores> createState() => _TelaResultadosAnterioresState();
}

class _TelaResultadosAnterioresState extends State<TelaResultadosAnteriores> {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> _resultados = [];
  bool _isLoading = true;
  String _ordenacao = 'data_recente'; // data_recente, data_antiga, maior_pontuacao, menor_pontuacao

  @override
  void initState() {
    super.initState();
    _carregarResultados();
  }

  Future<void> _carregarResultados() async {
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Buscar resultados de quizzes
      final quizzesSnapshot = await FirebaseFirestore.instance
          .collection('resultados_quiz')
          .doc(userId!)
          .collection('tentativas')
          .get();

      // Buscar pokémons conquistados
      final pokemonsSnapshot = await FirebaseFirestore.instance
          .collection('quiz_resultados')
          .where('userId', isEqualTo: userId)
          .get();

      // Mapear pokémons por timestamp aproximado
      Map<String, Map<String, dynamic>> pokemonsPorData = {};
      for (var doc in pokemonsSnapshot.docs) {
        final data = doc.data();
        if (data['pokemon'] != null && data['data_resposta'] != null) {
          final timestamp = (data['data_resposta'] as Timestamp).toDate();
          final chave = '${timestamp.year}${timestamp.month}${timestamp.day}${timestamp.hour}${timestamp.minute}';
          
          if (!pokemonsPorData.containsKey(chave)) {
            pokemonsPorData[chave] = data['pokemon'];
          }
        }
      }

      List<Map<String, dynamic>> resultados = [];
      for (var doc in quizzesSnapshot.docs) {
        final data = doc.data();
        final dataEnvio = (data['data_envio'] as Timestamp).toDate();
        final chave = '${dataEnvio.year}${dataEnvio.month}${dataEnvio.day}${dataEnvio.hour}${dataEnvio.minute}';
        
        resultados.add({
          'quiz_titulo': data['quiz_titulo'] ?? 'Quiz',
          'quiz_tipo': data['quiz_tipo'] ?? '',
          'acertos': data['acertos'] ?? 0,
          'total_perguntas': data['total_perguntas'] ?? 10,
          'data_envio': dataEnvio,
          'pokemon': pokemonsPorData[chave],
          'pontuacao_perfeita': data['pontuacao_perfeita'] ?? false,
        });
      }

      resultados.sort((a, b) => b['data_envio'].compareTo(a['data_envio']));

      setState(() {
        _resultados = resultados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _aplicarOrdenacao() {
    switch (_ordenacao) {
      case 'data_recente':
        _resultados.sort((a, b) => b['data_envio'].compareTo(a['data_envio']));
        break;
      case 'data_antiga':
        _resultados.sort((a, b) => a['data_envio'].compareTo(b['data_envio']));
        break;
      case 'maior_pontuacao':
        _resultados.sort((a, b) => b['acertos'].compareTo(a['acertos']));
        break;
      case 'menor_pontuacao':
        _resultados.sort((a, b) => a['acertos'].compareTo(b['acertos']));
        break;
    }
    setState(() {});
  }

  Future<void> _limparTodosResultados() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Histórico'),
        content: const Text('Tem certeza que deseja apagar TODOS os resultados anteriores? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Apagar Tudo'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isLoading = true);

    try {
      // Deletar APENAS os resultados de quizzes (mantém os pokémons)
      final quizzesDocs = await FirebaseFirestore.instance
          .collection('resultados_quiz')
          .doc(userId!)
          .collection('tentativas')
          .get();

      for (var doc in quizzesDocs.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _resultados = [];
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Histórico de quizzes limpo! Pokémons mantidos.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao limpar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getTipoColor(String tipo) {
    final cores = {
      'normal': Colors.grey,
      'fire': Colors.orange,
      'water': Colors.blue,
      'grass': Colors.green,
      'electric': Colors.yellow[700]!,
      'ice': Colors.cyan,
      'fighting': Colors.red[900]!,
      'poison': Colors.purple,
      'ground': Colors.brown,
      'flying': Colors.indigo[200]!,
      'psychic': Colors.pink,
      'bug': Colors.lightGreen,
      'rock': Colors.brown[700]!,
      'ghost': Colors.deepPurple,
      'dragon': Colors.indigo,
      'dark': Colors.grey[900]!,
      'steel': Colors.blueGrey,
      'fairy': Colors.pink[200]!,
    };
    return cores[tipo.toLowerCase()] ?? Colors.grey;
  }

  IconData _getQuizIcon(String quizTipo) {
    switch (quizTipo) {
      case 'banco_dados': return Icons.storage;
      case 'flutter': return Icons.phone_android;
      case 'web': return Icons.language;
      case 'git': return Icons.source;
      case 'algoritmos': return Icons.code;
      default: return Icons.quiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Meus Resultados')),
        body: const Center(child: Text('Erro: Usuário não encontrado.')),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Header roxo com título
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF403AFF),
                  Color(0xFF000000),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Meus Resultados\ndo Quiz',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep, color: Colors.white),
                  onPressed: _limparTodosResultados,
                  tooltip: 'Limpar todos os resultados',
                ),
              ],
            ),
          ),

          // Filtros e ordenação
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.sort, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _ordenacao,
                    decoration: const InputDecoration(
                      labelText: 'Ordenar por',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'data_recente', child: Text('Data: Mais Recente')),
                      DropdownMenuItem(value: 'data_antiga', child: Text('Data: Mais Antiga')),
                      DropdownMenuItem(value: 'maior_pontuacao', child: Text('Maior Pontuação')),
                      DropdownMenuItem(value: 'menor_pontuacao', child: Text('Menor Pontuação')),
                    ],
                    onChanged: (valor) {
                      setState(() => _ordenacao = valor!);
                      _aplicarOrdenacao();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Corpo com lista de resultados
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _resultados.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'Você ainda não respondeu nenhum quiz.',
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _resultados.length,
                        itemBuilder: (context, index) {
                          final resultado = _resultados[index];
                          final acertos = resultado['acertos'];
                          final total = resultado['total_perguntas'];
                          final porcentagem = (acertos / total) * 100;
                          final pokemon = resultado['pokemon'];
                          final pontuacaoPerfeita = resultado['pontuacao_perfeita'];
                          
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                // Cabeçalho com quiz
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF403AFF),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(_getQuizIcon(resultado['quiz_tipo']), color: Colors.white, size: 30),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              resultado['quiz_titulo'],
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                            Text(
                                              resultado['data_envio'].toString().substring(0, 16),
                                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (pontuacaoPerfeita)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(12)),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.star, size: 16, color: Colors.white),
                                              SizedBox(width: 4),
                                              Text('PERFEITO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                
                                // Pontuação e Pokémon
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: const Color(0xFF403AFF),
                                              radius: 30,
                                              child: Text('$acertos', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Pontuação: $acertos de $total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                Text('Porcentagem: ${porcentagem.toStringAsFixed(1)}%', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      if (pokemon != null)
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: _getTipoColor(
                                                    pokemon['types'] != null && (pokemon['types'] as List).isNotEmpty
                                                        ? pokemon['types'][0]['type']['name']
                                                        : 'normal'
                                                  ).withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Image.network(
                                                  pokemon['sprites']?['front_default'] ?? '',
                                                  errorBuilder: (_, __, ___) => const Icon(Icons.catching_pokemon, size: 40),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                (pokemon['name'] ?? 'Pokémon').toString().toUpperCase(),
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
