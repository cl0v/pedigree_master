import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:master/app/repositories/store_repository.dart';


class Categoria {
  String category;
  String breed;

  Categoria({required this.category, required this.breed});

  Categoria.fromJson(Map<String, dynamic> json)
      : this(
          category: json['category'],
          breed: json['breed'],
        );

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category'] = this.category;
    data['breed'] = this.breed;
    return data;
  }
}

class Product {
  //TODO: Add referencia
  String storeId;
  String title;
  String imgUrl;
  bool approved;
  Categoria category;
  String id;
  Product({
    required this.title,
    required this.category,
    required this.storeId,
    this.imgUrl = '',
    this.approved = true,
    this.id = '',
  });

  toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['approved'] = this.approved;
    data['storeId'] = this.storeId;
    data['title'] = this.title;
    data['imgUrl'] = this.imgUrl;
    data['category'] = this.category.toMap();
    return data;
  }

  Product.fromSnap(DocumentSnapshot<Map<String, dynamic>> snap)
      : this(
          approved: snap.data()!['approved'],
          storeId: snap.data()!['storeId'],
          title: snap.data()!['title'],
          imgUrl: snap.data()!['imgUrl'],
          category: Categoria.fromJson(snap.data()!['category']),
          id: snap.reference.id,
        );
}

class ProductFirebase {
  static final String collectionPath = 'products';

  final ref = FirebaseFirestore.instance
      .collection(collectionPath)
      .withConverter<Product>(
        fromFirestore: (snapshot, _) => Product.fromSnap(snapshot),
        toFirestore: (model, _) => model.toMap(),
      );

  create(Img img, Product p) async {
    ref.add(p).then((r) => ImgUploader(p: p).uploadFoto(r, img));
  }

  Stream<List<Product>> read(String storeId) => ref
      .where('storeId', isEqualTo: storeId)
      .snapshots()
      .map((p) => p.docs.map((e) => e.data()).toList());

  update(Product p) => ref.doc(p.id).update(p.toMap());

  delete(String id) => ref.doc(id).delete();
}

class Img {
  String nome;
  Uint8List? fileUnit;

  Img({
    required this.nome,
    required this.fileUnit,
  });
}

class ImgUploader {
  Product p;
  ImgUploader({
    required this.p,
  });

  uploadFoto(
    DocumentReference docRef,
    Img foto,
  ) async {
    var ref = FirebaseStorage.instance
        .ref()
        .child(StoreFirebase.collectionPath)
        .child(p.storeId)
        .child('products')
        .child(docRef.id)
        .child(foto.nome);
    //TODO: Implementar envio de imagem

    //https://pub.dev/packages/file_picker
    SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');
    await ref.putData(foto.fileUnit!, metadata).whenComplete(() async {
      print(await ref.getDownloadURL());
      await docRef.update({'imgUrl': await ref.getDownloadURL()});
    });
  }
// import 'package:path/path.dart' as p;
//  nome: p.extension(result.files.single.name),

}
