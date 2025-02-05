import 'package:flutter/material.dart';

import '../../data/memory_repository.dart';

class MemoryAtlasHomeScreen extends StatefulWidget {
  const MemoryAtlasHomeScreen({super.key});

  @override
  State<MemoryAtlasHomeScreen> createState() => _MemoryAtlasHomeScreenState();
}

class _MemoryAtlasHomeScreenState extends State<MemoryAtlasHomeScreen> {
  final _placeController = TextEditingController();
  final _titleController = TextEditingController();
  final _senseController = TextEditingController();
  final _repository = MemoryRepository();

  List<MemoryMoment> _moments = const [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _syncError;

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
    _repository.dispose();
    super.dispose();
  }

  Future<void> _loadMoments() async {
    try {
      final moments = await _repository.list();
      if (!mounted) return;
      setState(() {
        _moments = moments;
        _isLoading = false;
        _syncError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _syncError = '서버와 연결할 수 없습니다. 네트워크 상태를 확인해 주세요.';
      });
    }
  }

  Future<void> _addMoment() async {
    final place = _placeController.text.trim();
    final title = _titleController.text.trim();
    if (place.isEmpty || title.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final moment = await _repository.create(
        place: place,
        title: title,
        sense: _senseController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _moments = [moment, ..._moments];
        _isSaving = false;
        _syncError = null;
      });
      _placeController.clear();
      _titleController.clear();
      _senseController.clear();
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _syncError = '기억을 저장하지 못했습니다. 잠시 후 다시 시도해 주세요.';
      });
    }
  }

  Future<void> _removeMoment(String id) async {
    final previous = _moments;
    setState(() => _moments = _moments.where((moment) => moment.id != id).toList());
    try {
      await _repository.remove(id);
      if (!mounted) return;
      setState(() => _syncError = null);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _moments = previous;
        _syncError = '기억을 삭제하지 못했습니다.';
      });
    }
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
                onPressed: _isSaving ? null : _addMoment,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD6B56D),
                  foregroundColor: const Color(0xFF121317),
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(_isSaving ? '저장 중…' : '기억 저장'),
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
                  if (_syncError != null) ...[
                    _SyncNotice(message: _syncError!, onRetry: _loadMoments),
                    const SizedBox(height: 14),
                  ],
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
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFD6B56D)),
                ),
              )
            else if (_moments.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Text(
                      '첫 장소의 첫 순간을 남겨보세요.\n기록은 Memory Atlas에 안전하게 동기화됩니다.',
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

class _SyncNotice extends StatelessWidget {
  const _SyncNotice({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 18, color: Colors.white54),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ),
          TextButton(onPressed: onRetry, child: const Text('다시 연결')),
        ],
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
