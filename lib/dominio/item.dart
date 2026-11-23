/// Entidade de domínio: não conhece Flutter, SQLite nem formato de rede.
class Item {
  const Item({
    this.id,
    required this.nome,
    this.quantidade = 1,
    required this.categoria,
    this.observacao = '',
    this.comprado = false,
    this.sincronizado = false,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  /// Nulo enquanto o item não foi gravado no banco.
  final int? id;
  final String nome;
  final int quantidade;
  final String categoria;
  final String observacao;
  final bool comprado;

  /// Verdadeiro quando a versão atual já foi enviada ao servidor.
  final bool sincronizado;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  /// Cria uma cópia com alguns campos trocados. O objeto original não muda.
  Item copyWith({
    int? id,
    String? nome,
    int? quantidade,
    String? categoria,
    String? observacao,
    bool? comprado,
    bool? sincronizado,
    DateTime? atualizadoEm,
  }) {
    return Item(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      quantidade: quantidade ?? this.quantidade,
      categoria: categoria ?? this.categoria,
      observacao: observacao ?? this.observacao,
      comprado: comprado ?? this.comprado,
      sincronizado: sincronizado ?? this.sincronizado,
      criadoEm: criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}
