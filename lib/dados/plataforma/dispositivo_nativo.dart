import 'package:flutter/services.dart';

class InfoDispositivo {
  const InfoDispositivo({
    required this.fabricante,
    required this.modelo,
    required this.versaoAndroid,
    required this.nivelBateria,
  });

  final String fabricante;
  final String modelo;
  final String versaoAndroid;
  final int nivelBateria;
}

/// Lado Dart do canal de plataforma (Aula 14). O lado Kotlin fica na MainActivity.
class DispositivoNativo {
  static const _canal = MethodChannel('compras/dispositivo');

  /// Devolve null quando a plataforma não implementa o canal.
  Future<InfoDispositivo?> obterInformacoes() async {
    try {
      final mapa = await _canal.invokeMapMethod<String, Object?>(
        'obterInformacoes',
      );
      if (mapa == null) return null;
      return InfoDispositivo(
        fabricante: mapa['fabricante'] as String,
        modelo: mapa['modelo'] as String,
        versaoAndroid: mapa['versaoAndroid'] as String,
        nivelBateria: mapa['bateria'] as int,
      );
    } on MissingPluginException {
      return null; // canal não registrado nesta plataforma
    } on PlatformException {
      return null; // o código nativo respondeu com erro
    }
  }
}
