// services/pokemon_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';
import 'dart:math';

class PokemonService {
  static const String pokeApiUrl = 'https://pokeapi.co/api/v2';
  static const String backupApiUrl = 'https://www.canalti.com.br/api/pokemons.json';

  // Buscar um Pokémon aleatório da PokeAPI
  Future<Map<String, dynamic>> buscarPokemonAleatorio() async {
    try {
      // Gerar número aleatório entre 1 e 898 (total de pokémons na gen 8)
      final random = Random();
      final pokemonId = random.nextInt(898) + 1;
      
      print('🔍 Buscando Pokémon #$pokemonId da PokeAPI');
      
      final response = await http.get(
        Uri.parse('$pokeApiUrl/pokemon/$pokemonId'),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout ao buscar Pokémon');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Pokémon ${data['name']} carregado com sucesso!');
        return data;
      } else {
        throw Exception('Erro ao carregar Pokémon: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao buscar Pokémon: $e');
      throw Exception('Erro ao buscar Pokémon: $e');
    }
  }

  // Buscar todos os Pokémons da API
  Future<List<PokemonModel>> buscarPokemons() async {
    try {
      print('🔍 Buscando Pokémons da API: $backupApiUrl');
      
      final response = await http.get(
        Uri.parse(backupApiUrl),
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
      // Retornar lista vazia ao invés de erro
      return [];
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
