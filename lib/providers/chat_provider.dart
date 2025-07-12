import 'package:cloud_firestore/cloud_firestore.dart';

class ChatProvider {
  void sendMessage(String chatId, String senderId, String text) {
    FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .add({
        'senderId': senderId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
        'seen': false,
      });
  }
} 