import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';

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
    final data = await DatabaseHelper.instance.getMedicines();

    if (!mounted) return;

    setState(() {
      medicines = data;
    });
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
      await NotificationService.instance.cancelNotification(id);
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

  Future<void> toggleTaken(Map<String, dynamic> medicine) async {
    if (medicine["taken"] == 1) {
      await DatabaseHelper.instance.markMedicineNotTaken(medicine["id"]);
    } else {
      await DatabaseHelper.instance.markMedicineTaken(medicine["id"]);
    }

    loadMedicines();
  }

  Widget buildMedicineCard(Map<String, dynamic> medicine) {
    final bool taken = medicine["taken"] == 1;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      color: taken ? Colors.green.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medication,
                  color: taken ? Colors.green : Colors.blue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    medicine["name"],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: taken ? Colors.green : Colors.black,
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
              "📝 Not : ${medicine["notes"]?.toString().isNotEmpty == true ? medicine["notes"] : "-"}",
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(
                    medicine["isActive"] == 1
                        ? Icons.check_circle
                        : Icons.cancel,
                    size: 18,
                  ),
                  label: Text(
                    medicine["isActive"] == 1 ? "Aktif" : "Pasif",
                  ),
                ),
                Chip(
                  backgroundColor:
                  taken ? Colors.green.shade100 : Colors.orange.shade100,
                  avatar: Icon(
                    taken ? Icons.check : Icons.schedule,
                    size: 18,
                  ),
                  label: Text(
                    taken ? "Alındı" : "Alınmadı",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      taken ? Colors.orange : Colors.green,
                    ),
                    onPressed: () => toggleTaken(medicine),
                    icon: Icon(
                      taken ? Icons.undo : Icons.check,
                      color: Colors.white,
                    ),
                    label: Text(
                      taken ? "Geri Al" : "Aldım",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => deleteMedicine(medicine["id"]),
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
          style: TextStyle(fontSize: 18),
        ),
      )
          : RefreshIndicator(
        onRefresh: loadMedicines,
        child: ListView.builder(
          itemCount: medicines.length,
          itemBuilder: (context, index) {
            return buildMedicineCard(medicines[index]);
          },
        ),
      ),
    );
  }
}