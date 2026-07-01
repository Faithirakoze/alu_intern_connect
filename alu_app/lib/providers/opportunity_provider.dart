import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/opportunity.dart';

final opportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  return FirebaseFirestore.instance
      .collection('opportunities')
      .where('isOpen', isEqualTo: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((doc) => Opportunity.fromFirestore(doc)).toList());
});