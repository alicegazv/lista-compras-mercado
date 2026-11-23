import 'package:flutter/material.dart';

/// Pessoa responsável pelo aplicativo.
class Integrante {
  const Integrante({required this.nome});

  final String nome;
}

/// Identificação do aplicativo e da autoria. É o único arquivo a editar para
/// definir nome, créditos, cor do tema e categorias da lista.
abstract final class Identidade {
  /// Nome exibido na barra superior e na tela "Sobre".
  static const nomeDoApp = 'Lista de Compras do Mercado';

  /// Frase curta que descreve o propósito do aplicativo.
  static const descricao =
      'Lista para organizar as compras do mercado: anote o que falta, marque '
      'o que já foi para o carrinho e mantenha tudo salvo no celular, mesmo '
      'sem internet.';

  static const turma = 'Desenvolvimento para Dispositivos Móveis — 2026';

  static const integrantes = [
    Integrante(nome: 'Alice Gomes Azevedo'),
    Integrante(nome: 'Sarah'),
    Integrante(nome: 'Wagner'),
  ];

  /// Cor semente do tema (Aula 10): o Material 3 deriva a paleta a partir dela.
  static const corSemente = Color(0xFFF06292); // rosa

  /// Categorias oferecidas no formulário. A primeira é o valor padrão.
  static const categorias = [
    'Hortifrúti',
    'Açougue',
    'Padaria',
    'Mercearia',
    'Bebidas',
    'Limpeza',
    'Higiene',
  ];

  /// Emoji exibido ao lado de cada categoria.
  static const emojis = {
    'Hortifrúti': '🥕',
    'Açougue': '🥩',
    'Padaria': '🥐',
    'Mercearia': '🍚',
    'Bebidas': '🧃',
    'Limpeza': '🧼',
    'Higiene': '🧴',
  };

  static String emojiDa(String categoria) => emojis[categoria] ?? '🛒';
}
