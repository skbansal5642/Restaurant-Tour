import 'package:flutter/material.dart';

import 'favourites.dart';
import 'restaurant_list.dart';

class RestaurantTour extends StatelessWidget {
  const RestaurantTour({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text(
                'RestauranTour',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 25,
                ),
              ),
              bottom: const TabBar(
                tabAlignment: TabAlignment.center,
                dividerColor: Colors.transparent,
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                tabs: [
                  Tab(text: 'All Restaurants'),
                  Tab(text: 'My Favorites'),
                ],
              ),
              elevation: 3,
              scrolledUnderElevation: 3,
              surfaceTintColor: Colors.white,
              backgroundColor: Colors.white,
              shadowColor: const Color(0xFFD2DBDB),
            ),
            body: TabBarView(
              children: [
                const RestaurantList(),
                Favourites(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
