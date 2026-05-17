import 'package:uuid/uuid.dart';

enum ProductCategory {
  all('All Gear'),
  bats('Bats'),
  gloves('Gloves'),
  protective('Protective'),
  apparel('Apparel');

  final String displayName;
  const ProductCategory(this.displayName);
}

class Product {
  final String id;
  final String name;
  final String subtitle;
  final ProductCategory category;
  final int priceCoins;
  final String imageURL;
  final String woodType;
  final String weight;
  final String balance;
  final String handleGrip;
  final int powerRating;
  final String description;

  Product({
    String? id,
    required this.name,
    required this.subtitle,
    required this.category,
    required this.priceCoins,
    this.imageURL = '',
    this.woodType = '',
    this.weight = '',
    this.balance = '',
    this.handleGrip = '',
    this.powerRating = 0,
    this.description = '',
  }) : id = id ?? const Uuid().v4();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Product && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
