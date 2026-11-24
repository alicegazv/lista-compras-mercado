import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/identidade.dart';
import '../../dominio/item.dart';
import '../providers.dart';

class CartaoItem extends ConsumerWidget {
  const CartaoItem({super.key, required this.item});

  final Item item;

  /// Pede confirmação e, se o usuário aceitar, exclui o item.
  Future<void> _excluirComConfirmacao(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contextoDoDialogo) => AlertDialog(
        title: const Text('Excluir item?'),
        content: Text('"${item.nome}" será removido da lista.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contextoDoDialogo).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contextoDoDialogo).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    try {
      await ref.read(itensProvider.notifier).excluir(item);
    } catch (erro) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível excluir: $erro')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cores = Theme.of(context).colorScheme;
    final notifier = ref.read(itensProvider.notifier);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: cores.errorContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.delete_outline, color: cores.onErrorContainer),
      ),
      onDismissed: (_) => notifier.excluir(item),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          onTap: () => context.go('/item/${item.id}'),
          leading: Checkbox(
            shape: const CircleBorder(),
            value: item.comprado,
            onChanged: (_) => notifier.alternarComprado(item),
          ),
          title: Text(
            item.nome,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: item.comprado
                ? const TextStyle(decoration: TextDecoration.lineThrough)
                : null,
          ),
          subtitle: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text:
                      '${Identidade.emojiDa(item.categoria)} ${item.categoria} · '
                      '${item.quantidade} un. ',
                ),
                // Estado de envio: antes ficava na direita, mas esse espaço
                // agora é dos botões de editar e excluir.
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    item.sincronizado
                        ? Icons.cloud_done_outlined
                        : Icons.cloud_upload_outlined,
                    size: 16,
                    color: item.sincronizado ? cores.primary : cores.outline,
                    semanticLabel: item.sincronizado
                        ? 'Enviado ao servidor'
                        : 'Aguardando envio',
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Editar: botão tonal com lápis (diferente do ícone de nuvem
              // usado em "Enviar alterações").
              IconButton.filledTonal(
                tooltip: 'Editar item',
                onPressed: () => context.go('/item/${item.id}'),
                icon: const Icon(Icons.edit_outlined),
              ),
              const SizedBox(width: 4),
              // Excluir: botão vermelho, com confirmação.
              IconButton.filled(
                tooltip: 'Excluir item',
                style: IconButton.styleFrom(
                  backgroundColor: cores.errorContainer,
                  foregroundColor: cores.onErrorContainer,
                ),
                onPressed: () => _excluirComConfirmacao(context, ref),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
