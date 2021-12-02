
import '../../clothes.dart';
import 'dart:math';
class Outfit {
  String name;
  String id = '';
  List<String>? ref;
  List<Clothing> clothes;
  DateTime? recommendationDate;
  String recommendationFrequency;

  Outfit(this.name, this.clothes, this.id, {this.ref, this.recommendationDate,
    this.recommendationFrequency = 'Never'});

  Outfit.clone(Outfit other): this(other.name, [...other.clothes], other.id);

}
