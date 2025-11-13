import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaMeusPokemonsV2 extends StatefulWidget {
  const TelaMeusPokemonsV2({super.key});

  @override
  State<TelaMeusPokemonsV2> createState() => _TelaMeusPokemonsV2State();
}

class _TelaMeusPokemonsV2State extends State<TelaMeusPokemonsV2> {
  List<Map<String, dynamic>> _todosPokemons = [];
  List<Map<String, dynamic>> _pokemonsFiltrados = [];
  bool _isLoading = true;
  
  String? _tipoSelecionado;
  String _ordenacaoSelecionada = 'data'; // data, nome, ataque, defesa, hp

  final List<String> _tiposDisponiveis = [
    'Todos',
    'normal', 'fire', 'water', 'grass', 'electric', 'ice',
    'fighting', 'poison', 'ground', 'flying', 'psychic', 'bug',
    'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy'
  ];

  @override
  void initState() {
    super.initState();
    _carregarPokemons();
  }

  Future<void> _carregarPokemons() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('quiz_resultados')
          .where('userId', isEqualTo: userId)
          .get();

      final List<Map<String, dynamic>> pokemons = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['pokemon'] != null) {
          final pokemonData = data['pokemon'] as Map<String, dynamic>;
          final stats = pokemonData['stats'] as List<dynamic>? ?? [];
          
          // Extrair stats
          int hp = 0, ataque = 0, defesa = 0, spAtk = 0, spDef = 0, velocidade = 0;
          for (var stat in stats) {
            final statName = stat['stat']['name'];
            final baseStat = stat['base_stat'];
            if (statName == 'hp') hp = baseStat;
            if (statName == 'attack') ataque = baseStat;
            if (statName == 'defense') defesa = baseStat;
            if (statName == 'special-attack') spAtk = baseStat;
            if (statName == 'special-defense') spDef = baseStat;
            if (statName == 'speed') velocidade = baseStat;
          }
          
          pokemons.add({
            'id': pokemonData['id'] ?? 0,
            'nome': pokemonData['name'] ?? 'Desconhecido',
            'imagem': pokemonData['sprites']?['front_default'] ?? '',
            'tipos': pokemonData['types'] != null 
                ? (pokemonData['types'] as List).map((t) => t['type']['name'] as String).toList()
                : ['normal'],
            'pontuacao': data['pontuacao'] ?? 0,
            'data': data['data_resposta'] != null 
                ? (data['data_resposta'] as Timestamp).toDate()
                : DateTime.now(),
            'hp': hp,
            'ataque': ataque,
            'defesa': defesa,
            'ataque_especial': spAtk,
            'defesa_especial': spDef,
            'velocidade': velocidade,
            'peso': pokemonData['weight'] ?? 0,
            'altura': pokemonData['height'] ?? 0,
          });
        }
      }

      setState(() {
        _todosPokemons = pokemons;
        _aplicarFiltrosEOrdenacao();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _aplicarFiltrosEOrdenacao() {
    List<Map<String, dynamic>> resultado = List.from(_todosPokemons);
    
    // Aplicar filtro de tipo
    if (_tipoSelecionado != null && _tipoSelecionado != 'Todos') {
      resultado = resultado.where((pokemon) {
        final tipos = pokemon['tipos'] as List<String>;
        return tipos.contains(_tipoSelecionado);
      }).toList();
    }
    
    // Aplicar ordenação
    switch (_ordenacaoSelecionada) {
      case 'nome':
        resultado.sort((a, b) => a['nome'].compareTo(b['nome']));
        break;
      case 'ataque':
        resultado.sort((a, b) => b['ataque'].compareTo(a['ataque']));
        break;
      case 'defesa':
        resultado.sort((a, b) => b['defesa'].compareTo(a['defesa']));
        break;
      case 'hp':
        resultado.sort((a, b) => b['hp'].compareTo(a['hp']));
        break;
      case 'poder':
        resultado.sort((a, b) {
          int poderA = a['hp'] + a['ataque'] + a['defesa'] + a['ataque_especial'] + a['defesa_especial'] + a['velocidade'];
          int poderB = b['hp'] + b['ataque'] + b['defesa'] + b['ataque_especial'] + b['defesa_especial'] + b['velocidade'];
          return poderB.compareTo(poderA);
        });
        break;
      case 'data':
      default:
        resultado.sort((a, b) => b['data'].compareTo(a['data']));
    }
    
    setState(() {
      _pokemonsFiltrados = resultado;
    });
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

  void _mostrarDetalhesPokemon(Map<String, dynamic> pokemon) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: _getTipoColor(pokemon['tipos'][0]),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(24),
            children: [
              // Barra indicadora
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Nome e ID
              Text(
                pokemon['nome'].toString().toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '#${pokemon['id'].toString().padLeft(3, '0')}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              
              // Imagem
              Center(
                child: Image.network(
                  pokemon['imagem'],
                  height: 200,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.catching_pokemon,
                    size: 200,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Tipos
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: (pokemon['tipos'] as List<String>).map((tipo) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tipo.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              
              // Características físicas
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem('Peso', '${(pokemon['peso'] / 10).toStringAsFixed(1)} kg'),
                        _buildInfoItem('Altura', '${(pokemon['altura'] / 10).toStringAsFixed(1)} m'),
                        _buildInfoItem('Score', '${pokemon['pontuacao']}'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Stats
              const Text(
                'ESTATÍSTICAS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              _buildStatBar('HP', pokemon['hp'], Colors.red),
              _buildStatBar('Ataque', pokemon['ataque'], Colors.orange),
              _buildStatBar('Defesa', pokemon['defesa'], Colors.blue),
              _buildStatBar('Atq. Especial', pokemon['ataque_especial'], Colors.purple),
              _buildStatBar('Def. Especial', pokemon['defesa_especial'], Colors.green),
              _buildStatBar('Velocidade', pokemon['velocidade'], Colors.yellow[700]!),
              const SizedBox(height: 20),
              
              // Total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PODER TOTAL',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${pokemon['hp'] + pokemon['ataque'] + pokemon['defesa'] + pokemon['ataque_especial'] + pokemon['defesa_especial'] + pokemon['velocidade']}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildStatBar(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              Text(
                value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value / 255,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF403AFF), Color(0xFF000000)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Meus Pokémons',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: ${_pokemonsFiltrados.length}',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
          
          // Filtros e Ordenação
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Filtro por tipo
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _tiposDisponiveis.map((tipo) {
                      final selecionado = tipo == (_tipoSelecionado ?? 'Todos');
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(tipo == 'Todos' ? 'Todos' : tipo.toUpperCase()),
                          selected: selecionado,
                          onSelected: (_) {
                            setState(() {
                              _tipoSelecionado = tipo == 'Todos' ? null : tipo;
                              _aplicarFiltrosEOrdenacao();
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: tipo == 'Todos' ? Colors.purple[100] : _getTipoColor(tipo).withOpacity(0.3),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Ordenação
                Row(
                  children: [
                    const Text('Ordenar por:', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildOrdenacaoChip('Data', 'data'),
                            _buildOrdenacaoChip('Nome', 'nome'),
                            _buildOrdenacaoChip('Ataque', 'ataque'),
                            _buildOrdenacaoChip('Defesa', 'defesa'),
                            _buildOrdenacaoChip('HP', 'hp'),
                            _buildOrdenacaoChip('Poder Total', 'poder'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de Pokémons
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _pokemonsFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.catching_pokemon, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _tipoSelecionado != null
                                  ? 'Nenhum Pokémon tipo ${_tipoSelecionado!.toUpperCase()}'
                                  : 'Nenhum Pokémon capturado ainda',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _pokemonsFiltrados.length,
                        itemBuilder: (context, index) {
                          final pokemon = _pokemonsFiltrados[index];
                          final tipoPrimario = pokemon['tipos'][0] as String;
                          
                          return GestureDetector(
                            onTap: () => _mostrarDetalhesPokemon(pokemon),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _getTipoColor(tipoPrimario).withOpacity(0.8),
                                      _getTipoColor(tipoPrimario),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '#${pokemon['id'].toString().padLeft(3, '0')}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Image.network(
                                      pokemon['imagem'],
                                      height: 100,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.catching_pokemon,
                                        size: 100,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      pokemon['nome'].toString().toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 4,
                                      children: (pokemon['tipos'] as List<String>).map((tipo) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            tipo.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.star, size: 14, color: Colors.white70),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Score: ${pokemon['pontuacao']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdenacaoChip(String label, String valor) {
    final selecionado = valor == _ordenacaoSelecionada;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selecionado,
        onSelected: (_) {
          setState(() {
            _ordenacaoSelecionada = valor;
            _aplicarFiltrosEOrdenacao();
          });
        },
      ),
    );
  }
}
