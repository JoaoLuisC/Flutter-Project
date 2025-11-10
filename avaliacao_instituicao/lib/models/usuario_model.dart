// models/usuario_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModel {
  final String id;
  final String nome;
  final String email;
  final String tipoUsuario; // 'admin' ou 'aluno'
  final DateTime dataCriacao;
  final DateTime? dataAtualizacao;

  UsuarioModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.tipoUsuario,
    required this.dataCriacao,
    this.dataAtualizacao,
  });

  // Criar a partir de um documento do Firestore
  factory UsuarioModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UsuarioModel(
      id: doc.id,
      nome: data['nome'] ?? '',
      email: data['email'] ?? '',
      tipoUsuario: data['tipoUsuario'] ?? 'aluno',
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
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      tipoUsuario: tipoUsuario ?? this.tipoUsuario,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }
}
