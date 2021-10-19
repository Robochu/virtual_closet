abstract class Clothing {
  String getType();
  int getSize();
  String getColor();
  bool getLaundryStatus();
  @override
  String toString();
}

abstract class UpperHalf implements Clothing {
  String type;
  int size;
  String color;
  bool isLaundry;
  UpperHalf(this.type, this.size, this.color, this.isLaundry);

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
  bool getLaundryStatus() {
    return this.isLaundry;
  }

  bool setLaundryStatus(bool isLaundry) => this.isLaundry = isLaundry;

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
  bool isLaundry;
  LowerHalf(this.type, this.size, this.color, this.fit, this.isLaundry);
  String getFit();
}



