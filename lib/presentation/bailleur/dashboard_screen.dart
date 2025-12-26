import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../presentation/provider/PropertyProvider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().loadDashboard();
    });
  }

  // Formatage des nombres avec séparateurs
  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    final number = value is String ? (int.tryParse(value) ?? 0) : value;
    return NumberFormat('#,###', 'fr_FR').format(number);
  }

  // Formatage de la devise
  String _formatCurrency(dynamic value) {
    return '${_formatNumber(value)} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Text(
                  'LUWAAS',
                  style: TextStyle(
                    color: Color(0xFF2E4B8C),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  'assets/icons/house_welcome.svg',
                  width: 23,
                  height: 23,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF2E4B8C),
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<PropertyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => provider.loadDashboard(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = provider.dashboardData ?? {};

          // 👇 AJOUTE CE PRINT POUR VOIR LES VRAIS NOMS DANS TA CONSOLE
          print("📢 DONNÉES DASHBOARD REÇUES : $data");

          // 👇 CORRECTION : On essaie le nom Flutter ET le nom Laravel (snake_case)

          // Paiements
          final paiementRecu = data['paiementRecu'] ?? data['total_paiements'] ?? data['paiements_recus'] ?? 0;

          // Compteurs Logements/Propriétés
          final nombreLogements = (data['nombreLogements'] ?? data['total_logements'] ?? data['logements_count'] ?? 0) as int;
          final nombreProprietes = (data['nombreProprietes'] ?? data['total_proprietes'] ?? data['proprietes_count'] ?? 0) as int;

          // Loyers en attente
          final loyersEnAttente = data['loyersEnAttente'] ?? data['total_loyers_attente'] ?? data['montant_attente'] ?? 0;
          final nombreLoyersEnAttente = (data['nombreLoyersEnAttente'] ?? data['count_loyers_attente'] ?? 0) as int;

          // Vacants / Occupés
          final nombreLogementsVacants = (data['nombreLogementsVacants']
              ?? data['logements_disponibles'] // 👈 Ton API envoie sûrement ça
              ?? data['disponibles']
              ?? 0) as int;

// ✅ Occupé = Occupé
          final nombreLogementsOccupes = (data['nombreLogementsOccupes']
              ?? data['logements_occupes']
              ?? data['occupes']
              ?? 0) as int;


          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadDashboard();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Card principale - Paiements reçus
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.credit_card, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Paiements reçus',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _formatNumber(paiementRecu),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'FCFA',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.credit_card_outlined,
                          color: Colors.white.withOpacity(0.3),
                          size: 40,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Grid avec aspect ratio responsive
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: constraints.maxWidth > 600 ? 1.3 : 1.0,
                        children: [
                          _buildDashboardCard(
                            icon: Icons.apartment,
                            title: 'Logements',
                            value: nombreLogements.toString(),
                          ),
                          _buildDashboardCard(
                            icon: Icons.home,
                            title: 'Propriétés',
                            value: nombreProprietes.toString(),
                          ),
                          _buildDashboardCard(
                            icon: Icons.access_time,
                            title: 'Loyers en attente',
                            subtitle: '($nombreLoyersEnAttente)',
                            value: _formatNumber(loyersEnAttente),
                            valueUnit: 'FCFA',
                            valueSize: 16,
                          ),
                          _buildDashboardCard(
                            icon: Icons.home_outlined,
                            title: 'Logements vacants',
                            value: nombreLogementsVacants.toString(),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Card pleine largeur - Logements occupés
                  _buildDashboardCard(
                    icon: Icons.home,
                    title: 'Logements occupés',
                    value: nombreLogementsOccupes.toString(),
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    String? valueUnit,
    double valueSize = 24,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 28),
            ],
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: valueSize,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (valueUnit != null) ...[
                const SizedBox(width: 4),
                Text(
                  valueUnit,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: valueSize * 0.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}