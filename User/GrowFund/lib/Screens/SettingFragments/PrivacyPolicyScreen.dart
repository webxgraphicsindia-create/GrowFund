import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final policySections = [
      {
        'title': '1. Introduction',
        'content':
        'At GrowFund, we value your privacy. This Privacy Policy outlines how we collect, use, and protect your information.'
      },
      {
        'title': '2. Information We Collect',
        'content':
        'We collect personal information like name, email, phone number, and usage data to provide better services.'
      },
      {
        'title': '3. How We Use Your Information',
        'content':
        'We use your data to personalize your experience, improve our platform, and provide customer support.'
      },
      {
        'title': '4. Data Protection',
        'content':
        'We implement strong security measures to protect your data from unauthorized access or misuse.'
      },
      {
        'title': '5. Your Rights',
        'content':
        'You can access, update, or delete your personal data anytime by contacting us at support@growfund.in.'
      },
      {
        'title': '6. Changes to This Policy',
        'content':
        'We may update this Privacy Policy occasionally. Please review it regularly to stay informed.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        centerTitle: true,
        elevation: 2,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: policySections.length,
        itemBuilder: (context, index) {
          final section = policySections[index];
          return _animatedSection(section['title']!, section['content']!, index);
        },
      ),
    );
  }

  Widget _animatedSection(String title, String content, int index) {
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
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(content, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
