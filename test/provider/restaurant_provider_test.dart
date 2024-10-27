import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:restaurant_tour/main.dart';
import 'package:restaurant_tour/models/business_list_model.dart';
import 'package:restaurant_tour/providers/restaurant_provider.dart';
import 'package:restaurant_tour/utils/local_shared_prefrences.dart';

class MockSharedPrefrences extends Mock implements LocalSharedPreferences {
  @override
  List<String> getFavourites() {
    return [];
  }
}

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    localModel = await rootBundle.loadString('assets/model.json');
    localSharedPreferences = MockSharedPrefrences();
  });
  group('Testing App Provider', () {
    late RestaurantProvider restaurantProvider;
    List<Business> restaurants = [];
    setUp(() {
      restaurantProvider = RestaurantProvider();
      restaurants = restaurantProvider.setBusinessListModel(jsonDecode(localModel));
    });

    test('Restaurants should decoded correcly', () {
      restaurantProvider.businesses = restaurants;
      expect(restaurantProvider.businesses.isNotEmpty, true);
    });

    test('A new item should be added', () {
      restaurantProvider.businesses = restaurants;
      String businessId = "4XX-zF8h5Lvrr22_tqU6-Q";
      restaurantProvider.addFavourite(businessId);
      expect(restaurantProvider.favourites.isNotEmpty, true);
    });

    test('An item should be removed', () {
      restaurantProvider.businesses = restaurants;
      String businessId = "4XX-zF8h5Lvrr22_tqU6-Q";
      restaurantProvider.addFavourite(businessId);
      expect(restaurantProvider.favourites.isNotEmpty, true);

      restaurantProvider.removeFavourite(businessId);
      expect(restaurantProvider.favourites.isEmpty, true);
    });
  });
}
