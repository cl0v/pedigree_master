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
  static final String pTitle = 'title';
  static final String pImgUrl = 'imgUrl';
  static final String pCategory = 'category';
  static final String pApproved = 'approved';
  static final String pStoreId = 'storeId';

  //TODO: Add referencia
  String id;
  String title;
  String imgUrl;
  Categoria category;
  bool approved;
  String storeId;
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
    data[pTitle] = this.title;
    data[pImgUrl] = this.imgUrl;
    data[pCategory] = this.category.toMap();
    data[pApproved] = this.approved;
    data[pStoreId] = this.storeId;
    return data;
  }

  Product.fromSnap(DocumentSnapshot<Map<String, dynamic>> snap)
      : this(
          title: snap.data()![pTitle],
          imgUrl: snap.data()![pImgUrl],
          category: Categoria.fromJson(snap.data()![pCategory]),
          approved: snap.data()![pApproved],
          storeId: snap.data()![pStoreId],
          id: snap.reference.id,
        );
}

class ProductFirebase {
  static final String collectionPath = 'products';

//TODO: Make ref private
  final _ref = FirebaseFirestore.instance
      .collection(collectionPath)
      .withConverter<Product>(
        fromFirestore: (snapshot, _) => Product.fromSnap(snapshot),
        toFirestore: (model, _) => model.toMap(),
      );

  create(Img img, Product p) async {
    _ref.add(p).then((r) => ImgUploader(p: p).uploadFoto(r, img));
  }

//TODO: Rename to readAll
  Stream<List<Product>> readAll(String storeId) {
    print(storeId);
    return _ref
        .where(Product.pStoreId, isEqualTo: storeId)
        .snapshots()
        .map((p) => p.docs.map((e) => e.data()).toList());
  }

  update(Product p) => _ref.doc(p.id).update(p.toMap());

  delete(String id) => _ref.doc(id).delete();
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
      await docRef.update({'imgUrl': await ref.getDownloadURL()});
    });
  }
// import 'package:path/path.dart' as p;
//  nome: p.extension(result.files.single.name),

}
