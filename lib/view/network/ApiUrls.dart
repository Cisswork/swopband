class ApiUrls {
  static const String baseUrl = 'https://srirangasai.dev';
  static const String createUser = '$baseUrl/users/';
  static const String updateUser = '$baseUrl/users/';  // Will append user ID
  static const String updateUserAlt = '$baseUrl/users/update/';
  static const String createLink = '$baseUrl/links';
  static const String submitReview = '$baseUrl/reviews/';
  static const String uploadImage = '$baseUrl/upload';  // For image uploads
  static const String connections = '$baseUrl/connections/';  // For connections
  static const String userDetails = '$baseUrl/users/';  // For user details (append userId)
}
