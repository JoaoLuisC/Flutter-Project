import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaMeusPokemons extends StatefulWidget {
  const TelaMeusPokemons({super.key});

  @override
  State<TelaMeusPokemons> createState() => _TelaMeusPokemonsState();
}

class _TelaMeusPokemonsState extends State<TelaMeusPokemons> {
  List<Map<String, dynamic>> _pokemonsConquistados = [];
  bool _isLoading = true;

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

      print('🔍 Carregando pokémons do usuário: $userId');

      // Buscar resultados de quiz do usuário (sem orderBy para evitar necessidade de índice)
      final snapshot = await FirebaseFirestore.instance
          .collection('quiz_resultados')
          .where('userId', isEqualTo: userId)
          .get();

      print('📦 Documentos encontrados: ${snapshot.docs.length}');

      final List<Map<String, dynamic>> pokemons = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('📄 Documento: ${doc.id}');
        
        if (data['pokemon'] != null) {
          final pokemonData = data['pokemon'] as Map<String, dynamic>;
          pokemons.add({
            'nome': pokemonData['name'] ?? 'Desconhecido',
            'imagem': pokemonData['sprites']?['front_default'] ?? '',
            'tipo': pokemonData['types'] != null && (pokemonData['types'] as List).isNotEmpty
                ? pokemonData['types'][0]['type']['name'] ?? 'normal'
                : 'normal',
            'pontuacao': data['pontuacao'] ?? 0,
            'data': data['data_resposta'] != null 
                ? (data['data_resposta'] as Timestamp).toDate()
                : DateTime.now(),
          });
        }
      }

      // Ordenar em memória ao invés de no Firestore
      pokemons.sort((a, b) => b['data'].compareTo(a['data']));

      print('✅ Total de pokémons carregados: ${pokemons.length}');

      setState(() {
        _pokemonsConquistados = pokemons;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erro ao carregar pokémons: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar pokémons: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header roxo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
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
                const Icon(Icons.catching_pokemon, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Meus Pokémons',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_pokemonsConquistados.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Conteúdo
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _pokemonsConquistados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.catching_pokemon_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum Pokémon conquistado ainda',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Complete quizzes para ganhar Pokémons!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _carregarPokemons,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _pokemonsConquistados.length,
                          itemBuilder: (context, index) {
                            final pokemon = _pokemonsConquistados[index];
                            return _buildPokemonCard(pokemon);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonCard(Map<String, dynamic> pokemon) {
    final tipo = pokemon['tipo'] as String;
    final cor = _getTipoColor(tipo);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cor.withOpacity(0.3),
            cor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cor.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Imagem do Pokémon
          if (pokemon['imagem'] != null && pokemon['imagem'].isNotEmpty)
            Image.network(
              pokemon['imagem'],
              height: 100,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.catching_pokemon, size: 80);
              },
            )
          else
            const Icon(Icons.catching_pokemon, size: 80),
          
          const SizedBox(height: 12),
          
          // Nome do Pokémon
          Text(
            pokemon['nome'].toString().toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Tipo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tipo.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Pontuação
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '${pokemon['pontuacao']} pontos',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
