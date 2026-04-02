import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/agent_model.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

class AgentDetailScreen extends StatefulWidget {
  final AgentModel agent;
  const AgentDetailScreen({super.key, required this.agent});
  @override
  State<AgentDetailScreen> createState() => _AgentDetailScreenState();
}

class _AgentDetailScreenState extends State<AgentDetailScreen> {
  bool _isRenting = false;
  bool _hasRented = false;

  Future<void> _rentAgent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _isRenting = true);
    try {
      await FirebaseFirestore.instance.collection('rentals').add({
        'agentId': widget.agent.id,
        'agentTitle': widget.agent.title,
        'agentOwnerId': widget.agent.userId,
        'renterId': user.uid,
        'renterEmail': user.email,
        'pricePerRun': widget.agent.pricePerRun,
        'status': 'active',
        'rentedAt': DateTime.now().toIso8601String(),
      });
      await FirebaseFirestore.instance
        .collection('agents')
        .doc(widget.agent.id)
        .update({'totalRuns': FieldValue.increment(1)});
      setState(() => _hasRented = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Agent rented successfully!'),
          backgroundColor: AppColors.online));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to rent. Try again.'),
          backgroundColor: Colors.redAccent));
      }
    }
    setState(() => _isRenting = false);
  }

  @override
  Widget build(BuildContext context) {
    final agent = widget.agent;
    final isOwner = FirebaseAuth.instance.currentUser?.uid == agent.userId;

    final categoryIcons = {
      'Research': Icons.manage_search_rounded,
      'Code': Icons.code_rounded,
      'Data': Icons.bar_chart_rounded,
      'Writing': Icons.edit_note_rounded,
      'Other': Icons.auto_awesome_rounded,
    };
    final icon = categoryIcons[agent.category] ?? Icons.auto_awesome_rounded;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
            color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context)),
        title: const AppLogoWithText(),
        actions: [
          if (isOwner)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accentDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary, width: .5),
              ),
              child: const Text('Your agent',
                style: TextStyle(color: AppColors.accentLight,
                  fontSize: 11, fontWeight: FontWeight.w500))),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.bgCardBorder, width: .5),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.accentDark,
                    borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: AppColors.accent, size: 26)),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(agent.title,
                    style: const TextStyle(color: AppColors.textPrimary,
                      fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentDark,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primary, width: .5)),
                    child: Text(agent.category,
                      style: const TextStyle(color: AppColors.accentLight,
                        fontSize: 11, fontWeight: FontWeight.w500))),
                ])),
              ]),
              const SizedBox(height: 20),
              Row(children: [
                _StatChip(icon: Icons.star_rounded,
                  value: agent.rating.toStringAsFixed(1),
                  label: 'Rating',
                  color: const Color(0xFFFAC775)),
                const SizedBox(width: 10),
                _StatChip(icon: Icons.play_circle_rounded,
                  value: '${agent.totalRuns}',
                  label: 'Total runs',
                  color: AppColors.accent),
                const SizedBox(width: 10),
                _StatChip(icon: Icons.attach_money_rounded,
                  value: '\$${agent.pricePerRun.toStringAsFixed(2)}',
                  label: 'Per run',
                  color: AppColors.online),
              ]),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('About this agent',
                style: TextStyle(color: AppColors.textPrimary,
                  fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Text(agent.description,
                style: const TextStyle(color: AppColors.textSecondary,
                  fontSize: 14, height: 1.6)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.bgCardBorder, width: .5)),
                child: Column(children: [
                  _InfoRow(label: 'Category', value: agent.category),
                  const Divider(color: AppColors.bgCardBorder, height: 20, thickness: .5),
                  _InfoRow(label: 'Price per run',
                    value: '\$${agent.pricePerRun.toStringAsFixed(2)} USD'),
                  const Divider(color: AppColors.bgCardBorder, height: 20, thickness: .5),
                  _InfoRow(label: 'Total runs', value: '${agent.totalRuns} runs'),
                  const Divider(color: AppColors.bgCardBorder, height: 20, thickness: .5),
                  _InfoRow(label: 'Rating',
                    value: '${agent.rating.toStringAsFixed(1)} / 5.0'),
                ]),
              ),
              const SizedBox(height: 20),
              if (!isOwner) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.onlineDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.online, width: .5)),
                  child: Row(children: [
                    const Icon(Icons.info_outline_rounded,
                      color: AppColors.online, size: 16),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      'You will be charged \$${agent.pricePerRun.toStringAsFixed(2)} per run. Cancel anytime.',
                      style: const TextStyle(color: AppColors.online,
                        fontSize: 12, height: 1.4))),
                  ]),
                ),
                const SizedBox(height: 100),
              ] else
                const SizedBox(height: 20),
            ]),
          ),
        ]),
      ),
      bottomNavigationBar: isOwner ? null : Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: const BoxDecoration(
          color: AppColors.bgDeep,
          border: Border(top: BorderSide(color: AppColors.bgCardBorder, width: .5))),
        child: _hasRented
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.onlineDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.online, width: .5)),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.check_circle_rounded, color: AppColors.online, size: 18),
                SizedBox(width: 8),
                Text('Agent rented — active',
                  style: TextStyle(color: AppColors.online,
                    fontSize: 15, fontWeight: FontWeight.w500)),
              ]))
          : ElevatedButton.icon(
              onPressed: _isRenting ? null : _rentAgent,
              icon: _isRenting
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(
                      color: AppColors.accentLight, strokeWidth: 2))
                : const Icon(Icons.bolt_rounded, size: 18),
              label: Text(
                _isRenting ? 'Processing...'
                  : 'Rent agent — \$${agent.pricePerRun.toStringAsFixed(2)}/run',
                style: const TextStyle(fontSize: 15))),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _StatChip({required this.icon, required this.value,
    required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.bgDeep,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.bgCardBorder, width: .5)),
    child: Column(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(color: color,
        fontSize: 14, fontWeight: FontWeight.w500)),
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
    ]),
  ));
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(children: [
    Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
    const Spacer(),
    Text(value, style: const TextStyle(color: AppColors.textPrimary,
      fontSize: 13, fontWeight: FontWeight.w500)),
  ]);
}
