class UserModel {
  final int id;
  final String name;
  final String email;
  final String password;
  final String url;
  final String image_id;
  final bool is_admin;
  final String telefone;
  final String createdAt;
  final String updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.password,
    required this.email,
    required this.url,
    // ignore: non_constant_identifier_names
    required this.image_id,
    // ignore: non_constant_identifier_names
    required this.is_admin,
    required this.telefone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      url: map['url'],
      image_id: map['image_id'],
      is_admin: map['is_admin'],
      telefone: map['telefone'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}
