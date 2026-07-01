import 'package:cloud_firestore/cloud_firestore.dart';

class Opportunity {
  final String id;
  final String title;
  final String startupName;
  final String category;
  final List<String> skills;
  final String commitmentType; // 'Part-time' or 'Full-time'
  final String locationType;   // 'Remote', 'On-campus', 'Hybrid'
  final String description;
  final DateTime postedAt;

  Opportunity({
    required this.id,
    required this.title,
    required this.startupName,
    required this.category,
    required this.skills,
    required this.commitmentType,
    required this.locationType,
    required this.description,
    required this.postedAt,
  });

  // Convert Firestore document → Opportunity object
  factory Opportunity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Opportunity(
      id: doc.id,
      title: data['title'] ?? '',
      startupName: data['startupName'] ?? '',
      category: data['category'] ?? 'Other',
      skills: List<String>.from(data['skills'] ?? []),
      commitmentType: data['commitmentType'] ?? 'Part-time',
      locationType: data['locationType'] ?? 'On-campus',
      description: data['description'] ?? '',
      postedAt: (data['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert Opportunity object → Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'startupName': startupName,
      'category': category,
      'skills': skills,
      'commitmentType': commitmentType,
      'locationType': locationType,
      'description': description,
      'postedAt': Timestamp.fromDate(postedAt),
      'isOpen': true,
    };
  }
}