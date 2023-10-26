import '../repositories/moeda_repository.dart';
import '../models/moeda.dart';
import '../pages/moedas_detalhes_page.dart';
import '../repositories/favoritas_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MoedasPage extends StatefulWidget {
  MoedasPage({Key? key}) : super(key: key);

  @override
  _MoedasPageState createState() => _MoedasPageState();
}

class _MoedasPageState extends State<MoedasPage> {
  late List<Moeda> tabela;
  late NumberFormat real = NumberFormat.currency(locale: 'pt_BR', name: 'R\$');
  List<Moeda> selecionadas = [];
  late FavoritasRepository favoritas;
  late MoedaRepository moedas;


  appBarDinamica() {
    if (selecionadas.isEmpty) {
      return AppBar(
        title: const Text('Cripto Moedas'),
      );
    } else {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            limparSelecionadas();
          },
        ),
        title: Text('${selecionadas.length} selecionadas'),
        backgroundColor: Colors.blueGrey[50],
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        textTheme: const TextTheme(
          headline6: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  mostrarDetalhes(Moeda moeda) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoedasDetalhesPage(moeda: moeda),
      ),
    );
  }

  limparSelecionadas() {
    setState(() {
      selecionadas = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    // favoritas = Provider.of<FavoritasRepository>(context);
    favoritas = context.watch<FavoritasRepository>();
    moedas = context.watch<MoedaRepository>();
    tabela = moedas.tabela;

    return Scaffold(
      appBar: appBarDinamica(),
      body: RefreshIndicator(
        onRefresh: () => moedas.checkPrecos(),
        child: ListView.separated(
              itemBuilder: (BuildContext context, int moeda) {
                return ListTile(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  leading: (selecionadas.contains(tabela[moeda]))
                      ? const CircleAvatar(
                          child: Icon(Icons.check),
                        )
                      : SizedBox(
                          width: 40,
                          child: Image.network(tabela[moeda].icone),
                        ),
                  title: Row(
                    children: [
                      Text(
                        tabela[moeda].nome,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (favoritas.lista
                          .any((fav) => fav.sigla == tabela[moeda].sigla))
                        const Icon(Icons.circle, color: Colors.amber, size: 8),
                    ],
                  ),
                  trailing: Text(
                    real.format(tabela[moeda].preco),
                    style: const TextStyle(fontSize: 15),
                  ),
                  selected: selecionadas.contains(tabela[moeda]),
                  selectedTileColor: Colors.indigo[50],
                  onLongPress: () {
                    setState(() {
                      (selecionadas.contains(tabela[moeda]))
                          ? selecionadas.remove(tabela[moeda])
                          : selecionadas.add(tabela[moeda]);
                    });
                  },
                  onTap: () => mostrarDetalhes(tabela[moeda]),
                );
              },
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, ___) => const Divider(),
              itemCount: tabela.length,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: selecionadas.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () {
                  favoritas.saveAll(selecionadas);
                  limparSelecionadas();
                },
                icon: const Icon(Icons.star),
                label: const Text(
                  'FAVORITAR',
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
    );
  }
}