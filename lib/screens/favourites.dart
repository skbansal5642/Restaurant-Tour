import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_tour/models/business_list_model.dart';
import 'package:restaurant_tour/providers/restaurant_provider.dart';
import 'package:restaurant_tour/screens/restaurant.dart';

// ignore: must_be_immutable
class Favourites extends HookWidget {
  Favourites({super.key});

  late RestaurantProvider restaurantProvider;

  @override
  Widget build(BuildContext context) {
    restaurantProvider = Provider.of<RestaurantProvider>(context);
    // restaurantProvider.setLocalUpdate();
    final screenSize = MediaQuery.of(context).size;
    return restaurantProvider.favourites.isEmpty
        ? const Center(
            child: Text("No favourite restaurant found."),
          )
        : ListView.builder(
            itemCount: restaurantProvider.favourites.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              Business business = restaurantProvider.favourites[index];
              return Restaurant(
                screenSize: screenSize,
                business: business,
                index: index,
              );
            },
          );
  }
}
