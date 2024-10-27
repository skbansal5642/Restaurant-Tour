// To parse this JSON data, do
//
//     final businessListModel = businessListModelFromJson(jsonString);

import 'dart:convert';

BusinessListModel businessListModelFromJson(String str) => BusinessListModel.fromJson(json.decode(str));

String businessListModelToJson(BusinessListModel data) => json.encode(data.toJson());

class BusinessListModel {
  final Search search;

  BusinessListModel({
    required this.search,
  });

  factory BusinessListModel.fromJson(Map<String, dynamic> json) => BusinessListModel(
        search: Search.fromJson(json["search"]),
      );

  Map<String, dynamic> toJson() => {
        "search": search.toJson(),
      };
}

class Search {
  final int total;
  final List<Business> business;

  Search({
    required this.total,
    required this.business,
  });

  factory Search.fromJson(Map<String, dynamic> json) => Search(
        total: json["total"],
        business: List<Business>.from(json["business"].map((x) => Business.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "business": List<dynamic>.from(business.map((x) => x.toJson())),
      };
}

class Business {
  final String id;
  final List<Category> categories;
  final String displayPhone;
  final int reviewCount;
  final List<Review> reviews;
  final String url;
  final double rating;
  final String price;
  final List<String> photos;
  final String phone;
  final String name;
  final bool isClosed;
  bool isFavourite;
  final Location? location;

  Business({
    required this.id,
    required this.categories,
    required this.displayPhone,
    required this.reviewCount,
    required this.reviews,
    required this.url,
    required this.rating,
    required this.price,
    required this.photos,
    required this.phone,
    required this.name,
    required this.isClosed,
    required this.isFavourite,
    required this.location,
  });

  factory Business.fromJson(Map<String, dynamic> json) => Business(
        id: json["id"],
        categories: List<Category>.from(json["categories"].map((x) => Category.fromJson(x))),
        displayPhone: json["display_phone"],
        reviewCount: json["review_count"],
        reviews: List<Review>.from(json["reviews"].map((x) => Review.fromJson(x))),
        url: json["url"],
        rating: json["rating"]?.toDouble(),
        price: json["price"] ?? '',
        photos: List<String>.from(json["photos"].map((x) => x)),
        phone: json["phone"],
        name: json["name"],
        isClosed: json["is_closed"],
        isFavourite: false,
        location: Location.fromJson(json["location"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
        "display_phone": displayPhone,
        "review_count": reviewCount,
        "reviews": List<dynamic>.from(reviews.map((x) => x.toJson())),
        "url": url,
        "rating": rating,
        "price": price,
        "photos": List<dynamic>.from(photos.map((x) => x)),
        "phone": phone,
        "name": name,
        "is_closed": isClosed,
        "location": location?.toJson(),
      };
}

class Category {
  final String title;

  Category({
    required this.title,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
      };
}

class Review {
  final String id;
  final int rating;
  final String text;
  final DateTime timeCreated;
  final User user;

  Review({
    required this.id,
    required this.rating,
    required this.text,
    required this.timeCreated,
    required this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json["id"],
        rating: json["rating"],
        text: json["text"],
        timeCreated: DateTime.parse(json["time_created"]),
        user: User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "rating": rating,
        "text": text,
        "time_created": timeCreated.toIso8601String(),
        "user": user.toJson(),
      };
}

class User {
  final String id;
  final String? imageUrl;
  final String? name;
  final String? profileUrl;

  User({
    required this.id,
    this.imageUrl,
    this.name,
    this.profileUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        imageUrl: json["image_url"],
        name: json["name"],
        profileUrl: json["profile_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image_url": imageUrl,
        "name": name,
        "profile_url": profileUrl,
      };
}

class Location {
  final String? address1;
  final String? address2;
  final String? address3;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;

  Location({
    required this.address1,
    required this.address2,
    required this.address3,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        address1: json["address1"],
        address2: json["address2"],
        address3: json["address3"],
        city: json["city"],
        state: json["state"],
        postalCode: json["postal_code"],
        country: json["country"],
      );

  Map<String, dynamic> toJson() => {
        "address1": address1,
        "address2": address2,
        "address3": address3,
        "city": city,
        "state": state,
        "postal_code": postalCode,
        "country": country,
      };
}
