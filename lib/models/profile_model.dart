class ProfileModel{
  String name;
  String email;
  String? id;
  int? timeStamp;

  ProfileModel({required this.name, required this.email, this.id, this.timeStamp});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'id': id,
      'timeStamp': timeStamp,
    };
  }

  Map<String, dynamic> toCreateProfileMap() {
    return {
      'name': name,
      'email': email,
      'id': id,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      name: map['name'] ??"",
      email: map['email'] ??"",
      id: map['id'] ??"",
      timeStamp: map['timeStamp'] ??-1,
    );
  }

}