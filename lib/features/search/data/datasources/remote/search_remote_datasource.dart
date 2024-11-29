import 'package:cloud_firestore/cloud_firestore.dart';

class SearchRemoteDataSource {
  final FirebaseFirestore firestore;

  SearchRemoteDataSource({required this.firestore});

  Stream<QuerySnapshot> fetchUsers() {
    return firestore.collection('users').snapshots();
  }

  Stream<QuerySnapshot> fetchVideos() {
    return firestore.collection('videos').snapshots();
  }

  Stream<QuerySnapshot> fetchHashtags() {
    return firestore.collection('hashtags').snapshots();
  }

  Future<void> saveSearchQuery(String query) async {
    await firestore.collection('searches').add({
      'query': query,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSearchQuery(String query) async {
    final snapshots = await firestore
        .collection('searches')
        .where('query', isEqualTo: query)
        .get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }
}
