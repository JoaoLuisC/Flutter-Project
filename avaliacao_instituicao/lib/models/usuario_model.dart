// models/usuario_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class UsuarioModel {
  final String id;
  final String nome;
  final String email;
  final String tipoUsuario; // 'admin', 'aluno' ou 'professor'
  final String codigoAmizade;
  final List<String> amigos; // Lista de IDs de amigos
  final DateTime dataCriacao;
  final DateTime? dataAtualizacao;

  UsuarioModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.tipoUsuario,
    required this.codigoAmizade,
    this.amigos = const [],
    required this.dataCriacao,
    this.dataAtualizacao,
  });

  // Gerar código de amizade baseado no email + nome
  static String gerarCodigoAmizade(String email, String nome) {
    final input = email.toLowerCase() + nome.toLowerCase();
    final bytes = utf8.encode(input);
    final hash = sha256.convert(bytes);
    return hash.toString().substring(0, 8).toUpperCase();
  }

  // Criar a partir de um documento do Firestore
  factory UsuarioModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UsuarioModel(
      id: doc.id,
      nome: data['nome'] ?? '',
      email: data['email'] ?? '',
      tipoUsuario: data['tipoUsuario'] ?? 'aluno',
      codigoAmizade: data['codigoAmizade'] ?? '',
      amigos: List<String>.from(data['amigos'] ?? []),
      dataCriacao: (data['data_criacao'] as Timestamp).toDate(),
      dataAtualizacao: data['data_atualizacao'] != null 
          ? (data['data_atualizacao'] as Timestamp).toDate() 
          : null,
    );
  }

  // Converter para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'tipoUsuario': tipoUsuario,
      'codigoAmizade': codigoAmizade,
      'amigos': amigos,
      'data_criacao': Timestamp.fromDate(dataCriacao),
      'data_atualizacao': dataAtualizacao != null 
          ? Timestamp.fromDate(dataAtualizacao!) 
          : null,
    };
  }

  // Copiar com alterações
  UsuarioModel copyWith({
    String? id,
    String? nome,
    String? email,
    String? tipoUsuario,
    String? codigoAmizade,
    List<String>? amigos,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      codigoAmizade: codigoAmizade ?? this.codigoAmizade,
      amigos: amigos ?? this.amigos,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }
}
