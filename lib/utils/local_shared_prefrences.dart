import 'package:shared_preferences/shared_preferences.dart';

const String _keyFavouritesList = "favourites_list";

class LocalSharedPreferences {
  static LocalSharedPreferences? _instance;
  static late SharedPreferences _preferences;

  LocalSharedPreferences._();

  // Using a singleton pattern
  static Future<LocalSharedPreferences> getInstance() async {
    _instance ??= LocalSharedPreferences._();

    _preferences = await SharedPreferences.getInstance();

    return _instance!;
  }

  /// Function to save the user data model
  void saveFavourites(List<String> favouritesList) {
    _preferences.setStringList(_keyFavouritesList, favouritesList);
  }

  /// Function to retrive the saved user credentials and
  /// set them to common user data model and set global access token.
  List<String> getFavourites() {
    List<String> data = _preferences.getStringList(_keyFavouritesList) ?? [];
    return data;
  }
}
