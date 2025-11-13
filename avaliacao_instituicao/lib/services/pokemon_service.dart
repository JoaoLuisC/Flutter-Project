// services/pokemon_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';

class PokemonService {
  static const String apiUrl = 'https://www.canalti.com.br/api/pokemons.json';

  // Buscar todos os Pokémons da API
  Future<List<PokemonModel>> buscarPokemons() async {
    try {
      print('🔍 Buscando Pokémons da API: $apiUrl');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: A API demorou muito para responder');
        },
      );

      print('📡 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Decodificar o JSON
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> jsonList = jsonData['pokemon'];

        print('✅ ${jsonList.length} Pokémons carregados com sucesso!');

        // Converter cada item para PokemonModel
        List<PokemonModel> pokemons = jsonList
            .map((json) => PokemonModel.fromJson(json))
            .toList();

        return pokemons;
      } else {
        throw Exception('Erro ao carregar Pokémons: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao buscar Pokémons: $e');
      throw Exception('Erro ao buscar Pokémons: $e');
    }
  }

  // Buscar Pokémons aleatórios (útil para exibir após o quiz)
  Future<List<PokemonModel>> buscarPokemonsAleatorios(int quantidade) async {
    try {
      List<PokemonModel> todosPokemons = await buscarPokemons();
      
      // Embaralhar e pegar os primeiros N
      todosPokemons.shuffle();
      
      return todosPokemons.take(quantidade).toList();
    } catch (e) {
      throw Exception('Erro ao buscar Pokémons aleatórios: $e');
    }
  }

  // Buscar Pokémons por tipo
  Future<List<PokemonModel>> buscarPokemonsPorTipo(String tipo) async {
    try {
      List<PokemonModel> todosPokemons = await buscarPokemons();
      
      return todosPokemons
          .where((pokemon) => pokemon.type.any(
              (t) => t.toLowerCase() == tipo.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar Pokémons por tipo: $e');
    }
  }

  // Buscar Pokémon por número
  Future<PokemonModel?> buscarPokemonPorNumero(int numero) async {
    try {
      List<PokemonModel> todosPokemons = await buscarPokemons();
      
      return todosPokemons.firstWhere(
        (pokemon) => pokemon.number == numero,
        orElse: () => throw Exception('Pokémon não encontrado'),
      );
    } catch (e) {
      return null;
    }
  }

  // Buscar os N Pokémons mais fortes (por Total)
  Future<List<PokemonModel>> buscarPokemonsMaisFortes(int quantidade) async {
    try {
      List<PokemonModel> todosPokemons = await buscarPokemons();
      
      // Ordenar por Total (decrescente)
      todosPokemons.sort((a, b) => b.total.compareTo(a.total));
      
      return todosPokemons.take(quantidade).toList();
    } catch (e) {
      throw Exception('Erro ao buscar Pokémons mais fortes: $e');
    }
  }
}
