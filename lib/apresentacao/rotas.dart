import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'telas/tela_item.dart';
import 'telas/tela_lista.dart';
import 'telas/tela_nao_encontrada.dart';
import 'telas/tela_sobre.dart';

/// Rotas declaradas em um único lugar (Aula 14). Por serem filhas de '/', as
/// rotas de item e "sobre" mantêm a lista abaixo delas na pilha, inclusive
/// quando abertas por ligação profunda.
final roteadorProvider = Provider<GoRouter>((ref) {
  final roteador = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const TelaLista(),
        routes: [
          // 'item/novo' vem antes de 'item/:id' para "novo" não ser lido como id.
          GoRoute(
            path: 'item/novo',
            builder: (context, state) => const TelaItem(),
          ),
          GoRoute(
            path: 'item/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              return id == null ? const TelaNaoEncontrada() : TelaItem(id: id);
            },
          ),
          GoRoute(
            path: 'sobre',
            builder: (context, state) => const TelaSobre(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const TelaNaoEncontrada(),
  );
  ref.onDispose(roteador.dispose);
  return roteador;
});
