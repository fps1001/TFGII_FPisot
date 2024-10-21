import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_app/blocs/gps/gps_bloc.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:geolocator/geolocator.dart' as geo;

// Mockeamos las dependencias necesarias
class MockPermission extends Mock implements permission.Permission {}
class MockGeolocator extends Mock implements geo.GeolocatorPlatform {}

void main() {
  late GpsBloc gpsBloc;
  late MockGeolocator mockGeolocator;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    mockGeolocator = MockGeolocator();
    geo.GeolocatorPlatform.instance = mockGeolocator;

    // Configura los mocks correctamente
    when(() => mockGeolocator.isLocationServiceEnabled())
        .thenAnswer((_) async => true);
    when(() => mockGeolocator.getServiceStatusStream())
        .thenAnswer((_) => Stream.value(geo.ServiceStatus.enabled));

    gpsBloc = GpsBloc();
  });

  tearDown(() {
    gpsBloc.close();
  });

  setUpAll(() {
    registerFallbackValue(const GpsState(isGpsEnabled: false, isGpsPermissionGranted: false));
  });

  group('GpsBloc Tests', () {
    test('Initial state is GpsState with isGpsEnabled and isGpsPermissionGranted set to false', () {
      expect(
        gpsBloc.state,
        const GpsState(isGpsEnabled: false, isGpsPermissionGranted: false),
      );
    });

    blocTest<GpsBloc, GpsState>(
      'emits [isGpsEnabled: true, isGpsPermissionGranted: true] when OnGpsAndPermissionEvent is added',
      build: () => gpsBloc,
      act: (bloc) => bloc.add(const OnGpsAndPermissionEvent(
        isGpsEnabled: true,
        isGpsPermissionGranted: true,
      )),
      expect: () => [
        const GpsState(isGpsEnabled: true, isGpsPermissionGranted: true),
      ],
    );

    blocTest<GpsBloc, GpsState>(
      'calls askGpsAccess and emits [isGpsPermissionGranted: true] when permission is granted',
      setUp: () {
        when(() => permission.Permission.location.request())
            .thenAnswer((_) async => permission.PermissionStatus.granted);
      },
      build: () => gpsBloc,
      act: (bloc) => bloc.askGpsAccess(),
      expect: () => [
        const GpsState(isGpsEnabled: false, isGpsPermissionGranted: true),
      ],
    );

    blocTest<GpsBloc, GpsState>(
      'emits [isGpsPermissionGranted: false] when permission is denied',
      setUp: () {
        when(() => permission.Permission.location.request())
            .thenAnswer((_) async => permission.PermissionStatus.denied);
      },
      build: () => gpsBloc,
      act: (bloc) => bloc.askGpsAccess(),
      expect: () => [
        const GpsState(isGpsEnabled: false, isGpsPermissionGranted: false),
      ],
    );

    blocTest<GpsBloc, GpsState>(
      'emits [isGpsEnabled: true] when GPS is enabled',
      setUp: () {
        when(() => mockGeolocator.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
      },
      build: () => gpsBloc,
      act: (bloc) => bloc.checkGpsStatus(),
      expect: () => [
        const GpsState(isGpsEnabled: true, isGpsPermissionGranted: false),
      ],
    );

    blocTest<GpsBloc, GpsState>(
      'emits [isGpsEnabled: false] when GPS is disabled',
      setUp: () {
        when(() => mockGeolocator.isLocationServiceEnabled())
            .thenAnswer((_) async => false);
      },
      build: () => gpsBloc,
      act: (bloc) => bloc.checkGpsStatus(),
      expect: () => [
        const GpsState(isGpsEnabled: false, isGpsPermissionGranted: false),
      ],
    );
  });
}
