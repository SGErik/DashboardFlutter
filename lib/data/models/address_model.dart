class Address {
  List<Addresses>? addresses;

  Address({this.addresses});

  Address.fromJson(Map<String, dynamic> json) {
    if (json['addresses'] != null) {
      addresses = <Addresses>[];
      json['addresses'].forEach((v) {
        addresses!.add(new Addresses.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.addresses != null) {
      data['addresses'] = this.addresses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Addresses {
  int? id;
  String? zipcode;
  String? street;
  String? addressNumber;
  String? complement;
  int? userId;
  Neighborhood? neighborhood;

  Addresses(
      {this.id,
      this.zipcode,
      this.street,
      this.addressNumber,
      this.complement,
      this.userId,
      this.neighborhood});

  Addresses.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    zipcode = json['zipcode'];
    street = json['street'];
    addressNumber = json['addressNumber'];
    complement = json['complement'];
    userId = json['user_id'];
    neighborhood = json['neighborhood'] != null
        ? new Neighborhood.fromJson(json['neighborhood'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['zipcode'] = this.zipcode;
    data['street'] = this.street;
    data['addressNumber'] = this.addressNumber;
    data['complement'] = this.complement;
    data['user_id'] = this.userId;
    if (this.neighborhood != null) {
      data['neighborhood'] = this.neighborhood!.toJson();
    }
    return data;
  }
}

class Neighborhood {
  int? id;
  String? neighborhood;
  City? city;

  Neighborhood({this.id, this.neighborhood, this.city});

  Neighborhood.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    neighborhood = json['neighborhood'];
    city = json['city'] != null ? new City.fromJson(json['city']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['neighborhood'] = this.neighborhood;
    if (this.city != null) {
      data['city'] = this.city!.toJson();
    }
    return data;
  }
}

class City {
  int? id;
  String? city;
  State? state;

  City({this.id, this.city, this.state});

  City.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    city = json['city'];
    state = json['state'] != null ? new State.fromJson(json['state']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['city'] = this.city;
    if (this.state != null) {
      data['state'] = this.state!.toJson();
    }
    return data;
  }
}

class State {
  int? id;
  String? state;

  State({this.id, this.state});

  State.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    state = json['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['state'] = this.state;
    return data;
  }
}
