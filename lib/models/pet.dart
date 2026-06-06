class PetVO {
  final int id;
  final int userId;
  final String petName;
  final String petType;
  final String? avatarUrl;
  final int gender;
  final int age;
  final String ageUnit;
  final String breed;
  final String? weight;
  final int sterilized;
  final String? remark;
  final int status;
  final String? createdAt;
  final String? updatedAt;

  PetVO({
    required this.id,
    required this.userId,
    required this.petName,
    required this.petType,
    this.avatarUrl,
    this.gender = 1,
    this.age = 0,
    this.ageUnit = 'year',
    this.breed = '',
    this.weight,
    this.sterilized = 0,
    this.remark,
    this.status = 1,
    this.createdAt,
    this.updatedAt,
  });

  factory PetVO.fromJson(Map<String, dynamic> json) {
    return PetVO(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      petName: json['pet_name'] ?? '',
      petType: json['pet_type'] ?? '',
      avatarUrl: json['avatar_url'],
      gender: json['gender'] ?? 1,
      age: json['age'] ?? 0,
      ageUnit: json['age_unit'] ?? 'year',
      breed: json['breed'] ?? '',
      weight: json['weight']?.toString(),
      sterilized: json['sterilized'] ?? 0,
      remark: json['remark'],
      status: json['status'] ?? 1,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        'pet_name': petName,
        'pet_type': petType,
        'avatar_url': avatarUrl,
        'gender': gender,
        'age': age,
        'age_unit': ageUnit,
        'breed': breed,
        'weight': weight,
        'sterilized': sterilized,
        'remark': remark,
      };

  Map<String, dynamic> toUpdateJson() => {
        if (petName.isNotEmpty) 'pet_name': petName,
        if (petType.isNotEmpty) 'pet_type': petType,
        'avatar_url': avatarUrl,
        'gender': gender,
        'age': age,
        'age_unit': ageUnit,
        'breed': breed,
        'weight': weight,
        'sterilized': sterilized,
        'remark': remark,
      };

  String get genderLabel => gender == 1 ? '公' : '母';

  String get ageLabel {
    if (ageUnit == 'year') return '$age岁';
    if (ageUnit == 'month') return '$age个月';
    return '$age天';
  }

  String get sterilizedLabel => sterilized == 1 ? '已绝育' : '未绝育';
}
