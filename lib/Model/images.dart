class Images {
  String? id;
  late final String name;
  late final String url;

  Images({
    this.id = '',
    required this.name,
    required this.url,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url,
  };
  static Images fromJson(Map<String, dynamic> json) => Images(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    url: json['url'] ?? '',
  );
}
