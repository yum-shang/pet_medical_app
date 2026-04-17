import 'package:flutter/material.dart';

enum PetType { cat, dog, other }

enum PetGender { male, female }

class Pet {
  final String id;
  final String name;
  final PetType type;
  final String breed;
  final PetGender gender;
  final DateTime? birthDate;
  final double? weight;
  final bool isNeutered;
  final String? imageUrl;

  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.gender,
    this.birthDate,
    this.weight,
    this.isNeutered = false,
    this.imageUrl,
  });

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int years = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      years--;
    }
    return years;
  }

  Pet copyWith({
    String? id,
    String? name,
    PetType? type,
    String? breed,
    PetGender? gender,
    DateTime? birthDate,
    double? weight,
    bool? isNeutered,
    String? imageUrl,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      isNeutered: isNeutered ?? this.isNeutered,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'breed': breed,
      'gender': gender.index,
      'birthDate': birthDate?.toIso8601String(),
      'weight': weight,
      'isNeutered': isNeutered,
      'imageUrl': imageUrl,
    };
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      type: PetType.values[json['type']],
      breed: json['breed'],
      gender: PetGender.values[json['gender']],
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : null,
      weight: json['weight']?.toDouble(),
      isNeutered: json['isNeutered'] ?? false,
      imageUrl: json['imageUrl'],
    );
  }

  IconData get icon {
    switch (type) {
      case PetType.cat:
        return Icons.pets;
      case PetType.dog:
        return Icons.pets;
      case PetType.other:
        return Icons.cruelty_free;
    }
  }

  String get typeName {
    switch (type) {
      case PetType.cat:
        return '猫咪';
      case PetType.dog:
        return '狗狗';
      case PetType.other:
        return '其他';
    }
  }
}
