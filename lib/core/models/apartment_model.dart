// Author: PAMS Development Team
// File: apartment_model.dart
// Purpose: Domain model for a PAMS apartment (rentable unit).

import 'dart:convert';

enum ApartmentStatus { vacant, occupied, maintenance, unavailable }

class ApartmentModel {
  final String id;
  final String apartmentNumber;
  final String city; // Bristol / Cardiff / London / Manchester
  final String location; // e.g. "Harbourside Tower"
  final String type; // e.g. "Studio", "1-bed", "2-bed", "Penthouse"
  final int floor;
  final int bedrooms;
  final int bathrooms;
  final double areaSqft;
  final double rentAmount;
  final ApartmentStatus status;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApartmentModel({
    required this.id,
    required this.apartmentNumber,
    required this.city,
    required this.location,
    required this.type,
    required this.floor,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqft,
    required this.rentAmount,
    this.status = ApartmentStatus.vacant,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'apartment_number': apartmentNumber,
        'city': city,
        'location': location,
        'type': type,
        'floor': floor,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'area_sqft': areaSqft,
        'rent_amount': rentAmount,
        'status': status.name,
        'description': description,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory ApartmentModel.fromMap(Map<String, dynamic> m) => ApartmentModel(
        id: m['id'] as String,
        apartmentNumber: m['apartment_number'] as String,
        city: m['city'] as String,
        location: m['location'] as String,
        type: m['type'] as String,
        floor: (m['floor'] as num).toInt(),
        bedrooms: (m['bedrooms'] as num).toInt(),
        bathrooms: (m['bathrooms'] as num).toInt(),
        areaSqft: (m['area_sqft'] as num).toDouble(),
        rentAmount: (m['rent_amount'] as num).toDouble(),
        status: ApartmentStatus.values.firstWhere(
          (e) => e.name == m['status'],
          orElse: () => ApartmentStatus.vacant,
        ),
        description: m['description'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  String toJson() => json.encode(toMap());
  factory ApartmentModel.fromJson(String s) =>
      ApartmentModel.fromMap(json.decode(s));

  ApartmentModel copyWith({
    String? apartmentNumber,
    String? city,
    String? location,
    String? type,
    int? floor,
    int? bedrooms,
    int? bathrooms,
    double? areaSqft,
    double? rentAmount,
    ApartmentStatus? status,
    String? description,
    DateTime? updatedAt,
  }) =>
      ApartmentModel(
        id: id,
        apartmentNumber: apartmentNumber ?? this.apartmentNumber,
        city: city ?? this.city,
        location: location ?? this.location,
        type: type ?? this.type,
        floor: floor ?? this.floor,
        bedrooms: bedrooms ?? this.bedrooms,
        bathrooms: bathrooms ?? this.bathrooms,
        areaSqft: areaSqft ?? this.areaSqft,
        rentAmount: rentAmount ?? this.rentAmount,
        status: status ?? this.status,
        description: description ?? this.description,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );
}
