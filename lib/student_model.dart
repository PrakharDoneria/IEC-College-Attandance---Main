class Student {
  final String name;
  final String classNumber;
  final String rollNumber;
  final String mobileNumber;

  Student({
    required this.name,
    required this.classNumber,
    required this.rollNumber,
    required this.mobileNumber,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: json['name'],
      classNumber: json['class'],
      rollNumber: json['roll_number'],
      mobileNumber: json['mobile_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'class': classNumber,
      'roll_number': rollNumber,
      'mobile_number': mobileNumber,
    };
  }
}
