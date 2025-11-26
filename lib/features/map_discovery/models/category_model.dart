class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

final List<CategoryModel> mockCategories = [
  CategoryModel(
    id: '1',
    name: 'Vegetables',
    imageUrl: 'https://cdn-icons-png.flaticon.com/512/2329/2329903.png',
  ),
  CategoryModel(
    id: '2',
    name: 'Fruits',
    imageUrl: 'https://cdn-icons-png.flaticon.com/512/1625/1625048.png',
  ),
  CategoryModel(
    id: '3',
    name: 'Dairy',
    imageUrl: 'https://cdn-icons-png.flaticon.com/512/2674/2674486.png',
  ),
  CategoryModel(
    id: '4',
    name: 'Bakery',
    imageUrl: 'https://cdn-icons-png.flaticon.com/512/992/992747.png',
  ),
  CategoryModel(
    id: '5',
    name: 'Eggs',
    imageUrl: 'https://cdn-icons-png.flaticon.com/512/837/837560.png',
  ),
  CategoryModel(
    id: '6',
    name: 'Munchies',
    imageUrl: 'https://cdn-icons-png.flaticon.com/512/2553/2553691.png',
  ),
  CategoryModel(
    id: '7',
    name: 'Cold Drinks',
    imageUrl: 'https://cdn-icons-png.flaticon.com/512/2405/2405479.png',
  ),
  CategoryModel(
    id: '8',
    name: 'Instant Food',
    imageUrl: 'https://cdn-icons-png.flaticon.com/512/2515/2515183.png',
  ),
];
