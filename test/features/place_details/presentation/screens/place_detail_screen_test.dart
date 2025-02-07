import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
// import 'package:cherryrecorder_client/features/map/presentation/screens/map_screen.dart' show Place; // Remove this old import
import 'package:cherryrecorder_client/core/models/place.dart'; // Import Place from core/models
import 'package:cherryrecorder_client/core/models/place_detail.dart';
import 'package:cherryrecorder_client/features/place_details/presentation/providers/place_detail_view_model.dart';
import 'package:cherryrecorder_client/features/place_details/presentation/screens/place_detail_screen.dart';
import 'package:cherryrecorder_client/features/place_details/presentation/screens/memo_add_screen.dart';
import 'package:cherryrecorder_client/core/models/memo.dart'; // Memo 모델 임포트
import 'package:google_maps_flutter/google_maps_flutter.dart'; // LatLng 임포트

class FakePlaceDetailViewModel extends PlaceDetailViewModel {
  bool loading = false;
  String? errorMessage;
  List<Memo> memoItems = [];
  PlaceDetail? detail;
  String? loadedPlaceId;

  @override
  bool get isLoading => loading;

  @override
  String? get error => errorMessage;

  @override
  List<Memo> get memos => memoItems;

  @override
  PlaceDetail? get placeDetail => detail;

  @override
  Future<void> loadData(String placeId) async {
    loadedPlaceId = placeId;
  }

  @override
  Future<void> loadMemos(String placeId) async {}
}

void main() {
  late FakePlaceDetailViewModel viewModel;

  // 테스트용 데이터
  final testPlace = Place(
    id: 'test_place_id',
    name: 'Test Place',
    address: 'Test Address',
    location: const LatLng(37.5, 127.0),
    acceptsCreditCard: true,
  );
  final testMemo = Memo(
    id: 'memo1',
    placeId: testPlace.id,
    latitude: testPlace.location.latitude,
    longitude: testPlace.location.longitude,
    content: 'Test memo content',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  late PlaceDetail testPlaceDetail;

  // 각 테스트 전에 실행될 설정
  setUp(() {
    viewModel = FakePlaceDetailViewModel();
    testPlaceDetail = PlaceDetail(
      placeId: testPlace.id,
      name: testPlace.name,
      formattedAddress: testPlace.address,
      location: testPlace.location,
      photoReferences: const [],
    );

    viewModel.detail = testPlaceDetail;
  });

  // 테스트 위젯을 빌드하는 헬퍼 함수
  Widget createTestWidget() {
    return ChangeNotifierProvider<PlaceDetailViewModel>.value(
      value: viewModel,
      child: MaterialApp(
        home: PlaceDetailScreen(
          placeData: {
            'id': testPlace.id,
            'name': testPlace.name,
            'address': testPlace.address,
            'location': {
              'latitude': testPlace.location.latitude,
              'longitude': testPlace.location.longitude,
            },
            'acceptsCreditCard': testPlace.acceptsCreditCard,
          },
        ),
      ),
    );
  }

  testWidgets(
    'PlaceDetailScreen shows place name and address',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text(testPlace.name), findsOneWidget);
      expect(find.text(testPlace.address), findsOneWidget);
      expect(viewModel.loadedPlaceId, testPlace.id);
    },
  );

  testWidgets('Shows loading indicator when isLoading is true', (
    WidgetTester tester,
  ) async {
    viewModel.loading = true;
    await tester.pumpWidget(createTestWidget());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Shows error message when error is not null', (
    WidgetTester tester,
  ) async {
    const errorMessage = 'Failed to load memos';
    viewModel.errorMessage = errorMessage;
    await tester.pumpWidget(createTestWidget());
    expect(find.textContaining(errorMessage), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Shows "no memos" message when memos list is empty', (
    WidgetTester tester,
  ) async {
    viewModel.loading = false;
    viewModel.memoItems = [];
    await tester.pumpWidget(createTestWidget());
    expect(find.text('아직 기록된 메모가 없습니다.'), findsOneWidget);
  });

  testWidgets('Shows memo list when memos are available', (
    WidgetTester tester,
  ) async {
    viewModel.loading = false;
    viewModel.memoItems = [testMemo];
    await tester.pumpWidget(createTestWidget());
    expect(find.text(testMemo.content), findsOneWidget);
  });

  testWidgets('FloatingActionButton is present on non-web', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  // 웹 환경 테스트는 kIsWeb 값을 제어하기 어려워 별도 설정이나 조건부 로직 필요
  // testWidgets('FloatingActionButton is hidden on web', (WidgetTester tester) async { ... });

  testWidgets('Tapping FAB opens MemoAddScreen', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(MemoAddScreen), findsOneWidget);
  });
}
