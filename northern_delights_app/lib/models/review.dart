class Review {
  final String userName;
  final String reviewText;
  final double foodRating;
  final double svcRating;
  final double atmosRating;
  final String? reviewImage;
  final DateTime dateTime;

  Review({
    required this.userName,
    required this.reviewText,
    required this.foodRating,
    required this.svcRating,
    required this.atmosRating,
    required this.reviewImage,
    required this.dateTime,
  });

  // Convert Review object to a map
  Map<String, dynamic> toMap() {
    return {
      'customer': userName,
      'feedback': reviewText,
      'foodRating': foodRating,
      'serviceRating': svcRating,
      'atmosphereRating': atmosRating,
      'reviewimage': reviewImage,
      'datetime': dateTime,
    };
  }
}
