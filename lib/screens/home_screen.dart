import 'package:flutter/material.dart';
import 'add_medicine_screen.dart';
import '../database/database_helper.dart';
import 'medicine_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int medicineCount = 0;

  @override
  void initState() {
    super.initState();
    loadMedicines();
  }

  Future<void> loadMedicines() async {
    final medicines = await DatabaseHelper.instance.getMedicines();

    if (!mounted) return;

    setState(() {
      medicineCount = medicines.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MediTrack AI"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "👋 Merhaba Dilan",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "İlaçlarını düzenli takip etmeye hazır mısın?",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            const SizedBox(height: 15),

            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.medication, size: 35),
                title: const Text("Kayıtlı İlaç"),
                subtitle: Text("$medicineCount ilaç"),
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
            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddMedicineScreen(),
                    ),
                  );

                  loadMedicines();
                },
                icon: const Icon(Icons.add),
                label: const Text(
                  "İlaç Ekle",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}