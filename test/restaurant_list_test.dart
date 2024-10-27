import 'dart:convert';
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
import 'package:restaurant_tour/providers/restaurant_provider.dart';
import 'package:restaurant_tour/screens/restaurant_tour.dart';
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

@GenerateNiceMocks([
  MockSpec<GraphQLClient>(),
])
void main() {
  late MockGraphQLClient mockGraphQLClient;
  setUpAll(() async {
    mockGraphQLClient = MockGraphQLClient();
    mockGraphQLClient.defaultPolicies = DefaultPolicies(
      watchQuery: Policies.safe(FetchPolicy.networkOnly, ErrorPolicy.ignore, CacheRereadPolicy.ignoreAll),
      watchMutation: Policies.safe(FetchPolicy.networkOnly, ErrorPolicy.ignore, CacheRereadPolicy.ignoreAll),
      query: Policies.safe(FetchPolicy.networkOnly, ErrorPolicy.ignore, CacheRereadPolicy.ignoreAll),
      mutate: Policies.safe(FetchPolicy.networkOnly, ErrorPolicy.ignore, CacheRereadPolicy.ignoreAll),
      subscribe: Policies.safe(FetchPolicy.networkOnly, ErrorPolicy.ignore, CacheRereadPolicy.ignoreAll),
    );
    localSharedPreferences = MockSharedPrefrences();
    WidgetsFlutterBinding.ensureInitialized();
    localModel = await rootBundle.loadString('assets/model.json');
  });

  void mockQueryResponse({
    required Map<String, dynamic>? data,
    bool isLoading = false,
    String? errorMessage,
  }) {
    final options = QueryOptions(
      document: gql(kSearchRestaurantQuery),
      variables: const {'nOffset': 10},
      pollInterval: const Duration(hours: 24),
      cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
    );
    when(
      client.value.query(options),
    ).thenAnswer(
      (_) => Future.value(
        QueryResult(
          options: options,
          source: isLoading ? QueryResultSource.loading : QueryResultSource.network,
          data: data,
          exception: errorMessage != null
              ? OperationException(
                  graphqlErrors: [
                    GraphQLError(message: errorMessage),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  group('Favorites Page Widget Tests', () {
    late RestaurantProvider restaurantProvider;

    setUp(() async {
      await mockApplicationDocumentsDirectory();
      await initHiveForFlutter();
      client = ValueNotifier(mockGraphQLClient);

      restaurantProvider = RestaurantProvider();
      restaurantProvider.setBusinessListModel(jsonDecode(localModel));
      mockQueryResponse(data: jsonDecode(localModel));
    });

    testWidgets('Test if ListView shows up', (tester) async {
      mockNetworkImagesFor(
        () async {
          await tester.pumpWidget(MultiProvider(
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
                home: const RestaurantTour(),
              ),
            ),
          ));
          AutomatedTestWidgetsFlutterBinding.ensureInitialized();
          TestWidgetsFlutterBinding.ensureInitialized();

          await tester.pump(const Duration(seconds: 3));
          restaurantProvider.setBusinessListModel(jsonDecode(localModel));
          await tester.pumpAndSettle();
          expect(find.byType(ListView), findsOneWidget);
        },
      );
    });
  });
}

Widget createRestaurantScreen() => MultiProvider(
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
          home: const RestaurantTour(),
        ),
      ),
    );
