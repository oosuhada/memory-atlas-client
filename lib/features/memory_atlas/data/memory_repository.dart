import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';

class MemoryMoment {
  const MemoryMoment({
    required this.id,
    required this.place,
    required this.title,
    required this.sense,
    required this.createdAt,
  });

  final String id;
  final String place;
  final String title;
  final String sense;
  final DateTime createdAt;

  factory MemoryMoment.fromJson(Map<String, dynamic> json) {
    final epoch = json['createdAtEpochMs'];
    final iso = json['createdAt'];
    final createdAt = epoch is num
        ? DateTime.fromMillisecondsSinceEpoch(epoch.toInt())
        : iso is String
            ? DateTime.tryParse(iso) ?? DateTime.now()
            : DateTime.now();

    return MemoryMoment(
      id: json['id']?.toString() ?? '',
      place: json['place']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      sense: json['sense']?.toString() ?? '',
      createdAt: createdAt,
    );
  }
}

class MemoryRepository {
  MemoryRepository({ApiClient? apiClient})
      : _apiClient = apiClient ??
            ApiClient(
              client: http.Client(),
              baseUrl: const String.fromEnvironment(
                'WEB_API_BASE_URL',
                defaultValue: 'http://localhost:8080',
              ),
            ),
        _ownsClient = apiClient == null;

  final ApiClient _apiClient;
  final bool _ownsClient;

  Future<List<MemoryMoment>> list() async {
    final response = await _apiClient.get('/memories');
    final items = response['items'];
    if (items is! List) return const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(MemoryMoment.fromJson)
        .toList(growable: false);
  }

  Future<MemoryMoment> create({
    required String place,
    required String title,
    required String sense,
  }) async {
    final response = await _apiClient.post(
      '/memories',
      body: {'place': place, 'title': title, 'sense': sense},
    );
    return MemoryMoment.fromJson(response);
  }

  Future<void> remove(String id) async {
    await _apiClient.delete('/memories/${Uri.encodeComponent(id)}');
  }

  void dispose() {
    if (_ownsClient) _apiClient.dispose();
  }
}
