import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? db,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp(String email, String password, String name) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) return;

    await user.updateDisplayName(name);

    final newUser = AppUser(
      id: user.uid,
      email: email,
      name: name,
      currentFamilyId: null,
      createdAt: DateTime.now(),
    );

    // Blindado: usa merge para não depender de doc pré-existente
    await _db.collection('users').doc(user.uid).set(
          newUser.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<AppUser?> userDocStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    });
  }
}
