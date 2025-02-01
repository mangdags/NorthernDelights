class Review {
  final String userName;
  final String reviewText;
  final double rating;
  final String? reviewImage;
  final DateTime dateTime;

  Review({
    required this.userName,
    required this.reviewText,
    required this.rating,
    required this.reviewImage,
    required this.dateTime,
  });

  // Convert Review object to a map
  Map<String, dynamic> toMap() {
    return {
      'customer': userName,
      'feedback': reviewText,
      'star': rating,
      'reviewimage': reviewImage,
      'datetime': dateTime,
    };
  }
}
