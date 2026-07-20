import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  List<Map<String, dynamic>> medicines = [];

  @override
  void initState() {
    super.initState();
    loadMedicines();
  }

  Future<void> loadMedicines() async {
    medicines = await DatabaseHelper.instance.getMedicines();

    if (!mounted) return;

    setState(() {});
  }

  Future<void> deleteMedicine(int id) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("İlacı Sil"),
          content: const Text(
            "Bu ilacı silmek istediğinize emin misiniz?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Hayır"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Evet"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await DatabaseHelper.instance.deleteMedicine(id);

      await loadMedicines();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("İlaç silindi."),
        ),
      );
    }
  }

  Widget buildMedicineCard(Map<String, dynamic> medicine) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                const Icon(
                  Icons.medication,
                  color: Colors.blue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    medicine["name"],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Text("💊 Doz : ${medicine["dose"]}"),
            Text("🕒 Saat : ${medicine["time"]}"),
            Text("📅 Başlangıç : ${medicine["startDate"]}"),
            Text("📅 Bitiş : ${medicine["endDate"]}"),
            Text("🔄 Günde : ${medicine["timesPerDay"]} kez"),

            const SizedBox(height: 8),

            Text(
              "📝 Not : ${medicine["notes"]}",
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Chip(
                  label: Text(
                    medicine["isActive"] == 1
                        ? "Aktif"
                        : "Pasif",
                  ),
                ),

                const Spacer(),

                IconButton(
                  onPressed: () {
                    deleteMedicine(medicine["id"]);
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kayıtlı İlaçlar"),
      ),

      body: medicines.isEmpty
          ? const Center(
        child: Text(
          "Henüz ilaç eklenmedi.",
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      )
          : ListView.builder(
        itemCount: medicines.length,
        itemBuilder: (context, index) {
          return buildMedicineCard(
            medicines[index],
          );
        },
      ),
    );
  }
}