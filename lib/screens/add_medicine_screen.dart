import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/medicine.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController doseController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  TimeOfDay? selectedTime;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 7));

  int timesPerDay = 1;

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: startDate,
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    doseController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("İlaç Ekle"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "İlaç Adı",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: doseController,
              decoration: const InputDecoration(
                labelText: "Doz",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            ListTile(
              title: Text(
                selectedTime == null
                    ? "Saat Seç"
                    : selectedTime!.format(context),
              ),
              trailing: const Icon(Icons.access_time),
              onTap: pickTime,
            ),

            const SizedBox(height: 15),

            ListTile(
              title: Text(
                "Başlangıç: ${startDate.day}/${startDate.month}/${startDate.year}",
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: pickStartDate,
            ),

            ListTile(
              title: Text(
                "Bitiş: ${endDate.day}/${endDate.month}/${endDate.year}",
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: pickEndDate,
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<int>(
              initialValue: timesPerDay,
              decoration: const InputDecoration(
                labelText: "Günde Kaç Kez",
                border: OutlineInputBorder(),
              ),
              items: [1,2,3,4,5]
                  .map(
                    (e) => DropdownMenuItem(
                  value: e,
                  child: Text("$e kez"),
                ),
              )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  timesPerDay = value!;
                });
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Notlar",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      doseController.text.isEmpty ||
                      selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Lütfen zorunlu alanları doldurun."),
                      ),
                    );
                    return;
                  }

                  final medicine = Medicine(
                    name: nameController.text,
                    dose: doseController.text,
                    time:
                    "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                    startDate: startDate.toIso8601String(),
                    endDate: endDate.toIso8601String(),
                    timesPerDay: timesPerDay,
                    notes: notesController.text,
                    isActive: true,
                  );

                  await DatabaseHelper.instance.insertMedicine(
                    medicine.toMap(),
                  );

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("İlaç başarıyla kaydedildi."),
                    ),
                  );

                  Navigator.pop(context);
                },
                child: const Text(
                  "Kaydet",
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