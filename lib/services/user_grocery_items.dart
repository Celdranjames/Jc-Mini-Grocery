import 'dart:convert';

GroceryItems groceryItemsFromJson(String str) =>
    GroceryItems.fromJson(json.decode(str));

class GroceryItems {
  GroceryItems({required this.data});

  final List<ItemData> data;

  factory GroceryItems.fromJson(Map<String, dynamic> json) => GroceryItems(
    data: List<ItemData>.from(json["data"].map((x) => ItemData.fromJson(x))),
  );
}

class ItemData {
  ItemData({
    required this.id,
    required this.itemName,
    required this.category,
    required this.itemImage,
    required this.inStock,
  });

  final int id;
  final String itemName;
  final String category;
  final String itemImage;
  final bool inStock;

  factory ItemData.fromJson(Map<String, dynamic> json) => ItemData(
    id: json["id"],
    itemName: json["itemName"],
    category: json["category"],
    itemImage: json["itemImage"],
    inStock: json["inStock"],
  );
}
