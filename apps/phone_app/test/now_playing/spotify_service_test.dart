import 'dart:convert';

import 'package:bt_speaker/features/now_playing/data/spotify_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

class _MockClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  group('SpotifyService', () {
    late _MockStorage storage;
    late _MockClient client;
    late SpotifyService service;

    setUp(() {
      storage = _MockStorage();
      client = _MockClient();
      service = SpotifyService(storage: storage, client: client);
    });

    test('isAuthenticated is false when no token is stored', () async {
      when(
        () => storage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);

      expect(await service.isAuthenticated, isFalse);
    });

    test('isAuthenticated is true when a token is stored', () async {
      when(
        () => storage.read(key: 'spotify_access_token'),
      ).thenAnswer((_) async => 'token');

      expect(await service.isAuthenticated, isTrue);
    });

    test('currentlyPlaying returns null when no token is stored', () async {
      when(
        () => storage.read(key: 'spotify_access_token'),
      ).thenAnswer((_) async => null);

      expect(await service.currentlyPlaying(), isNull);
    });

    test('currentlyPlaying returns null on 204 (nothing playing)', () async {
      when(
        () => storage.read(key: 'spotify_access_token'),
      ).thenAnswer((_) async => 'token');
      when(
        () => client.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('', 204));

      expect(await service.currentlyPlaying(), isNull);
    });

    test('currentlyPlaying parses a track from a 200 response', () async {
      when(
        () => storage.read(key: 'spotify_access_token'),
      ).thenAnswer((_) async => 'token');
      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'progress_ms': 1000,
            'item': {
              'name': 'Song',
              'duration_ms': 200000,
              'artists': [
                {'name': 'Artist One'},
                {'name': 'Artist Two'},
              ],
              'album': {'name': 'Album', 'images': <Map<String, dynamic>>[]},
            },
          }),
          200,
        ),
      );

      final track = await service.currentlyPlaying();

      expect(track, isNotNull);
      expect(track!.title, 'Song');
      expect(track.artist, 'Artist One, Artist Two');
      expect(track.album, 'Album');
      expect(track.progressMs, 1000);
      expect(track.durationMs, 200000);
      expect(track.albumArtBase64, isNull);
    });

    test('currentlyPlaying refreshes the token on 401 and retries', () async {
      when(
        () => storage.read(key: 'spotify_access_token'),
      ).thenAnswer((_) async => 'expired-token');
      when(
        () => storage.read(key: 'spotify_refresh_token'),
      ).thenAnswer((_) async => 'refresh-token');
      when(
        () =>
            storage.write(key: any(named: 'key'), value: any(named: 'value')),
      ).thenAnswer((_) async {});

      var callCount = 0;
      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer((
        _,
      ) async {
        callCount++;
        return callCount == 1 ? http.Response('', 401) : http.Response('', 204);
      });
      when(
        () => client.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async =>
            http.Response(jsonEncode({'access_token': 'new-token'}), 200),
      );

      final result = await service.currentlyPlaying();

      expect(result, isNull);
      verify(
        () => storage.write(key: 'spotify_access_token', value: 'new-token'),
      ).called(1);
    });

    test('currentlyPlaying returns null when the request throws', () async {
      when(
        () => storage.read(key: 'spotify_access_token'),
      ).thenAnswer((_) async => 'token');
      when(
        () => client.get(any(), headers: any(named: 'headers')),
      ).thenThrow(Exception('network down'));

      expect(await service.currentlyPlaying(), isNull);
    });

    test('logout clears stored tokens', () async {
      when(
        () => storage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      await service.logout();

      verify(() => storage.delete(key: 'spotify_access_token')).called(1);
      verify(() => storage.delete(key: 'spotify_refresh_token')).called(1);
    });
  });
}
