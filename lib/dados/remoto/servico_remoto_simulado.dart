import 'dart:math';

import '../../dominio/item.dart';
import 'nova_tentativa.dart';

/// Ocupa o lugar de uma API real: demora a responder e falha em parte das
/// chamadas, o que permite observar nova tentativa e sincronização sem servidor.
class ServicoRemotoSimulado {
  ServicoRemotoSimulado({this.taxaDeFalha = 0.3, Random? aleatorio})
    : _aleatorio = aleatorio ?? Random();

  /// Fração das chamadas que falham (0.0 = nunca, 1.0 = sempre).
  final double taxaDeFalha;
  final Random _aleatorio;

  Future<void> enviar(Item item) async {
    await Future<void>.delayed(
      Duration(milliseconds: 200 + _aleatorio.nextInt(600)),
    );
    if (_aleatorio.nextDouble() < taxaDeFalha) {
      throw const FalhaTransitoria('Servidor indisponível (simulação).');
    }
  }
}
