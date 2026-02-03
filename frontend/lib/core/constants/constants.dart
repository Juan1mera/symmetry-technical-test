import 'package:flutter_dotenv/flutter_dotenv.dart';

String newsAPIBaseURL = dotenv.env['NEWS_API_BASE_URL']!;
String newsAPIKey = dotenv.env['NEWS_API_KEY']!;
String countryQuery = dotenv.env['COUNTRY_QUERY']!;
String categoryQuery = dotenv.env['CATEGORY_QUERY']!;
String kDefaultImage = dotenv.env['DEFAULT_IMAGE']!;