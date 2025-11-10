// tela_resultado_pokemon.dart
import 'package:flutter/material.dart';
import 'package:avaliacao_instituicao/models/pokemon_model.dart';
import 'package:avaliacao_instituicao/services/pokemon_service.dart';

class TelaResultadoPokemon extends StatefulWidget {
  final int pontuacao;
  final int totalPerguntas;

  const TelaResultadoPokemon({
    super.key,
    required this.pontuacao,
    required this.totalPerguntas,
  });

  @override
  State<TelaResultadoPokemon> createState() => _TelaResultadoPokemonState();
}

class _TelaResultadoPokemonState extends State<TelaResultadoPokemon> {
  final PokemonService _pokemonService = PokemonService();
  List<PokemonModel> _pokemons = [];
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
      // Determinar quantos Pokémons mostrar baseado na pontuação
      int quantidade = _calcularQuantidadePokemons();
      
      List<PokemonModel> pokemons;
      
      // Se teve pontuação alta (>80%), mostrar os mais fortes
      double percentual = (widget.pontuacao / widget.totalPerguntas) * 100;
      if (percentual >= 80) {
        pokemons = await _pokemonService.buscarPokemonsMaisFortes(quantidade);
      } else {
        pokemons = await _pokemonService.buscarPokemonsAleatorios(quantidade);
      }

      setState(() {
        _pokemons = pokemons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _erro = e.toString();
        _isLoading = false;
      });
    }
  }

  int _calcularQuantidadePokemons() {
    double percentual = (widget.pontuacao / widget.totalPerguntas) * 100;
    
    if (percentual >= 90) return 10;
    if (percentual >= 70) return 8;
    if (percentual >= 50) return 6;
    return 4;
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
              '🎁 Seus Pokémons Recompensa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando Pokémons...'),
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
            Text('Erro ao carregar Pokémons', style: TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            Text(_erro!, style: TextStyle(fontSize: 12, color: Colors.grey)),
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

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _pokemons.length,
      itemBuilder: (context, index) {
        return _buildPokemonCard(_pokemons[index]);
      },
    );
  }

  Widget _buildPokemonCard(PokemonModel pokemon) {
    Color cardColor = _hexToColor(pokemon.getPrimaryColor());

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardColor.withOpacity(0.8),
              cardColor,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Número
            Text(
              '#${pokemon.number.toString().padLeft(3, '0')}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Imagem
            if (pokemon.imageUrl.isNotEmpty)
              Image.network(
                pokemon.imageUrl,
                height: 80,
                width: 80,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.catching_pokemon, size: 80, color: Colors.white);
                },
              )
            else
              const Icon(Icons.catching_pokemon, size: 80, color: Colors.white),
            
            const SizedBox(height: 8),
            
            // Nome
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                pokemon.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Tipos
            Wrap(
              spacing: 4,
              children: pokemon.type.map((type) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    type,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 8),
            
            // Stats
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Total: ${pokemon.total}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'HP: ${pokemon.hp} | ATK: ${pokemon.attack}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
