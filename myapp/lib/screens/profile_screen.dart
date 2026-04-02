import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

class ProfileScreen extends StatelessWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  Future<Map<String, dynamic>> _loadStats() async {
    final db = FirebaseFirestore.instance;
    final agents = await db.collection('agents')
      .where('userId', isEqualTo: user.uid).get();
    final rentals = await db.collection('rentals')
      .where('agentOwnerId', isEqualTo: user.uid).get();
    final myRentals = await db.collection('rentals')
      .where('renterId', isEqualTo: user.uid).get();

    double earnings = 0;
    for (final r in rentals.docs) {
      earnings += (r.data()['pricePerRun'] ?? 0.0).toDouble();
    }
    return {
      'agentCount': agents.docs.length,
      'totalRentals': rentals.docs.length,
      'myRentals': myRentals.docs.length,
      'earnings': earnings,
      'rentals': rentals.docs,
    };
  }

  @override
  Widget build(BuildContext context) {
    final initials = (user.email ?? 'U')
      .substring(0, 1).toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const AppLogoWithText(),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded,
              color: AppColors.textMuted, size: 20),
            onPressed: () => FirebaseAuth.instance.signOut()),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadStats(),
        builder: (context, snapshot) {
          final stats = snapshot.data;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.bgCardBorder, width: .5)),
                  child: Row(children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.accentDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary, width: .5)),
                      child: Center(child: Text(initials,
                        style: const TextStyle(color: AppColors.accent,
                          fontSize: 22, fontWeight: FontWeight.w500)))),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email ?? 'Unknown',
                          style: const TextStyle(color: AppColors.textPrimary,
                            fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.onlineDark,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.online, width: .5)),
                          child: const Text('Agent Developer',
                            style: TextStyle(color: AppColors.online,
                              fontSize: 10, fontWeight: FontWeight.w500))),
                      ],
                    )),
                  ]),
                ),
                const SizedBox(height: 16),
                const Text('Earnings overview',
                  style: TextStyle(color: AppColors.textPrimary,
                    fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.accentDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary, width: .5)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total earnings',
                        style: TextStyle(color: AppColors.accentLight,
                          fontSize: 12)),
                      const SizedBox(height: 6),
                      isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.accent, strokeWidth: 2)
                        : Text(
                            '\$${(stats?['earnings'] ?? 0.0).toStringAsFixed(2)}',
                            style: const TextStyle(color: AppColors.accent,
                              fontSize: 36, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('From ${stats?['totalRentals'] ?? 0} rentals',
                        style: const TextStyle(color: AppColors.primary,
                          fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _StatCard(
                    icon: Icons.smart_toy_rounded,
                    label: 'My agents',
                    value: isLoading ? '-' : '${stats?['agentCount'] ?? 0}',
                    color: AppColors.accent)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(
                    icon: Icons.bolt_rounded,
                    label: 'Rented out',
                    value: isLoading ? '-' : '${stats?['totalRentals'] ?? 0}',
                    color: AppColors.online)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(
                    icon: Icons.shopping_bag_rounded,
                    label: 'I rented',
                    value: isLoading ? '-' : '${stats?['myRentals'] ?? 0}',
                    color: const Color(0xFFFAC775))),
                ]),
                const SizedBox(height: 20),
                const Text('Recent rentals',
                  style: TextStyle(color: AppColors.textPrimary,
                    fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                if (isLoading)
                  const Center(child: CircularProgressIndicator(
                    color: AppColors.accent))
                else if ((stats?['rentals'] ?? []).isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.bgCardBorder, width: .5)),
                    child: const Center(child: Text(
                      'No rentals yet. Publish agents to start earning!',
                      style: TextStyle(color: AppColors.textMuted,
                        fontSize: 13),
                      textAlign: TextAlign.center)))
                else
                  ...((stats?['rentals'] ?? []) as List).map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.bgCardBorder, width: .5)),
                      child: Row(children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.onlineDark,
                            borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.bolt_rounded,
                            color: AppColors.online, size: 18)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['agentTitle'] ?? 'Agent',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13, fontWeight: FontWeight.w500)),
                            Text(data['renterEmail'] ?? '',
                              style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 11),
                              overflow: TextOverflow.ellipsis),
                          ],
                        )),
                        Text(
                          '\$${(data['pricePerRun'] ?? 0.0).toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.online,
                            fontSize: 13, fontWeight: FontWeight.w500)),
                      ]),
                    );
                  }),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  icon: const Icon(Icons.logout_rounded,
                    color: AppColors.textMuted, size: 16),
                  label: const Text('Sign out',
                    style: TextStyle(color: AppColors.textMuted)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.bgCardBorder, width: .5),
                    padding: const EdgeInsets.symmetric(vertical: 12))),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({required this.icon, required this.label,
    required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.bgCardBorder, width: .5)),
    child: Column(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(color: color,
        fontSize: 18, fontWeight: FontWeight.w500)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: AppColors.textMuted,
        fontSize: 10)),
    ]),
  );
}
