import 'dart:convert';

import 'package:commons/commons.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../main.dart';


class CategoriaModelHelper {
  late String categoria;
  late List<EspecieModelHelper> especies;

  CategoriaModelHelper({
    required this.categoria,
    required this.especies,
  });

  CategoriaModelHelper.fromMap(Map<String, dynamic> json) {
    categoria = json['categoria'];
    especies = json['especies']
        .map<EspecieModelHelper>((m) => EspecieModelHelper.fromJson(m))
        .toList();
  }

  factory CategoriaModelHelper.fromJson(String source) =>
      CategoriaModelHelper.fromMap(json.decode(source));
}

class EspecieModelHelper {
  late String nome;

  EspecieModelHelper({
    required this.nome,
  });

  EspecieModelHelper.fromJson(Map<String, dynamic> json) {
    nome = json['nome'];
  }
}

class _CategoryBloc {
  final url = Configs.configJsonUrl;
  Future<List<CategoriaModelHelper>> get future async {
    var response = await Dio().get(url);
    List<CategoriaModelHelper> list = response.data.map<CategoriaModelHelper>(
      (v) {
        return CategoriaModelHelper.fromMap(v);
      },
    ).toList()
      ..sort((a, b) => a.categoria
          .toString()
          .toLowerCase()
          .compareTo(b.categoria.toString().toLowerCase()));
    print(list);
    return list;
  }
}

class PetCategorySectionWidget extends StatelessWidget {
  final _bloc = _CategoryBloc();

  final String storeId;

  PetCategorySectionWidget({Key? key, required this.storeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Categorias",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            FutureBuilder<List<CategoriaModelHelper>>(
                future: _bloc.future,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<CategoriaModelHelper> l = snapshot.data!;
                    return Column(
                      children: l.map(
                        (c) {
                          return CategoriaCard(
                            padding: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 12),
                            title: c.categoria,
                            onTap: () {
                              push(
                                  context,
                                  CategoriasScreen(
                                    storeId: storeId,
                                    categoria: c,
                                  ));
                            },
                          );
                        },
                      ).toList(),
                    );
                  } else
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                })
            // ),
          ],
        ),
      ),
    );
  }
}

class CategoriasScreen extends StatelessWidget {
  final CategoriaModelHelper categoria;
  final String storeId;

  const CategoriasScreen({
    Key? key,
    required this.categoria,
    required this.storeId,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          categoria.categoria,
          style: TextStyle(
            color: Colors.grey[800],
          ),
        ),
        leading: BackButton(
          color: Colors.grey[800],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: categoria.especies
              .map(
                (e) => CategoriaCard(
                    title: e.nome,
                    onTap: () {
                      push(
                        context,
                        CreateProductScreen(
                            storeId: storeId,
                            category: CategoriaFilhote(
                              category: categoria.categoria,
                              breed: e.nome,
                            )),
                      );
                    }),
              )
              .toList(),
        ),
      ),
    );
  }
}

class CategoriaCard extends StatelessWidget {
  const CategoriaCard({
    Key? key,
    required this.onTap,
    required this.title,
    // this.padding = const EdgeInsets.all(12),
    this.padding,
  }) : super(key: key);

  final String title;
  final VoidCallback onTap;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        trailing: Icon(Icons.arrow_forward_ios),
        contentPadding: padding,
        title: Text(title),
      ),
    );
  }
}
