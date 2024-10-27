import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
// import 'package:http/testing.dart';
// import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:restaurant_tour/config.dart';
import 'package:restaurant_tour/main.dart';
import 'package:restaurant_tour/models/business_list_model.dart';
// import 'package:restaurant_tour/main.dart';
import 'package:restaurant_tour/providers/restaurant_provider.dart';
import 'package:restaurant_tour/screens/restaurant_detail_screen.dart';
import 'package:restaurant_tour/screens/restaurant_tour.dart';
import 'package:restaurant_tour/utils/local_shared_prefrences.dart';

class MockHttpClient extends Mock implements http.Client {}

/// https://flutter.dev/docs/cookbook/persistence/reading-writing-files#testing
Future<void> mockApplicationDocumentsDirectory() async {
  // Create a temporary directory.
  final directory = await Directory.systemTemp.createTemp();
  handler(MethodCall methodCall) async {
    // If you're getting the apps documents directory, return the path to the
    // temp directory on the test environment instead.
    if (methodCall.method == 'getApplicationDocumentsDirectory') {
      return directory.path;
    }
    return null;
  }

  // Mock out the MethodChannel for the path_provider plugin.
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, handler);
  const channelOsx = MethodChannel('plugins.flutter.io/path_provider_macos');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channelOsx, handler);
}

Future<Map<String, dynamic>> loadJsonFromFile(String path) async {
  final file = File(path);
  final jsonString = await file.readAsString();
  return jsonDecode(jsonString);
}

void main() {
  setUpAll(() async {
    await mockApplicationDocumentsDirectory();
    await initHiveForFlutter();
    localModel = await rootBundle.loadString('assets/model.json');
    localSharedPreferences = await LocalSharedPreferences.getInstance();
  });
  group('Testing Restaurant Details', () {
    HttpLink httpLink;

    setUp(() async {
      final AuthLink authLink = AuthLink(
        getToken: () => 'Bearer ${Config.yelpAccessToken}_test',
      );

      httpLink = HttpLink(Config.yelpApiUrl);

      final Link link = authLink.concat(httpLink);
      client = ValueNotifier(
        GraphQLClient(
          cache: GraphQLCache(store: await HiveStore.open()),
          link: link,
        ),
      );
    });

    testWidgets('Add to favourite', (tester) async {
      await tester.pumpWidget(MainWidget(client: client, child: const RestaurantTour()));

      TestWidgetsFlutterBinding.ensureInitialized();

      expect(find.text('RestauranTour'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));

      // Check if favourite list is empty
      await tester.tap(find.text("My Favorites"));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('No favourite restaurant found.'), findsOneWidget);
      // Go back to restaurant list
      await tester.tap(find.text("All Restaurants"));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Open a restaurant
      await tester.tap(find.byKey(const ValueKey("4XX-zF8h5Lvrr22_tqU6-Q")));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      // Add to favourite
      await tester.tap(find.byKey(const ValueKey("4XX-zF8h5Lvrr22_tqU6-Q_favourite")));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Go to favourite screen
      await tester.tap(find.text("My Favorites"));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('No favourite restaurant found.'), findsNothing);

      // Remove restaurants from favourites.

      await tester.tap(find.byKey(const ValueKey("4XX-zF8h5Lvrr22_tqU6-Q_favourite")));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('No favourite restaurant found.'), findsOneWidget);

      // Go back to restaurant list
      await tester.tap(find.text("All Restaurants"));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
  });
}

class MainWidget extends StatelessWidget {
  const MainWidget({
    super.key,
    required this.client,
    required this.child,
  });

  final ValueNotifier<GraphQLClient>? client;
  final Widget child;

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
            useMaterial3: true,
          ),
          home: child,
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
