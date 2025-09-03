import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {'question': 'How do I reset my password?', 'answer': 'Go to settings > Change Password.'},
      {'question': 'How do I update my profile?', 'answer': 'Go to settings > Edit Profile.'},
      {'question': 'How can I contact support?', 'answer': 'Email us at support@example.com.'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Center"),
        centerTitle: true,
        elevation: 2,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return _animatedFAQ(faq['question']!, faq['answer']!, index);
        },
      ),
    );
  }

  Widget _animatedFAQ(String question, String answer, int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + index * 100),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(answer),
          ),
        ),
      ),
    );
  }
}
