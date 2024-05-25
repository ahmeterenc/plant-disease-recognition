class DiseasePrediction {
  final String prediction;
  final String recommendation;
  final bool success;

  DiseasePrediction({
    required this.prediction,
    required this.recommendation,
    required this.success,
  });

  factory DiseasePrediction.fromJson(Map<String, dynamic> json) {
    return DiseasePrediction(
      prediction: json['prediction'] as String,
      recommendation: json['recommendation'] as String,
      success: json['success'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction,
      'recommendation': recommendation,
      'success': success,
    };
  }
}
