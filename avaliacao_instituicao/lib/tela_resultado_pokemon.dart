// tela_resultado_pokemon.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:avaliacao_instituicao/services/pokemon_service.dart';

class TelaResultadoPokemon extends StatefulWidget {
  final int pontuacao;
  final int totalPerguntas;
  final bool pontuacaoPerfeita;

  const TelaResultadoPokemon({
    super.key,
    required this.pontuacao,
    required this.totalPerguntas,
    this.pontuacaoPerfeita = false,
  });

  @override
  State<TelaResultadoPokemon> createState() => _TelaResultadoPokemonState();
}

class _TelaResultadoPokemonState extends State<TelaResultadoPokemon> {
  final PokemonService _pokemonService = PokemonService();
  List<Map<String, dynamic>> _pokemons = [];
  bool _isLoading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarPokemons();
  }

  Future<void> _carregarPokemons() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      // Se pontuação perfeita (10/10), buscar 2 Pokémons, senão 1
      final quantidadePokemons = widget.pontuacaoPerfeita ? 2 : 1;
      
      for (int i = 0; i < quantidadePokemons; i++) {
        final pokemon = await _pokemonService.buscarPokemonAleatorio();
        
        // Salvar cada Pokémon no Firestore
        await FirebaseFirestore.instance
            .collection('quiz_resultados')
            .add({
          'userId': user.uid,
          'pontuacao': widget.pontuacao,
          'total_perguntas': widget.totalPerguntas,
          'pontuacao_perfeita': widget.pontuacaoPerfeita,
          'pokemon': pokemon,
          'data_resposta': FieldValue.serverTimestamp(),
        });
        
        _pokemons.add(pokemon);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _erro = e.toString();
        _isLoading = false;
      });
    }
  }

  String _obterMensagemMotivacional() {
    double percentual = (widget.pontuacao / widget.totalPerguntas) * 100;
    
    if (percentual >= 90) {
      return '🏆 Excelente! Você é um Mestre Pokémon!';
    } else if (percentual >= 70) {
      return '⭐ Muito Bem! Continue treinando!';
    } else if (percentual >= 50) {
      return '👍 Bom trabalho! Você está evoluindo!';
    } else {
      return '💪 Continue se esforçando! Todo mestre começou assim!';
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
          // Header com gradiente
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 30),
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
                  'Resultado do Quiz',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${widget.pontuacao} / ${widget.totalPerguntas}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _obterMensagemMotivacional(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Título dos Pokémons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.pontuacaoPerfeita 
                  ? '🏆 Pontuação Perfeita! 2 Pokémons Recompensa!'
                  : '🎁 Seu Pokémon Recompensa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Lista de Pokémons
          Expanded(
            child: _buildContent(),
          ),

          // Botão Voltar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar para Home', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(widget.pontuacaoPerfeita 
                ? 'Carregando seus 2 Pokémons...' 
                : 'Carregando seu Pokémon...'),
          ],
        ),
      );
    }

    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Erro ao carregar Pokémon', style: TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            Text(_erro!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarPokemons,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_pokemons.isEmpty) {
      return const Center(child: Text('Nenhum Pokémon encontrado.'));
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: _pokemons.map((pokemon) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildPokemonCard(pokemon),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPokemonCard(Map<String, dynamic> pokemon) {
    final name = pokemon['name'] ?? 'Desconhecido';
    final id = pokemon['id'] ?? 0;
    final imageUrl = pokemon['sprites']?['front_default'] ?? '';
    final types = pokemon['types'] as List<dynamic>? ?? [];
    final stats = pokemon['stats'] as List<dynamic>? ?? [];
    
    final primaryType = types.isNotEmpty 
        ? types[0]['type']['name'] as String 
        : 'normal';
    final cardColor = _getTipoColor(primaryType);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardColor.withOpacity(0.8),
              cardColor,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Número
            Text(
              '#${id.toString().padLeft(3, '0')}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Imagem
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                height: 150,
                width: 150,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.catching_pokemon, size: 150, color: Colors.white);
                },
              )
            else
              const Icon(Icons.catching_pokemon, size: 150, color: Colors.white),
            
            const SizedBox(height: 16),
            
            // Nome
            Text(
              name.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tipos
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: types.map<Widget>((type) {
                final typeName = type['type']['name'] as String;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    typeName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: stats.map<Widget>((stat) {
                  final statName = stat['stat']['name'] as String;
                  final statValue = stat['base_stat'] as int;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            statName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: statValue / 255,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 30,
                          child: Text(
                            '$statValue',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

