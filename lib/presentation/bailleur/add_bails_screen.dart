import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


import '../../data/model/demande.dart';
import '../../presentation/provider/BailProvider.dart';
import 'package:luwaas/data/model/bails.dart';

class FormulaireBailScreen extends StatefulWidget {
  final Demande demande;

  const FormulaireBailScreen({Key? key, required this.demande}) : super(key: key);

  @override
  State<FormulaireBailScreen> createState() => _FormulaireBailScreenState();
}

class _FormulaireBailScreenState extends State<FormulaireBailScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs modifiables
  late TextEditingController _loyerCtrl;
  late TextEditingController _cautionCtrl;
  late TextEditingController _chargesCtrl;
  late TextEditingController _cautionsPayerCtrl;
  late TextEditingController _jourEcheanceCtrl;

  // Dates
  DateTime? _dateDebut;
  DateTime? _dateFin;

  // Options
  bool _renouvellementAuto = true;

  @override
  void initState() {
    super.initState();
    final logement = widget.demande.logement;

    // --- LOGIQUE DYNAMIQUE : PRÉ-REMPLISSAGE ---

    // Le loyer vient du logement
    _loyerCtrl = TextEditingController(text: logement?['prix']?.toString() ?? '0');

    // Par défaut, la caution est souvent = 2 mois de loyer (exemple)
    int loyer = int.tryParse(logement?['prix']?.toString() ?? '0') ?? 0;
    _cautionCtrl = TextEditingController(text: (loyer * 2).toString());

    // Charges à 0 par défaut
    _chargesCtrl = TextEditingController(text: '0');

    // Caution à payer maintenant (souvent la totalité)
    _cautionsPayerCtrl = TextEditingController(text: (loyer * 2).toString());

    // Jour d'échéance standard (le 5 du mois)
    _jourEcheanceCtrl = TextEditingController(text: '5');

    // Dates par défaut (Début aujourd'hui, Fin dans 1 an)
    _dateDebut = DateTime.now();
    _dateFin = DateTime.now().add(const Duration(days: 365));
  }

  @override
  void dispose() {
    _loyerCtrl.dispose();
    _cautionCtrl.dispose();
    _chargesCtrl.dispose();
    _cautionsPayerCtrl.dispose();
    _jourEcheanceCtrl.dispose();
    super.dispose();
  }

  // Calcul du total mensuel dynamique
  int get _totalMensuel {
    int loyer = int.tryParse(_loyerCtrl.text) ?? 0;
    int charges = int.tryParse(_chargesCtrl.text) ?? 0;
    return loyer + charges;
  }

  // Sélecteur de date
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
          // Astuce : Si on change le début, on repousse la fin auto à +1 an
          if (_dateFin == null || _dateFin!.isBefore(picked)) {
            _dateFin = picked.add(const Duration(days: 365));
          }
        } else {
          _dateFin = picked;
        }
      });
    }
  }

  // Action : CRÉER LE BAIL
  Future<void> _submitBail() async {
    if (_formKey.currentState!.validate() && _dateDebut != null && _dateFin != null) {

      final provider = Provider.of<BailProvider>(context, listen: false);

      final success = await provider.createBail(
        logementId: widget.demande.logementId,
        locataireId: widget.demande.locataireId,
        demandeId: widget.demande.id, // On lie à la demande
        montantLoyer: int.parse(_loyerCtrl.text),
        caution: int.parse(_cautionCtrl.text),
        charges: int.parse(_chargesCtrl.text),
        cautionsPayer: int.parse(_cautionsPayerCtrl.text),
        dateDebut: _dateDebut!,
        dateFin: _dateFin!,
        jourEcheance: int.parse(_jourEcheanceCtrl.text),
        renouvellementAuto: _renouvellementAuto,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bail créé avec succès !"), backgroundColor: Colors.green),
        );
        // Ici on pourrait rediriger vers l'écran de visualisation du bail pour l'imprimer
        Navigator.pop(context);
        Navigator.pop(context); // Retour double vers l'accueil ou la liste
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? "Erreur inconnue"), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs et dates"), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Récupération des données pour l'affichage (Lecture seule)
    final logementInfo = widget.demande.logement;
    final locataireInfo = widget.demande.locataire;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Créer un Bail"),
        backgroundColor: const Color(0xFF1E3A8A), // Bleu Luwaas
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 1. SECTION LOGEMENT (Lecture Seule)
              _buildSectionTitle(Icons.home_outlined, "Logement"),
              _buildInfoCard(
                title: logementInfo?['titre'] ?? "Appartement",
                subtitle: "${logementInfo?['adresse'] ?? 'Adresse inconnue'}",
                details: ["${logementInfo?['superficie'] ?? 0} m²", "Immeuble Kebe"], // Exemple statique ou dynamique
              ),

              const SizedBox(height: 20),

              // 2. SECTION LOCATAIRE (Lecture Seule)
              _buildSectionTitle(Icons.person_outline, "Locataire"),
              _buildInfoCard(
                title: locataireInfo?['name'] ?? "Nom Inconnu",
                subtitle: locataireInfo?['telephone'] ?? "Pas de numéro",
                details: ["Dossier Validé"],
              ),

              const SizedBox(height: 20),

              // 3. CONDITIONS FINANCIERES
              _buildSectionTitle(Icons.monetization_on_outlined, "Condition Financière"),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: _buildInput("Loyer mensuel", _loyerCtrl)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInput("Cautions Total", _cautionCtrl)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildInput("Charges mensuel", _chargesCtrl)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInput("Caution à Payer", _cautionsPayerCtrl)),
                ],
              ),

              const SizedBox(height: 20),

              // PILLULE TOTAL (Calculé dynamiquement)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "Total mensuel : ${_totalMensuel} FCFA",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // 4. DURÉE DU BAIL
              const Text("Durée du bail", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              _buildDatePicker("Date de Début", _dateDebut, true),
              const SizedBox(height: 10),
              _buildDatePicker("Date de Fin", _dateFin, false),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _buildInput("Jour Echeance", _jourEcheanceCtrl, isNumber: true),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Renouvellement", style: TextStyle(fontWeight: FontWeight.bold)),
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

              const SizedBox(height: 10),

              // Message informatif bas (Bleu clair)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF1E3A8A)),
                    const SizedBox(width: 10),
                    Text(
                      _dateFin != null
                          ? "Fin du bail : ${DateFormat('dd MMMM yyyy').format(_dateFin!)}"
                          : "Sélectionnez une date",
                      style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // BOUTONS ACTIONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Annuler", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Consumer<BailProvider>(
                      builder: (context, provider, _) {
                        return ElevatedButton(
                          onPressed: provider.isCreating ? null : _submitBail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: provider.isCreating
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("Créer Bail", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // BOUTON IMPRIMER (Vert) - Désactivé tant que pas créé, ou alors on le met juste pour le design
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Logique future : Appeler l'export PDF
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Veuillez d'abord créer le bail pour l'imprimer.")),
                    );
                  },
                  icon: const Icon(Icons.print, color: Colors.white),
                  label: const Text("Imprimer le Bail", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10893E), // Vert Excel/Print
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS HELPER POUR LE STYLE ---

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1E3A8A)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required String subtitle, required List<String> details}) {
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
              const Icon(Icons.check, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
          ),
          ...details.map((d) => Padding(
            padding: const EdgeInsets.only(left: 28, top: 4),
            child: Text("✓ $d", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          )),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {bool isNumber = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          onChanged: (val) => setState(() {}), // Pour mettre à jour le total en temps réel
          decoration: InputDecoration(
            suffixText: isNumber ? "FCFA" : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
          validator: (val) => val!.isEmpty ? "Requis" : null,
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
}
