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
  static const String inbox = '/friends'; // Alias for the Inbox shell tab
  static const String profile = '/profile';
  static const String preferences = '/preferences';
  static const String myPreferences = '/profile/preferences';

  // ── Trip Details & Nested Trip Routes ───────────────────────────────────────
  static const String createTrip = '/trips/create';
  static const String inviteMembers = '/trips/invite';
  static const String reviewTrip = '/trips/review';
  static const String invitationDetails = '/inbox/details';
  static const String invitationSuccess = '/inbox/success';
  static const String tripDetails = '/trips/:tripId';
  static const String itinerary = '/trips/:tripId/itinerary';
  static const String chat = '/trips/:tripId/chat';
  static const String polls = '/trips/:tripId/polls';
  static const String expenses = '/trips/:tripId/expenses';
  static const String memories = '/trips/:tripId/memories';
  static const String addSuggestion = '/trips/:tripId/add-suggestion';
  static const String suggestionDetail = '/trips/:tripId/suggestion-detail';
  static const String aiInsights = '/trips/:tripId/ai-insights';
  static const String plansAlternatives = '/trips/:tripId/plans-alternatives';
  static const String votingCollaboration = '/trips/:tripId/voting-collaboration';

  // ── Dynamic Path Generators ─────────────────────────────────────────────────
  static String tripDetailsPath(String tripId) => '/trips/$tripId';
  static String addSuggestionPath(String tripId) => '/trips/$tripId/add-suggestion';
  static String suggestionDetailPath(String tripId) => '/trips/$tripId/suggestion-detail';
  static String itineraryPath(String tripId) => '/trips/$tripId/itinerary';
  static String chatPath(String tripId) => '/trips/$tripId/chat';
  static String pollsPath(String tripId) => '/trips/$tripId/polls';
  static String expensesPath(String tripId) => '/trips/$tripId/expenses';
  static String memoriesPath(String tripId) => '/trips/$tripId/memories';
  static String aiInsightsPath(String tripId) => '/trips/$tripId/ai-insights';
  static String plansAlternativesPath(String tripId) => '/trips/$tripId/plans-alternatives';
  static String votingCollaborationPath(String tripId) => '/trips/$tripId/voting-collaboration';
}
