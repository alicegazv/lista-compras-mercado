import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/identidade.dart';
import '../../dominio/item.dart';
import '../../dominio/regras_item.dart';
import '../componentes/cartao_item.dart';
import '../componentes/faixa_offline.dart';
import '../componentes/mascote.dart';
import '../providers.dart';

class TelaLista extends ConsumerWidget {
  const TelaLista({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itensAsync = ref.watch(itensProvider);
    final online = switch (ref.watch(conectividadeProvider)) {
      AsyncData(:final value) => value,
      _ => true, // enquanto o estado da rede é desconhecido, não há alerta
    };
    // select: esta tela só é reconstruída quando "emAndamento" muda.
    final sincronizando = ref.watch(
      sincronizacaoProvider.select((estado) => estado.emAndamento),
    );

    // Ao recuperar a conexão, envia automaticamente o que ficou pendente.
    ref.listen(conectividadeProvider, (anterior, atual) {
      final reconectou =
          anterior is AsyncData<bool> &&
          !anterior.value &&
          atual is AsyncData<bool> &&
          atual.value;
      if (reconectou) {
        ref.read(sincronizacaoProvider.notifier).sincronizar();
      }
    });

    // Exibe o resultado de cada sincronização.
    ref.listen(sincronizacaoProvider, (anterior, atual) {
      final mensagem = atual.mensagem;
      if (!atual.emAndamento && mensagem != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(mensagem)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(Identidade.nomeDoApp),
        actions: [
          IconButton(
            tooltip: 'Enviar alterações',
            onPressed: sincronizando
                ? null
                : () => ref.read(sincronizacaoProvider.notifier).sincronizar(),
            icon: sincronizando
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
          ),
          IconButton(
            tooltip: 'Sobre o aplicativo',
            onPressed: () => context.go('/sobre'),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/item/novo'),
        icon: const Icon(Icons.add),
        label: const Text('Novo item'),
      ),
      body: Column(
        children: [
          if (!online) const FaixaOffline(),
          Expanded(
            child: itensAsync.when(
              data: (itens) => _Conteudo(itens: itens),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (erro, _) => _Falha(
                erro: erro,
                aoTentarNovamente: () => ref.invalidate(itensProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.itens});

  final List<Item> itens;

  @override
  Widget build(BuildContext context) {
    if (itens.isEmpty) return const _EstadoVazio();

    final resumo = resumir(itens);
    // A altura do cartão acompanha a escala de fonte do sistema (Aula 4).
    final alturaDoCartao = MediaQuery.textScalerOf(context).scale(80);

    return LayoutBuilder(
      builder: (context, restricoes) {
        // Pontos de quebra de 600 e 840 dp (Aula 3).
        final colunas = restricoes.maxWidth < 600
            ? 1
            : restricoes.maxWidth < 840
            ? 2
            : 3;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _CabecalhoResumo(resumo: resumo)),
            SliverPadding(
              // 96 dp no fim: o botão flutuante não cobre o último item.
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: colunas,
                  mainAxisExtent: alturaDoCartao,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: itens.length,
                itemBuilder: (context, i) => CartaoItem(item: itens[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CabecalhoResumo extends StatelessWidget {
  const _CabecalhoResumo({required this.resumo});

  final Resumo resumo;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final cores = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cores.primaryContainer, cores.tertiaryContainer],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '♡ ${resumo.comprados} de ${resumo.total} itens comprados',
              style: textos.titleMedium?.copyWith(
                color: cores.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: resumo.progresso,
                minHeight: 10,
                backgroundColor: cores.surface.withValues(alpha: 0.6),
              ),
            ),
            if (resumo.aguardandoEnvio > 0) ...[
              const SizedBox(height: 8),
              Text(
                '${resumo.aguardandoEnvio} alteração(ões) aguardando envio',
                style: textos.bodySmall?.copyWith(
                  color: cores.onPrimaryContainer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Mascote(),
            const SizedBox(height: 16),
            Text(
              'A lista está vazia.',
              style: tema.textTheme.titleLarge?.copyWith(
                color: tema.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Toque em "Novo item" para começar ✿',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Falha extends StatelessWidget {
  const _Falha({required this.erro, required this.aoTentarNovamente});

  final Object erro;
  final VoidCallback aoTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Não foi possível ler a lista salva no aparelho.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text('$erro', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: aoTentarNovamente,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
