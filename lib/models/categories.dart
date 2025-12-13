class Categories {
  final int id;
  final String name;

  Categories({required this.id, required this.name});
}

final categories = <Categories>[
  Categories(id: 0, name: 'Todas'),
  Categories(id: 1, name: 'Favoritos'), 
  Categories(id: 2, name: 'Calle'),
  Categories(id: 3, name: 'Fino'),
  Categories(id: 4, name: 'Relajado'),
];

