import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match.dart';

class MatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> joinContest({
    required String userId,
    required Match match,
  }) async {
    final matchRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('matches')
        .doc(match.id);
    final doc = await matchRef.get();
    if (doc.exists) {
      // If match already exists, update status to 'upcoming' (or keep existing status if more advanced logic needed)
      await matchRef.update({
        'status': 'upcoming',
        'startTime': match.startTime.toIso8601String(),
        'endTime': match.endTime?.toIso8601String(),
        'name': match.name,
        'type': match.type,
        'category': match.category,
      });
    } else {
      // If match does not exist, add it
      await matchRef.set({
        'id': match.id,
        'name': match.name,
        'type': match.type,
        'category': match.category,
        'startTime': match.startTime.toIso8601String(),
        'endTime': match.endTime?.toIso8601String(),
        'status': 'upcoming',
        'score': match.score,
      });
    }
  }

  Future<List<Match>> fetchUserMatches(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('matches')
        .get();
    return snapshot.docs.map((doc) => Match.fromJson(doc.data())).toList();
  }

  Future<void> updateMatchStatus({
    required String userId,
    required String matchId,
    required String status,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('matches')
        .doc(matchId)
        .update({'status': status});
  }
} 