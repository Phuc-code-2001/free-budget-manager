class Category {
  String name;
  String iconText;

  Category({ required this.name, required this.iconText });

  @override
  bool operator == (other) {
    return (other is Category)
        && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconText': iconText,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      iconText: json['iconText'],
    );
  }
}
