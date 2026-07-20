class Medicine {
  final int? id;
  final String name;
  final String dose;
  final String time;

  final String startDate;
  final String endDate;
  final int timesPerDay;
  final String notes;
  final bool isActive;

  Medicine({
    this.id,
    required this.name,
    required this.dose,
    required this.time,
    required this.startDate,
    required this.endDate,
    required this.timesPerDay,
    required this.notes,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dose': dose,
      'time': time,
      'startDate': startDate,
      'endDate': endDate,
      'timesPerDay': timesPerDay,
      'notes': notes,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      dose: map['dose'],
      time: map['time'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      timesPerDay: map['timesPerDay'],
      notes: map['notes'],
      isActive: map['isActive'] == 1,
    );
  }
}