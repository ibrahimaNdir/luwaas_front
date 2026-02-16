import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../presentation/provider/auth_provider.dart';
import '../../presentation/provider/BailProvider.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer2<AuthProvider, BailProvider>(
        builder: (context, authProvider, bailProvider, child) {
          final user = authProvider.user;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Stats baux (exemple : adapte selon tes données)
          //final bauxActifs = bailProvider.bauxLocataire.where((b) => b.statut == 'actif').length;
          //final loyersPayes = bailProvider.bauxLocataire.fold(0, (sum, b) => sum + (b.paiementsPayes ?? 0));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                // Header Profil
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF1E3E8A), const Color(0xFF2C4FA1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, size: 60, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "${user.prenom ?? ''} ${user.nom ?? ''}".trim(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        user.email ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Text(
                        "Locataire",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Stats Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 1.4,
                  children: [
                    _StatCard(
                      icon: Icons.home,
                      label: "Baux Actifs",
                      value: '',
                      color: const Color(0xFF1E3E8A),
                    ),
                    _StatCard(
                      icon: Icons.payments,
                      label: "Loyers Payés",
                      value: '',
                      color: const Color(0xFF10B981),
                    ),
                    _StatCard(
                      icon: Icons.notifications,
                      label: "Notifications",
                      value: '12', // Remplace par NotificationProvider.unreadCount
                      color: Colors.orange,
                    ),
                    _StatCard(
                      icon: Icons.payment,
                      label: "Prochain Loyer",
                      value: '05/02/26', // Date du prochain
                      color: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Actions
                _ActionButton(
                  icon: Icons.edit,
                  label: "Modifier Profil",
                  onTap: () => _showEditDialog(context),
                ),
                _ActionButton(
                  icon: Icons.history,
                  label: "Historique Paiements",
                  onTap: () => Navigator.pushNamed(context, '/paiements'),
                ),
                _ActionButton(
                  icon: Icons.logout,
                  label: "Déconnexion",
                  color: Colors.red,
                  onTap: () => _logout(context, authProvider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    // TODO: Dialog pour éditer nom/tel (update Firestore)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modifier Profil"),
        content: const Text("Fonctionnalité à implémenter"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Sauvegarder")),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, AuthProvider authProvider) async {
    await authProvider.logout();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color ?? const Color(0xFF1E3E8A), child: Icon(icon, color: Colors.white)),
        title: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: Colors.grey[50],
        onTap: onTap,
      ),
    );
  }
}
