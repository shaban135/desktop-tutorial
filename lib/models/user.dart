class User {
  final int id;
  final String name;
  final String? gender;
  final String? cnic;
  final String phone;
  final String? dateOfBirth;
  final String? address;
  final String email;
  final String? sapCode;
  final String? designationId;
  final String? departmentId;
  final String? dateOfJoining;
  final bool isActive;
  final String? avatarUrl;
  final Department? department;
  final Designation? designation;
  final Region? region;
  final Circle? circle;
  final Division? division;
  final SubDivision? subDivision;
  final Feeder? feeder;
  final Posting? currentPosting;
  final List<Posting> postings;

  User({
    required this.id,
    required this.name,
    this.gender,
    this.cnic,
    required this.phone,
    this.dateOfBirth,
    this.address,
    required this.email,
    this.sapCode,
    this.designationId,
    this.departmentId,
    this.dateOfJoining,
    required this.isActive,
    this.avatarUrl,
    this.department,
    this.designation,
    this.region,
    this.circle,
    this.division,
    this.subDivision,
    this.feeder,
    this.currentPosting,
    required this.postings,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var postingsList = json['postings'] as List? ?? [];
    List<Posting> postings = postingsList.map((i) => Posting.fromJson(i)).toList();

    return User(
      id: json['id'],
      name: json['name'] ?? '',
      gender: json['gender'],
      cnic: json['cnic']?.toString(),
      phone: json['phone']?.toString() ?? '',
      dateOfBirth: json['date_of_birth'],
      address: json['address'],
      email: json['email'] ?? '',
      sapCode: json['sap_code']?.toString(),
      designationId: json['designation_id']?.toString(),
      departmentId: json['department_id']?.toString(),
      dateOfJoining: json['date_of_joining'],
      isActive: json['is_active'] == 1,
      avatarUrl: json['avatar_url'],
      department: json['department'] != null ? Department.fromJson(json['department']) : null,
      designation: json['designation'] != null ? Designation.fromJson(json['designation']) : null,
      region: json['region'] != null ? Region.fromJson(json['region']) : null,
      circle: json['circle'] != null ? Circle.fromJson(json['circle']) : null,
      division: json['division'] != null ? Division.fromJson(json['division']) : null,
      subDivision: json['sub_division'] != null ? SubDivision.fromJson(json['sub_division']) : null,
      feeder: json['feeder'] != null ? Feeder.fromJson(json['feeder']) : null,
      currentPosting: json['current_posting'] != null ? Posting.fromJson(json['current_posting']) : null,
      postings: postings,
    );
  }
}

class Posting {
  final Region? region;
  final Circle? circle;
  final Division? division;
  final SubDivision? subDivision;
  final Feeder? feeder;
  final Designation? designation;
  final String? effectiveFrom;
  final String? effectiveTo;

  Posting({
    this.region,
    this.circle,
    this.division,
    this.subDivision,
    this.feeder,
    this.designation,
    this.effectiveFrom,
    this.effectiveTo,
  });

  factory Posting.fromJson(Map<String, dynamic> json) {
    return Posting(
      region: json['region'] != null ? Region.fromJson(json['region']) : null,
      circle: json['circle'] != null ? Circle.fromJson(json['circle']) : null,
      division: json['division'] != null ? Division.fromJson(json['division']) : null,
      subDivision: json['sub_division'] != null ? SubDivision.fromJson(json['sub_division']) : null,
      feeder: json['feeder'] != null ? Feeder.fromJson(json['feeder']) : null,
      designation: json['designation'] != null ? Designation.fromJson(json['designation']) : null,
      effectiveFrom: json['effective_from'],
      effectiveTo: json['effective_to'],
    );
  }
}

class Department {
  final String name;
  Department({required this.name});
  factory Department.fromJson(Map<String, dynamic> json) => Department(name: json['name']);
}

class Designation {
  final String name;
  Designation({required this.name});
  factory Designation.fromJson(Map<String, dynamic> json) => Designation(name: json['name']);
}

class Region {
  final String name;
  Region({required this.name});
  factory Region.fromJson(Map<String, dynamic> json) => Region(name: json['name']);
}

class Circle {
  final String name;
  Circle({required this.name});
  factory Circle.fromJson(Map<String, dynamic> json) => Circle(name: json['name']);
}

class Division {
  final String name;
  Division({required this.name});
  factory Division.fromJson(Map<String, dynamic> json) => Division(name: json['name']);
}

class SubDivision {
  final String name;
  SubDivision({required this.name});
  factory SubDivision.fromJson(Map<String, dynamic> json) => SubDivision(name: json['name']);
}

class Feeder {
  final String name;
  Feeder({required this.name});
  factory Feeder.fromJson(Map<String, dynamic> json) => Feeder(name: json['name']);
}
