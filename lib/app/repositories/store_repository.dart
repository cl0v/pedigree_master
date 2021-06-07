import 'package:cloud_firestore/cloud_firestore.dart';

class Store {
  static final String pTitle = 'title';
  static final String pPhone = 'phone';
  static final String pInstagram = 'instagram';
  

  //TODO: Add referencia
  String? id;
  String title;
  String phone;
  String instagram;

  Store({
    required this.title,
    required this.phone,
    required this.instagram,
    this.id,
  });
  toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[pTitle] = this.title;
    data[pPhone] = this.phone;
    data[pInstagram] = this.instagram;
    return data;
  }

  Store.fromSnap(DocumentSnapshot<Map<String, dynamic>> snap)
      : this(
          title: snap.data()![pTitle],
          phone: snap.data()![pPhone],
          instagram: snap.data()![pInstagram],
          id: snap.reference.id,
        );
}

class StoreFirebase {
  //TODO: Renomear para 'store'

  static final String collectionPath = 'stores';

  final ref = FirebaseFirestore.instance
      .collection(collectionPath)
      .withConverter<Store>(
        fromFirestore: (snapshot, _) => Store.fromSnap(snapshot),
        toFirestore: (model, _) => model.toMap(),
      );

  create(Store s) => ref.add(s);

//Precisa ser stream? nao, pode ser future, mas stream eh sempre melhor pelo padrao bloc
  Stream<List<Store>> readAll() => ref.snapshots().map((s) => s.docs.map((e) {
        print(e.reference.id);
        return e.data();
      }).toList());

  update(Store s) => ref.doc(s.id).update(s.toMap());

  delete(String id) => ref.doc(id).delete();
}
