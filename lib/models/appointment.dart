import 'package:flutter/material.dart';

class Appointment {
  final String id;
  final String petId;
  final String petName;
  final String doctorId;
  final String doctorName;
  final String hospital;
  final String department;
  final DateTime dateTime;
  final String status; // pending, confirmed, completed, cancelled

  Appointment({
    required this.id,
    required this.petId,
    required this.petName,
    required this.doctorId,
    required this.doctorName,
    required this.hospital,
    required this.department,
    required this.dateTime,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'petName': petName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'hospital': hospital,
      'department': department,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      petId: json['petId'],
      petName: json['petName'],
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      hospital: json['hospital'],
      department: json['department'],
      dateTime: DateTime.parse(json['dateTime']),
      status: json['status'],
    );
  }
}

class Doctor {
  final String id;
  final String name;
  final String title;
  final String specialty;
  final String avatar;
  final String hospital;
  final List<String> availableDays;
  final List<String> availableTimes;

  Doctor({
    required this.id,
    required this.name,
    required this.title,
    required this.specialty,
    required this.avatar,
    required this.hospital,
    required this.availableDays,
    required this.availableTimes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'specialty': specialty,
      'avatar': avatar,
      'hospital': hospital,
      'availableDays': availableDays,
      'availableTimes': availableTimes,
    };
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      specialty: json['specialty'],
      avatar: json['avatar'],
      hospital: json['hospital'],
      availableDays: List<String>.from(json['availableDays']),
      availableTimes: List<String>.from(json['availableTimes']),
    );
  }
}
