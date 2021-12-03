import 'package:virtual_closet/clothes.dart';
import 'package:collection/collection.dart';
import 'package:virtual_closet/screens/combinations/outfit.dart';
import 'package:virtual_closet/service/database.dart';

class Recommendation {
  int score;
  Clothing clothing;

  Recommendation({required this.score, required this.clothing});

}

class RecommendationQueue {
  List<Clothing> closet;
  List<String> attributes;
  List<Outfit> outfits;
  List<Clothing> blacklist = [];
  List<Clothing> whitelist = [];
  List<Recommendation> recommendations = <Recommendation>[];
  RecommendationQueue({required this.closet, required this.attributes, required this.outfits}) {
    for (var item in closet) {
      //print(item.link);
      recommendations.add(Recommendation(score: 0, clothing: item));
    }
    //print('');
    //print(outfits.length);
    for (Outfit outfit in outfits) {
      if (outfit.recommendationDate != null &&
        outfit.recommendationDate!.difference(DateTime.now()).inDays <= 7) {
        if (outfit.recommendationDate!.difference(DateTime.now()).inDays == 0) {
          whitelist.addAll(outfit.clothes);
        } else {
          blacklist.addAll(outfit.clothes);
        }
      }
    }
  }

  PriorityQueue<Recommendation> get queue {
    PriorityQueue<Recommendation> queue = PriorityQueue<Recommendation>((a,b) {
      int res = b.score.compareTo(a.score);
      if(res == 0) {
        return res+1;
      } else {
        return res;
      }

    });
    calculateScore();
    recommendations.removeWhere((element) => element.score == 0);
    recommendations.removeWhere((element) => element.clothing.isLaundry == true);
    queue.addAll(recommendations);
    return queue;
  }

  void calculateScore() {
    for(var item in recommendations) {
      if (blacklist.contains(item.clothing)) {
        item.score = 0;
        continue;
      } else if (whitelist.contains(item.clothing)) {
        item.score = 20;
        continue;
      }

      if(attributes.contains(item.clothing.category)) {
        item.score = item.score+ 1;
      }
      if(attributes.contains(item.clothing.item)) {
        item.score = item.score + 1;
      }
      if(attributes.contains(item.clothing.color)) {
        item.score = item.score + 1;
      }
      if(attributes.contains(item.clothing.materials)) {
        item.score = item.score + 1;
      }
      if(attributes.contains(item.clothing.sleeves)) {
        item.score = item.score + 1;
      }
      if(item.clothing.isFavorite) {
        item.score = item.score + 3;
      }
    }
  }

}