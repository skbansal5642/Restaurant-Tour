import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_tour/main.dart';
import 'package:restaurant_tour/models/business_list_model.dart';
import 'package:restaurant_tour/providers/restaurant_provider.dart';
import 'package:restaurant_tour/utils/constants.dart';

import 'restaurant.dart';

// ignore: must_be_immutable
class RestaurantList extends StatefulWidget {
  const RestaurantList({super.key});

  @override
  State<RestaurantList> createState() => _RestaurantListState();
}

class _RestaurantListState extends State<RestaurantList> {
  late RestaurantProvider restaurantProvider;
  late Future<QueryResult<Object?>> query;

  int offset = 10;

  @override
  void initState() {
    super.initState();
    query = client.value.query(QueryOptions(
      document: gql(kSearchRestaurantQuery),
      variables: {
        'nOffset': offset,
      },
      pollInterval: const Duration(hours: 24),
      cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // final scrollController = useScrollController();
    restaurantProvider = Provider.of<RestaurantProvider>(context);

    final screenSize = MediaQuery.of(context).size;
    return FutureBuilder(
      future: query,
      // options: QueryOptions(
      //   document: gql(kSearchRestaurantQuery),
      //   variables: {
      //     'nOffset': offset,
      //   },
      //   pollInterval: const Duration(hours: 24),
      //   cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      // ),
      builder: (context, result) {
        if (result.data == null) return Container();
        if (result.data!.isLoading && restaurantProvider.businesses.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        // if (result.hasException) {
        //   return Center(child: Text(result.exception.toString()));
        // }

        // if (result.data != null) {
        final restaurants = restaurantProvider.setBusinessListModel(result.data!.data);
        restaurantProvider.businesses = restaurants;
        // }
        // final opts = FetchMoreOptions(
        //   updateQuery: (previousResultData, fetchMoreResultData) => fetchMoreResultData,
        // );

        // useEffect(() {
        //   scrollController.addListener(() {
        //     if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100 && !scrollController.position.outOfRange) {
        //       if (fetchMore != null) {
        //         offset += 10;
        //         fetchMore(opts);
        //       }
        //     }
        //   });

        //   // Clean up listener when the widget is disposed
        //   return () => scrollController.removeListener(() {});
        // }, [scrollController]);

        return ListView.builder(
          // controller: scrollController,
          itemCount: restaurantProvider.businesses.length,
          padding: const EdgeInsets.all(10),
          itemBuilder: (context, index) {
            Business business = restaurantProvider.businesses[index];
            return Restaurant(
              key: Key(business.id),
              screenSize: screenSize,
              business: business,
              index: index,
            );
          },
        );
      },
    );
  }
}
