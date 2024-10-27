import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:restaurant_tour/main.dart';
import 'package:restaurant_tour/models/business_list_model.dart';

class RestaurantProvider extends ChangeNotifier {
  BusinessListModel? businessListModel;
  final List<Business> _businesses = [];
  List<Business> favourites = [];
  // bool _isLocalUpdate = false;

  set businesses(List<Business> value) {
    _businesses.clear();
    _businesses.addAll(value);
  }

  List<Business> get businesses => _businesses;

  List<Business> setBusinessListModel(Map<String, dynamic>? data) {
    // if (_isLocalUpdate) {
    //   _isLocalUpdate = false;
    //   return [];
    // }
    String? response;
    if (data != null) {
      response = jsonEncode(data);
    } else {
      response = localModel;
    }
    businessListModel = businessListModelFromJson(response);
    fetchFavourites();
    List<Business> restaurants = [];
    if (businessListModel != null) {
      for (Business business in businessListModel!.search.business) {
        for (Business favourite in favourites) {
          if (favourite.id == business.id) {
            business.isFavourite = true;
            // break;
          }
        }
        restaurants.add(business);
      }
    }
    return restaurants;
  }

  fetchFavourites() {
    if (favourites.isNotEmpty) return;
    List<String> encodedFavourites = localSharedPreferences.getFavourites();
    favourites = encodedFavourites.map((str) {
      Business favourite = Business.fromJson(jsonDecode(str));
      favourite.isFavourite = true;
      return favourite;
    }).toList();
    // notifyListeners();
  }

  addFavourite(String id) {
    for (int idx = 0; idx < _businesses.length; idx++) {
      if (_businesses[idx].id == id) {
        _businesses[idx].isFavourite = true;
        favourites.add(_businesses[idx]);
      }
    }
    // _isLocalUpdate = true;
    notifyListeners();
    updateSharedList();
  }

  removeFavourite(String id) {
    for (int idx = 0; idx < businesses.length; idx++) {
      if (businesses[idx].id == id) {
        businesses[idx].isFavourite = false;
        // break;
      }
    }

    for (int idx = 0; idx < favourites.length; idx++) {
      if (favourites[idx].id == id) {
        favourites.removeAt(idx);
        // break;
      }
    }
    // _isLocalUpdate = true;
    notifyListeners();
    updateSharedList();
  }

  // setLocalUpdate() {
  //   // _isLocalUpdate = true;
  // }

  updateSharedList() {
    List<String> encodedFavourites = favourites.map((business) => jsonEncode(business.toJson())).toList();
    localSharedPreferences.saveFavourites(encodedFavourites);
  }
}
