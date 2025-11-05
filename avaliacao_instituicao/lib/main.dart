import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:avaliacao_instituicao/tela_login.dart';
import 'package:avaliacao_instituicao/tela_home.dart';
import 'package:avaliacao_instituicao/tela_registro.dart';
import 'package:avaliacao_instituicao/tela_formulario_avaliacao.dart';
import 'package:avaliacao_instituicao/tela_quiz.dart';
import 'package:avaliacao_instituicao/tela_resultados_anteriores.dart';

void main() async {
  // Garantir que o Flutter esteja inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar o Firebase
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avaliação Institucional',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF403AFF), // Roxo do protótipo
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Color(0xFF403AFF), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF403AFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 2,
          ),
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF403AFF);
            }
            return Colors.grey;
          }),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: const Color(0xFF403AFF),
          thumbColor: const Color(0xFF403AFF),
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthCheck(),
        '/login': (context) => const TelaLogin(),
        '/registro': (context) => const TelaRegistro(),
        '/home': (context) => const TelaHome(),
        '/formulario': (context) => const TelaFormularioAvaliacao(),
        '/quiz': (context) => const TelaQuiz(),
        '/resultados': (context) => const TelaResultadosAnteriores(),
      },
    );
  }
}

// Widget de Verificação de Autenticação
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Se estiver carregando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // Se tiver um usuário (logado)
        if (snapshot.hasData) {
          return const TelaHome();
        }
        
        // Se não tiver um usuário (deslogado)
        return const TelaLogin();
      },
    );
  }
}
