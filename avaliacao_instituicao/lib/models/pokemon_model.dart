// models/pokemon_model.dart
class PokemonModel {
  final int number;
  final String name;
  final List<String> type;
  final int total;
  final int hp;
  final int attack;
  final int defense;
  final int spAtk;
  final int spDef;
  final int speed;
  final String imageUrl;

  PokemonModel({
    required this.number,
    required this.name,
    required this.type,
    required this.total,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.spAtk,
    required this.spDef,
    required this.speed,
    required this.imageUrl,
  });

  // Criar a partir do JSON da API
  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    return PokemonModel(
      number: json['Number'] ?? 0,
      name: json['Name'] ?? '',
      type: List<String>.from(json['Type'] ?? []),
      total: json['Total'] ?? 0,
      hp: json['HP'] ?? 0,
      attack: json['Attack'] ?? 0,
      defense: json['Defense'] ?? 0,
      spAtk: json['Sp_Atk'] ?? 0,
      spDef: json['Sp_Def'] ?? 0,
      speed: json['Speed'] ?? 0,
      imageUrl: json['Image'] ?? '',
    );
  }

  // Converter para Map (opcional, para salvar no Firestore se necessário)
  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'name': name,
      'type': type,
      'total': total,
      'hp': hp,
      'attack': attack,
      'defense': defense,
      'spAtk': spAtk,
      'spDef': spDef,
      'speed': speed,
      'imageUrl': imageUrl,
    };
  }

  // Obter cor baseada no tipo primário
  String getPrimaryColor() {
    if (type.isEmpty) return '#A8A878'; // Normal

    switch (type[0].toLowerCase()) {
      case 'grass':
        return '#78C850';
      case 'fire':
        return '#F08030';
      case 'water':
        return '#6890F0';
      case 'electric':
        return '#F8D030';
      case 'psychic':
        return '#F85888';
      case 'ice':
        return '#98D8D8';
      case 'dragon':
        return '#7038F8';
      case 'dark':
        return '#705848';
      case 'fairy':
        return '#EE99AC';
      case 'normal':
        return '#A8A878';
      case 'fighting':
        return '#C03028';
      case 'flying':
        return '#A890F0';
      case 'poison':
        return '#A040A0';
      case 'ground':
        return '#E0C068';
      case 'rock':
        return '#B8A038';
      case 'bug':
        return '#A8B820';
      case 'ghost':
        return '#705898';
      case 'steel':
        return '#B8B8D0';
      default:
        return '#A8A878';
    }
  }
}
