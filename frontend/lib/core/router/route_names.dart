/// Centralized route paths and route path builders for WeTravel.
class RouteNames {
  RouteNames._();

  // ── Public Routes ───────────────────────────────────────────────────────────
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';

  // ── Primary App Shell Routes (Tabs) ─────────────────────────────────────────
  static const String home = '/home';
  static const String trips = '/trips';
  static const String friends = '/friends';
  static const String profile = '/profile';
  static const String preferences = '/preferences';

  // ── Trip Details & Nested Trip Routes ───────────────────────────────────────
  static const String tripDetails = '/trips/:tripId';
  static const String itinerary = '/trips/:tripId/itinerary';
  static const String chat = '/trips/:tripId/chat';
  static const String polls = '/trips/:tripId/polls';
  static const String expenses = '/trips/:tripId/expenses';
  static const String memories = '/trips/:tripId/memories';

  // ── Dynamic Path Generators ─────────────────────────────────────────────────
  static String tripDetailsPath(String tripId) => '/trips/$tripId';
  static String itineraryPath(String tripId) => '/trips/$tripId/itinerary';
  static String chatPath(String tripId) => '/trips/$tripId/chat';
  static String pollsPath(String tripId) => '/trips/$tripId/polls';
  static String expensesPath(String tripId) => '/trips/$tripId/expenses';
  static String memoriesPath(String tripId) => '/trips/$tripId/memories';
}
