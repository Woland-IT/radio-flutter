class RadioStation {
  final String name;
  final int bitrate;
  final String url;

  RadioStation({required this.name, required this.bitrate, required this.url});

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      name: json['name'] ?? 'Unknown',
      bitrate: json['bitrate'] ?? 0,
      url: json['url_resolved'] ?? json['url'] ?? '',
    );
  }
}