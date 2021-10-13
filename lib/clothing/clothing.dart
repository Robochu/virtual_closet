abstract class Clothing {
  String getType();
  int getSize();
  String getColor();
  @override
  String toString();
}

abstract class UpperHalf implements Clothing {
  String type;
  int size;
  String color;
  UpperHalf(this.type, this.size, this.color);

  @override
  String getType() {
    return this.type;
  }
  void setType(String type){
    this.type = type;
  }

  @override
  int getSize() {
    return this.size;
  }

  void setSize(int size){
    this.size = size;
  }

  @override
  String getColor() {
    return this.color;
  }

  void setColor(String color) {
    this.color = color;
  }

  @override
  String toString() {
    return 'Top: {type: ${this.type}, size: ${this.size}, color: ${this.color}';
  }

}

abstract class LowerHalf implements Clothing {
  String type;
  int size;
  String color;
  String fit;
  LowerHalf(this.type, this.size, this.color, this.fit);
  String getFit();
}



