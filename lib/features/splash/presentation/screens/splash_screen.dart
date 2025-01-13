import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';

/// 앱 시작 시 표시되는 스플래시 화면 위젯.
class SplashScreen extends StatefulWidget {
  /// 기본 생성자.
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// [SplashScreen]의 상태 관리 클래스.
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 2초 후 메인 화면으로 자동 이동
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/atlas');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101114),
      body: SafeArea(
        child: Stack(
          // Column을 Stack으로 변경하여 위치를 자유롭게 조정
          children: <Widget>[
            // 로고를 중앙에 배치
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SvgPicture.asset('assets/images/logo.svg', width: 86, height: 90),
                  const SizedBox(height: 22),
                  const Text(
                    'MEMORY ATLAS',
                    style: TextStyle(
                      color: Color(0xFFD6B56D),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.2,
                    ),
                  ),
                ],
              ),
            ),
            // "나만의 혜택 기록장" 텍스트를 하단 중앙에 배치
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 48.0), // 하단 여백 추가
                child: const Text(
                  'Places become memories.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
