import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_tour/main.dart';
import 'package:restaurant_tour/models/business_list_model.dart';
import 'package:restaurant_tour/providers/restaurant_provider.dart';
import 'package:restaurant_tour/screens/restaurant_detail_screen.dart';
import 'package:restaurant_tour/utils/constants.dart';
import 'package:restaurant_tour/utils/local_shared_prefrences.dart';
import 'package:http/http.dart' as http;

import 'restaurant_list_test.mocks.dart';

class MockHttpClient extends Mock implements http.Client {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest? request) => super.noSuchMethod(
        Invocation.method(#send, [request]),
        returnValue: Future.value(
          http.StreamedResponse(
            Stream.fromIterable(const [<int>[]]),
            500,
          ),
        ),
      ) as Future<http.StreamedResponse>;
}

class MockSharedPrefrences extends Mock implements LocalSharedPreferences {
  @override
  List<String> getFavourites() {
    return [];
  }
}

Future<void> mockApplicationDocumentsDirectory() async {
  // Create a temporary directory.
  final directory = await Directory.systemTemp.createTemp();
  handler(MethodCall methodCall) async {
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

late RestaurantProvider restaurantProvider;
List<Business> restaurants = [];

setBusinesses() {
  restaurantProvider.businesses = restaurants;
}

getListOfBusinesses() {
  BusinessListModel businessListModel = businessListModelFromJson(localModel);
  return businessListModel.search.business;
}

@GenerateNiceMocks([
  MockSpec<GraphQLClient>(),
])
void main() {
  late MockGraphQLClient mockGraphQLClient;

  setUpAll(() async {
    mockGraphQLClient = MockGraphQLClient();
    localSharedPreferences = MockSharedPrefrences();
    WidgetsFlutterBinding.ensureInitialized();
    localModel = await rootBundle.loadString('assets/model.json');
    restaurants = getListOfBusinesses();
  });

  group('Restaurant Details Screen Tests', () {
    setUp(() async {
      await mockApplicationDocumentsDirectory();
      await initHiveForFlutter();
      client = ValueNotifier(mockGraphQLClient);
      final options = QueryOptions(
        document: gql(kSearchRestaurantQuery),
        variables: const {'nOffset': 10},
        pollInterval: const Duration(hours: 24),
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      );
      client.value.query(options);
    });

    testWidgets('Test if favourite icon shows', (tester) async {
      mockNetworkImagesFor(
        () async {
          await tester.pumpWidget(createRestaurantScreen(restaurants));
          await tester.pump(const Duration(seconds: 3));
          expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        },
      );
    });

    testWidgets('Test if restaurant add to favourite on tap', (tester) async {
      mockNetworkImagesFor(
        () async {
          await tester.pumpWidget(createRestaurantScreen(restaurants));
          setBusinesses();
          await tester.pumpAndSettle(const Duration(seconds: 3));
          await tester.tap(find.byIcon(Icons.favorite_border));
          await tester.pumpAndSettle(const Duration(seconds: 1));
          expect(find.byIcon(Icons.favorite), findsOneWidget);
        },
      );
    });
  });
}

Widget createRestaurantScreen(List<Business> restaurants) => MultiProvider(
      providers: [
        ChangeNotifierProvider<RestaurantProvider>(create: (context) {
          restaurantProvider = RestaurantProvider();
          return restaurantProvider;
        }),
      ],
      child: GraphQLProvider(
        client: client,
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
            useMaterial3: true,
          ),
          home: RestaurantDetailScreen(business: restaurants[0]),
        ),
      ),
    );
