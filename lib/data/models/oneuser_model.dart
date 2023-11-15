class OneUserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String url;
  final String image_id;
  final bool is_admin;
  final String telefone;
  final String createdAt;
  final String updatedAt;

  OneUserModel({
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

  factory OneUserModel.fromJson(Map<String, dynamic> json) {
    return OneUserModel(
      id: json['id'] ?? 0,
      name: json['name'],
      email: json['email'],
      password: json['password'],
      url: json['url'],
      image_id: json['image_id'],
      is_admin: json['is_admin'],
      telefone: json['telefone'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
