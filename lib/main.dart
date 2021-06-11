import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:commons/commons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app/widgets/category_screen.dart';

//TODO:adicionar localizacao

//TODO: Adicionar Seletor de categoria

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  bool useEmulator = false;
  bool firstRun = true;

  if (kDebugMode && useEmulator) {
    String host = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2:8080'
        : 'localhost:8080';

    if (firstRun) {
      FirebaseFirestore.instance.settings = Settings(
        host: host,
        sslEnabled: false,
      );
    }

    await FirebaseStorage.instance.useEmulator(host: 'localhost', port: 9199);

    // FirebaseAuth.instance.useEmulator('http://localhost:9099');
  }

  runApp(Pedigree());
}

class Pedigree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pedigree Vendedor',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.Home,
      routes: routes,
    );
  }
}

abstract class Routes {
  static const Home = '/';
}

final routes = <String, WidgetBuilder>{
  Routes.Home: (context) => StoreListScreen(),
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class StoreBloc {
  final _r = StoreFirebase();

  get stream => _r.readAll();

  create(Store s) => _r.create(s);

  delete(String id) => _r.delete(id);
}

class ProductBloc {
  final String storeId;
  final _rep = ProductFirebase();

  ProductBloc(this.storeId);

  get stream => _rep.readFromStore(storeId);

  create(PlatformFile img, Product p) => _rep.create(img, p);
}

class StoreListScreen extends StatefulWidget {
  const StoreListScreen({Key? key}) : super(key: key);

  @override
  _StoreListScreenState createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  final _bloc = StoreBloc();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          push(context, CreateStoreScreen());
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<List<Store>>(
        stream: _bloc.stream,
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final l = snapshot.data!;
            return ListView.builder(
              itemCount: l.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(l[i].title),
                  subtitle: Text(l[i].phone),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        onPressed: () {
                          push(
                              context,
                              CreateStoreScreen(
                                store: l[i],
                              ));
                        },
                        icon: Icon(Icons.edit),
                      )
                    ],
                  ),
                  onTap: () {
                    push(
                      context,
                      StoreScreen(
                        store: l[i],
                      ),
                    );
                  },
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class CreateStoreScreen extends StatefulWidget {
  final Store? store;
  const CreateStoreScreen({
    Key? key,
    this.store,
  }) : super(key: key);

  @override
  _CreateStoreScreenState createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends State<CreateStoreScreen> {
  late final _tTitle;
  late final _tPhone;
  late final _tInstagram;
  final _bloc = StoreBloc();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tTitle = TextEditingController(text: widget.store?.title);
    _tPhone = TextEditingController(text: widget.store?.phone);
    _tInstagram = TextEditingController(text: widget.store?.instagram);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.store?.title ?? 'Create'),
        actions: [
          widget.store != null
              ? IconButton(
                  onPressed: () {
                    _bloc.delete(widget.store!.id!);
                    pop(context);
                  },
                  icon: Icon(Icons.delete),
                )
              : Container()
        ],
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(hintText: 'Title'),
            controller: _tTitle,
          ),
          TextField(
            decoration: InputDecoration(hintText: 'Phone'),
            controller: _tPhone,
          ),
          TextField(
            decoration: InputDecoration(hintText: 'Insta'),
            controller: _tInstagram,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Store s = Store(
            title: _tTitle.text,
            instagram: _tInstagram.text,
            phone: _tPhone.text,
          );
          _bloc.create(s);
          pop(context);
        },
        child: Icon(
          Icons.check,
        ),
      ),
    );
  }
}

class StoreScreen extends StatefulWidget {
  final Store store;
  const StoreScreen({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  get _bloc => ProductBloc(widget.store.id!);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.store.title),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _bloc.stream,
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final l = snapshot.data!;
            return ListView.builder(
              itemCount: l.length,
              itemBuilder: (c, i) {
                final p = l[i];
                return ListTile(
                  title: Text(p.title),
                  subtitle: Text(p.approved.toString()),
                  onTap: () {
                    push(
                        context,
                        CreateProductScreen(
                          storeId: widget.store.id!,
                          product: p,
                        ));
                  },
                );
              },
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          push(
              context,
              PetCategorySectionWidget(
                storeId: widget.store.id!,
              ));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class CreateProductScreen extends StatefulWidget {
  final String storeId;
  final Product? product; //TODO: Por enquanto nao edita
  final CategoriaFilhote? category;
  const CreateProductScreen({
    Key? key,
    required this.storeId,
    this.product,
    this.category,
  }) : super(key: key);

  @override
  _CreateProductScreenState createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  late final _tTitle;
  get _bloc => ProductBloc(widget.storeId);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tTitle = TextEditingController(text: widget.product?.title);
  }

  PlatformFile? img;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create'),
      ),
      body: Column(
        children: [
          ImagePickerTileWidget(
            onChanged: (i) {
              print('trocando de img agr : $i');
              img = i;
            },
            title: 'Foto',
          ),
          TextField(
            controller: _tTitle,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Product p = Product(
            imgUrl: '',
            storeId: widget.storeId,
            title: _tTitle.text,
            category: widget.category!,
          );
          _bloc.create(img!, p);
          pop(context);
        },
        child: Icon(
          Icons.check,
        ),
      ),
    );
  }
}