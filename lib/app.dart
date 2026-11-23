import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'apresentacao/rotas.dart';
import 'config/identidade.dart';

class AppCompras extends ConsumerWidget {
  const AppCompras({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: Identidade.nomeDoApp,
      debugShowCheckedModeBanner: false,
      theme: _tema(Brightness.light),
      darkTheme: _tema(Brightness.dark),
      routerConfig: ref.watch(roteadorProvider),
    );
  }
}

/// Tema fofo em tons de rosa, derivado da cor semente (Aula 10).
ThemeData _tema(Brightness brilho) {
  final cores = ColorScheme.fromSeed(
    seedColor: Identidade.corSemente,
    brightness: brilho,
  );
  final claro = brilho == Brightness.light;
  return ThemeData(
    colorScheme: cores,
    scaffoldBackgroundColor: claro ? const Color(0xFFFFF0F6) : cores.surface,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: claro ? const Color(0xFFFFD6E7) : cores.surfaceContainerHigh,
      foregroundColor: cores.onSurface,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: claro ? Colors.white : cores.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cores.primary.withValues(alpha: 0.3)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: cores.primary,
      foregroundColor: cores.onPrimary,
      shape: const StadiumBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: claro ? Colors.white : null,
    ),
  );
}
