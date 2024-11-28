class Review {
  final String userName;
  final String reviewText;
  final double rating;
  final DateTime dateTime;

  Review({
    required this.userName,
    required this.reviewText,
    required this.rating,
    required this.dateTime,
  });

  // Convert Review object to a map
  Map<String, dynamic> toMap() {
    return {
      'customer': userName,
      'feedback': reviewText,
      'star': rating,
      'datetime': dateTime,
    };
  }
}
