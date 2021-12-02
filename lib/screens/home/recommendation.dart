import 'package:virtual_closet/clothes.dart';
import 'package:collection/collection.dart';

class Recommendation {
  int score;
  Clothing clothing;

  Recommendation({required this.score, required this.clothing});

}

class RecommendationQueue {
  List<Clothing> closet;
  List<String> attributes;
  List<Recommendation> recommendations = <Recommendation>[];
  RecommendationQueue({required this.closet, required this.attributes}) {
      for (var item in closet) {
        recommendations.add(Recommendation(score: 0, clothing: item));

    }
  }

  PriorityQueue<Recommendation> get queue {
    PriorityQueue<Recommendation> queue = PriorityQueue<Recommendation>((a,b) => (b.score.compareTo(a.score)));
    calculateScore();
    recommendations.removeWhere((element) => element.score == 0);
    recommendations.removeWhere((element) => element.clothing.isLaundry == true);
    queue.addAll(recommendations);
    return queue;
  }

  void calculateScore() {
    for(var item in recommendations) {
      if(attributes.contains(item.clothing.category)) {
        item.score = item.score+1;
      }
      if(attributes.contains(item.clothing.item)) {
        item.score = item.score +1;
      }
      if(attributes.contains(item.clothing.color)) {
        item.score = item.score +1;
      }
      if(attributes.contains(item.clothing.materials)) {
        item.score = item.score +1;
      }
      if(attributes.contains(item.clothing.sleeves)) {
        item.score = item.score +1;
      }
      if(item.clothing.isFavorite) {
        item.score = item.score * 2;
      }
    }
  }

}