class CategoryModel {
  final String? categoryId;
  final String? categoryName;
  final String? parentId;

  CategoryModel({
    this.categoryId,
    this.categoryName,
    this.parentId,
  });

  CategoryModel.fromJson(Map<String, dynamic> json)
      : categoryId = json['category_id'].toString(),
        categoryName = json['category_name'].toString(),
        parentId = json['parent_id'].toString();

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'category_name': categoryName,
        'parent_id': parentId,
      };
}
