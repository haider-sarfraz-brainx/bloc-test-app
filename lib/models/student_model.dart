import 'package:equatable/equatable.dart';

class StudentModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;

  const StudentModel({
    this.id = "",
    this.name = "",
    this.email = "",
    this.phoneNumber = "",
  });

  @override
  List<Object?> get props => [id, name, email, phoneNumber];

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email, 'phoneNumber': phoneNumber};
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] ?? "",
      name: map['name'] ?? "",
      email: map['email'] ?? "",
      phoneNumber: map['phoneNumber'] ?? "",
    );
  }
}
