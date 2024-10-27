import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_tour/config.dart';
import 'package:restaurant_tour/models/business_list_model.dart';
import 'package:restaurant_tour/providers/restaurant_provider.dart';
import 'package:restaurant_tour/screens/restaurant_detail_screen.dart';
import 'package:restaurant_tour/utils/local_shared_prefrences.dart';

import 'screens/restaurant_tour.dart';

late ValueNotifier<GraphQLClient> client;
late LocalSharedPreferences localSharedPreferences;
late String localModel;

void main() async {
  await initHiveForFlutter();

  final HttpLink httpLink = HttpLink(Config.yelpApiUrl);

  final AuthLink authLink = AuthLink(
    getToken: () => 'Bearer ${Config.yelpAccessToken}',
  );

  localModel = await rootBundle.loadString('assets/model.json');

  final Link link = authLink.concat(httpLink);

  client = ValueNotifier(
    GraphQLClient(
      link: link,
      // The default store is the InMemoryStore, which does NOT persist to disk
      cache: GraphQLCache(store: HiveStore()),
    ),
  );
  localSharedPreferences = await LocalSharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RestaurantProvider>(create: (context) => RestaurantProvider()),
      ],
      child: GraphQLProvider(
        client: client,
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
          ),
          initialRoute: "restaurant_tour",
          onGenerateRoute: (settings) {
            if (settings.name == "restaurant_details") {
              return MaterialPageRoute(
                builder: (context) => RestaurantDetailScreen(business: settings.arguments as Business),
              );
            } else if (settings.name == "restaurant_tour") {
              return MaterialPageRoute(builder: (context) => const RestaurantTour());
            }
            return null;
          },
        ),
      ),
    );
  }
}
