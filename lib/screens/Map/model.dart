class DataModel {
  final String id;
  final String name;
  final double long;
  final double latt;
  final String desc;
  final String price;
  final String category;
  final List<String> others;

  DataModel({
    required this.id,
    required this.long,
    required this.latt,
    required this.desc,
    required this.price,
    required this.others,
    required this.category,
    required this.name,
  });

  static DataModel fromJson(Map<String, dynamic> json) => DataModel(
    id: json['id'],
    long: json['long'],
    desc: json['desc'],
    latt: json['latt'],
    name: json['name'],
    others: json['others'],
    category: json['category'],
    price: json['price'],
  );
}
