import 'package:cloud_firestore/cloud_firestore.dart';

class Store {
  //TODO: Add referencia
  String title;
  String instagram;
  String phone;

  String? id;
  Store({
    required this.title,
    required this.instagram,
    required this.phone,
    this.id,
  });
  toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['instagram'] = this.instagram;
    data['phone'] = this.phone;
    return data;
  }

  Store.fromSnap(DocumentSnapshot<Map<String, dynamic>> snap)
      : this(
          title: snap.data()!['title'],
          instagram: snap.data()!['instagram'],
          phone: snap.data()!['phone'],
          id: snap.reference.id,
        );
}

class StoreFirebase {
  //TODO: Renomear para 'store'

  static final String collectionPath = 'stores';

  final ref = FirebaseFirestore.instance.collection(collectionPath).withConverter<Store>(
        fromFirestore: (snapshot, _) => Store.fromSnap(snapshot),
        toFirestore: (model, _) => model.toMap(),
      );

  create(Store s) => ref.add(s);

//Precisa ser stream? nao, pode ser future, mas stream eh sempre melhor pelo padrao bloc
  Stream<List<Store>> read() =>
      ref.snapshots().map((s) => s.docs.map((e) => e.data()).toList());

  update(Store s) => ref.doc(s.id).update(s.toMap());

  delete(String id) => ref.doc(id).delete();
}
