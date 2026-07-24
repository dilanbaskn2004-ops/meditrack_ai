import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../services/notification_service.dart';
import 'add_medicine_screen.dart';
import 'medicine_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {
  int medicineCount = 0;
  int takenCount = 0;
  double progress = 0;
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
      medicineCount = data.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final today =
    DateFormat("dd MMMM yyyy", "tr_TR").format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("💊 MediTrack AI"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: loadMedicines,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Hoş geldin kartı
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "👋 Merhaba Dilan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    today,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Toplam ilaç kartı
            Card(
              elevation: 4,
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.medication),
                ),
                title: const Text("Toplam İlaç"),
                subtitle: Text("$medicineCount kayıtlı ilaç"),
              ),
            ),

            const SizedBox(height: 20),

            // Bugünkü ilaçlar
            const Text(
              "📅 Bugünkü İlaçlar",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            medicines.isEmpty
                ? const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Bugün için kayıtlı ilaç bulunmuyor.",
                ),
              ),
            )
                : Column(
              children: medicines.map((medicine) {
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.medication),
                    ),
                    title: Text(medicine["name"]),
                    subtitle: Text("🕒 ${medicine["time"]}"),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "📈 Günlük İlerleme",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "$takenCount / $medicineCount ilaç alındı",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "% ${(progress * 100).toStringAsFixed(0)} tamamlandı",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Kayıtlı ilaçlar
            Card(
              elevation: 4,
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.list_alt),
                ),
                title: const Text("Kayıtlı İlaçlar"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MedicineListScreen(),
                    ),
                  );

                  loadMedicines();
                },
              ),
            ),

            const SizedBox(height: 20),

            // AI önerisi
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "🤖 AI Önerisi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Henüz yeterli veri bulunmuyor.\n"
                          "İlaç kullanım alışkanlıkların analiz edilmeye başlanacak.",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Yeni ilaç ekle
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text(
                  "Yeni İlaç Ekle",
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddMedicineScreen(),
                    ),
                  );

                  loadMedicines();
                },
              ),
            ),

            const SizedBox(height: 15),

            // Bildirim testi
            OutlinedButton.icon(
              icon: const Icon(Icons.notifications),
              label: const Text("Bildirim Testi"),
              onPressed: () async {
                await NotificationService.instance.showInstantNotification(
                  title: "MediTrack AI",
                  body: "Bildirim sistemi çalışıyor 🎉",
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}