import 'item.dart';

/// Contrato que a camada de dados deve cumprir. O domínio define o que
/// precisa; a camada de dados decide como (SQLite, memória, rede).
abstract interface class ItemRepository {
  Future<List<Item>> listar();

  /// Insere (quando id é nulo) ou atualiza. Devolve o item com id preenchido.
  Future<Item> salvar(Item item);

  Future<void> excluir(int id);

  Future<List<Item>> listarNaoSincronizados();

  /// Marca como enviada a versão informada, se ela ainda for a atual.
  Future<void> marcarComoSincronizado(Item item);
}
