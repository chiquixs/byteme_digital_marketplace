class ReviewModel {
  final String reviewId;
  final String userId;
  final String produkId;
  final int rating;
  final String? komentar;
  final DateTime? tglReview;
  final String? username;
  final String? avatar;
  final String? namaProduk;
  final String? filePath;

  ReviewModel({
    required this.reviewId,
    required this.userId,
    required this.produkId,
    required this.rating,
    this.komentar,
    this.tglReview,
    this.username,
    this.avatar,
    this.namaProduk,
    this.filePath,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewId:   json['review_id'],
      userId:     json['user_id'],
      produkId:   json['produk_id'],
      rating:     json['rating'],
      komentar:   json['komentar'],
      tglReview:  json['tgl_review'] != null
                    ? DateTime.parse(json['tgl_review'])
                    : null,
      username:   json['username'],
      avatar:     json['avatar'],
      namaProduk: json['nama_produk'],
      filePath:   json['file_path'],
    );
  }
}