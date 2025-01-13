import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'place': place,
      'title': title,
      'sense': sense,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MemoryMoment.fromJson(Map<String, dynamic> json) {
    return MemoryMoment(
      id: json['id'] as String,
      place: json['place'] as String,
      title: json['title'] as String,
      sense: json['sense'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class MemoryAtlasHomeScreen extends StatefulWidget {
  const MemoryAtlasHomeScreen({super.key});

  @override
  State<MemoryAtlasHomeScreen> createState() => _MemoryAtlasHomeScreenState();
}

class _MemoryAtlasHomeScreenState extends State<MemoryAtlasHomeScreen> {
  static const _storageKey = 'memory_atlas.moments.v1';

  final _placeController = TextEditingController();
  final _titleController = TextEditingController();
  final _senseController = TextEditingController();

  List<MemoryMoment> _moments = const [];

  @override
  void initState() {
    super.initState();
    _loadMoments();
  }

  @override
  void dispose() {
    _placeController.dispose();
    _titleController.dispose();
    _senseController.dispose();
    super.dispose();
  }

  Future<void> _loadMoments() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final moments = decoded
          .map((item) => MemoryMoment.fromJson(item as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() => _moments = moments);
    } catch (_) {
      await preferences.remove(_storageKey);
    }
  }

  Future<void> _saveMoments(List<MemoryMoment> moments) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(moments.map((moment) => moment.toJson()).toList()),
    );
  }

  Future<void> _addMoment() async {
    final place = _placeController.text.trim();
    final title = _titleController.text.trim();
    if (place.isEmpty || title.isEmpty) return;

    final moment = MemoryMoment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      place: place,
      title: title,
      sense: _senseController.text.trim(),
      createdAt: DateTime.now(),
    );
    final nextMoments = [moment, ..._moments];
    await _saveMoments(nextMoments);
    if (!mounted) return;
    setState(() => _moments = nextMoments);
    _placeController.clear();
    _titleController.clear();
    _senseController.clear();
    Navigator.pop(context);
  }

  Future<void> _removeMoment(String id) async {
    final nextMoments = _moments.where((moment) => moment.id != id).toList();
    await _saveMoments(nextMoments);
    if (!mounted) return;
    setState(() => _moments = nextMoments);
  }

  void _openMomentComposer() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181A1F),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '새로운 순간',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '장소와 함께 기억하고 싶은 감각을 남겨보세요.',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 20),
              _MemoryTextField(controller: _placeController, label: '장소'),
              const SizedBox(height: 12),
              _MemoryTextField(controller: _titleController, label: '기억의 제목'),
              const SizedBox(height: 12),
              _MemoryTextField(
                controller: _senseController,
                label: '향, 음악, 맛, 기분 등 감각 메모',
                maxLines: 3,
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _addMoment,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD6B56D),
                  foregroundColor: const Color(0xFF121317),
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text('기억 저장'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101114),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              sliver: SliverList.list(
                children: [
                  const Text(
                    'MEMORY ATLAS',
                    style: TextStyle(
                      color: Color(0xFFD6B56D),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '장소를 저장하는 대신\n장소에 남은 나를 기록합니다.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.map_outlined,
                          title: '지도 열기',
                          subtitle: '주변 장소에서 기억 시작',
                          onTap: () => Navigator.pushNamed(context, '/map'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.auto_awesome_outlined,
                          title: '순간 남기기',
                          subtitle: '감각과 맥락을 함께 기록',
                          onTap: _openMomentComposer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '최근의 순간',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${_moments.length} memories',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            if (_moments.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Text(
                      '첫 장소의 첫 순간을 남겨보세요.\n기록은 이 기기 안에 먼저 안전하게 쌓입니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, height: 1.6),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList.separated(
                  itemCount: _moments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final moment = _moments[index];
                    return Dismissible(
                      key: ValueKey(moment.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _removeMoment(moment.id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade900,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF191B20),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              moment.place,
                              style: const TextStyle(
                                color: Color(0xFFD6B56D),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              moment.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (moment.sense.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                moment.sense,
                                style: const TextStyle(color: Colors.white54, height: 1.5),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF191B20),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFD6B56D)),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white38, fontSize: 11, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryTextField extends StatelessWidget {
  const _MemoryTextField({required this.controller, required this.label, this.maxLines = 1});

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD6B56D)),
        ),
      ),
    );
  }
}
