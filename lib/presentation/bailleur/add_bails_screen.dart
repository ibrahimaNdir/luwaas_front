import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


import '../../data/model/demande.dart';
import '../../presentation/provider/BailProvider.dart';
import '../../presentation/provider/DemandeProvider.dart';
import 'package:luwaas/data/model/bails.dart';

class FormulaireBailScreen extends StatefulWidget {
  final Demande? demande; // ✅ NULLABLE maintenant

  const FormulaireBailScreen({Key? key, this.demande}) : super(key: key);

  @override
  State<FormulaireBailScreen> createState() => _FormulaireBailScreenState();
}

class _FormulaireBailScreenState extends State<FormulaireBailScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _loyerCtrl;
  late TextEditingController _nombreMoisCautionCtrl;
  late TextEditingController _chargesCtrl;
  late TextEditingController _jourEcheanceCtrl;

  DateTime? _dateDebut;
  DateTime? _dateFin;
  bool _renouvellementAuto = true;

  // ✅ POUR LE PARCOURS 2 : Demande sélectionnée
  Demande? _demandeSelectionnee;
  List<Demande> _demandesAcceptees = [];
  bool _isLoadingDemandes = false;

  @override
  void initState() {
    super.initState();

    // ✅ PARCOURS 1 : Demande fournie
    if (widget.demande != null) {
      _demandeSelectionnee = widget.demande;
      _initializeFromDemande(widget.demande!);
    }
    // ✅ PARCOURS 2 : Pas de demande, il faut charger la liste
    else {
      _loadDemandesAcceptees();
    }

    // Initialisation des dates par défaut
    _dateDebut = DateTime.now();
    _dateFin = DateTime.now().add(const Duration(days: 365));
  }

  // ✅ Charger les demandes acceptées (Parcours 2)
  Future<void> _loadDemandesAcceptees() async {
    setState(() => _isLoadingDemandes = true);

    try {
      final provider = Provider.of<DemandeProvider>(context, listen: false);
      //await provider.fetchDemandesProprietaire();

      setState(() {
        _demandesAcceptees = provider.demandes
            .where((d) => d.status == 'acceptee')
            .toList();
        _isLoadingDemandes = false;
      });
    } catch (e) {
      setState(() => _isLoadingDemandes = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // ✅ Initialiser les champs depuis une demande
  void _initializeFromDemande(Demande demande) {
    final logement = demande.logement;
    final loyer = int.tryParse(logement?['prix']?.toString() ?? '0') ?? 0;

    _loyerCtrl = TextEditingController(text: loyer.toString());
    _nombreMoisCautionCtrl = TextEditingController(text: '2');
    _chargesCtrl = TextEditingController(text: '0');
    _jourEcheanceCtrl = TextEditingController(text: '5');
  }

  @override
  void dispose() {
    _loyerCtrl.dispose();
    _nombreMoisCautionCtrl.dispose();
    _chargesCtrl.dispose();
    _jourEcheanceCtrl.dispose();
    super.dispose();
  }

  // Calculs dynamiques
  int get _cautionTotale {
    int loyer = int.tryParse(_loyerCtrl.text) ?? 0;
    int nombreMois = int.tryParse(_nombreMoisCautionCtrl.text) ?? 0;
    return loyer * nombreMois;
  }

  int get _totalMensuel {
    int loyer = int.tryParse(_loyerCtrl.text) ?? 0;
    int charges = int.tryParse(_chargesCtrl.text) ?? 0;
    return loyer + charges;
  }

  Future<void> _submitBail() async {
    // ✅ Vérifier qu'une demande est sélectionnée
    if (_demandeSelectionnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Veuillez sélectionner un locataire"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate() && _dateDebut != null && _dateFin != null) {
      final provider = Provider.of<BailProvider>(context, listen: false);

      final success = await provider.createBail(
        demandeId: _demandeSelectionnee!.id,
        montantLoyer: int.parse(_loyerCtrl.text),
        nombreMoisCaution: int.parse(_nombreMoisCautionCtrl.text),
        chargesMensuelles: int.parse(_chargesCtrl.text),
        dateDebut: _dateDebut!,
        dateFin: _dateFin!,
        jourEcheance: int.parse(_jourEcheanceCtrl.text),
        renouvellementAuto: _renouvellementAuto,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Bail créé avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? "❌ Erreur inconnue"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Créer un Bail"),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
      ),
      body: _isLoadingDemandes
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ✅ PARCOURS 2 : Sélecteur de locataire
              if (widget.demande == null) ...[
                _buildSectionTitle(Icons.person_search, "Sélectionner un locataire"),
                const SizedBox(height: 10),
                _buildDemandeDropdown(),
                const SizedBox(height: 20),
              ],

              // ✅ SECTIONS PRÉ-REMPLIES (affichées après sélection)
              if (_demandeSelectionnee != null) ...[
                _buildSectionTitle(Icons.home_outlined, "Logement"),
                _buildInfoCard(
                  title: _demandeSelectionnee!.logement?['titre'] ?? "Logement",
                  subtitle: _demandeSelectionnee!.logement?['adresse'] ?? "Adresse",
                  details: [
                    "Prix affiché : ${_demandeSelectionnee!.logement?['prix'] ?? 0} FCFA",
                  ],
                ),
                const SizedBox(height: 20),

                _buildSectionTitle(Icons.person_outline, "Locataire"),
                _buildInfoCard(
                  title: _demandeSelectionnee!.locataire?['name'] ?? "Locataire",
                  subtitle: _demandeSelectionnee!.locataire?['telephone'] ?? "Téléphone",
                  details: ["Dossier validé"],
                ),
                const SizedBox(height: 20),

                // CONDITIONS FINANCIÈRES
                _buildSectionTitle(Icons.monetization_on_outlined, "Conditions Financières"),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(child: _buildInput("Loyer mensuel", _loyerCtrl)),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildInput(
                        "Caution (nb mois)",
                        _nombreMoisCautionCtrl,
                        suffix: "mois",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(child: _buildInput("Charges mensuelles", _chargesCtrl)),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Caution totale",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              border: Border.all(color: Colors.green),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "$_cautionTotale FCFA",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "Total mensuel : $_totalMensuel FCFA",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // DURÉE DU BAIL
                const Text(
                  "Durée du bail",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                _buildDatePicker("Date de Début", _dateDebut, true),
                const SizedBox(height: 10),
                _buildDatePicker("Date de Fin", _dateFin, false),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                        "Jour d'échéance",
                        _jourEcheanceCtrl,
                        suffix: "du mois",
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Renouvellement auto",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(_renouvellementAuto ? "OUI" : "NON"),
                            value: _renouvellementAuto,
                            activeColor: const Color(0xFF1E3A8A),
                            onChanged: (val) => setState(() => _renouvellementAuto = val),
                          ),
                        ],
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 30),

                // BOUTONS
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Annuler"),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 2,
                      child: Consumer<BailProvider>(
                        builder: (context, provider, _) {
                          return ElevatedButton.icon(
                            onPressed: provider.isCreating ? null : _submitBail,
                            icon: provider.isCreating
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Icon(Icons.check_circle_outline),
                            label: Text(
                              provider.isCreating ? "Création..." : "Créer le Bail",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Dropdown pour sélectionner une demande (Parcours 2)
  Widget _buildDemandeDropdown() {
    if (_demandesAcceptees.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "⚠️ Aucune demande acceptée disponible.\nAcceptez d'abord une demande depuis l'écran Demandes.",
          style: TextStyle(color: Colors.orange),
        ),
      );
    }

    return DropdownButtonFormField<Demande>(
      decoration: InputDecoration(
        labelText: "Choisir un locataire",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      value: _demandeSelectionnee,
      items: _demandesAcceptees.map((demande) {
        return DropdownMenuItem<Demande>(
          value: demande,
          child: Text(
            "${demande.locataire?['name'] ?? 'Locataire'} - ${demande.logement?['titre'] ?? 'Logement'}",
          ),
        );
      }).toList(),
      onChanged: (Demande? demande) {
        if (demande != null) {
          setState(() {
            _demandeSelectionnee = demande;
            _initializeFromDemande(demande);
          });
        }
      },
      validator: (val) => val == null ? "Veuillez sélectionner un locataire" : null,
    );
  }

  // Widgets helper (inchangés)
  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1E3A8A)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required List<String> details,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
          ),
          ...details.map((d) => Padding(
            padding: const EdgeInsets.only(left: 28, top: 4),
            child: Text(
              "✓ $d",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildInput(
      String label,
      TextEditingController controller, {
        String suffix = "FCFA",
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (val) => setState(() {}),
          decoration: InputDecoration(
            suffixText: suffix,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          validator: (val) {
            if (val == null || val.isEmpty) return "Requis";
            if (int.tryParse(val) == null) return "Nombre invalide";
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, bool isDebut) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickDate(isDebut),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Text(
              date != null ? DateFormat('dd/MM/yyyy').format(date) : "Choisir une date",
              style: TextStyle(color: date != null ? Colors.black : Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(bool isDebut) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDebut ? (_dateDebut ?? DateTime.now()) : (_dateFin ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isDebut) {
          _dateDebut = picked;
          if (_dateFin == null || _dateFin!.isBefore(picked)) {
            _dateFin = picked.add(const Duration(days: 365));
          }
        } else {
          _dateFin = picked;
        }
      });
    }
  }
}