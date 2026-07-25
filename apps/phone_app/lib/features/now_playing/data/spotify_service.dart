import 'dart:convert';
import 'dart:math';

import 'package:bt_speaker/features/now_playing/data/spotify_credentials.dart';
import 'package:bt_speaker_core/now_playing.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const _authEndpoint = 'https://accounts.spotify.com/authorize';
const _tokenEndpoint = 'https://accounts.spotify.com/api/token';
const _nowPlayingEndpoint =
    'https://api.spotify.com/v1/me/player/currently-playing';
const _scope = 'user-read-currently-playing user-read-playback-state';

const _keyAccessToken = 'spotify_access_token';
const _keyRefreshToken = 'spotify_refresh_token';
const _keyCodeVerifier = 'spotify_code_verifier';

/// Handles Spotify PKCE OAuth and the currently-playing API endpoint.
class SpotifyService {
  /// Creates a [SpotifyService] with optional [storage] and [client] overrides.
  SpotifyService({
    FlutterSecureStorage? storage,
    http.Client? client,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _client = client ?? http.Client();

  final FlutterSecureStorage _storage;
  final http.Client _client;

  // ── Auth ──────────────────────────────────────────────────────────────

  /// Returns true if a stored access token exists.
  Future<bool> get isAuthenticated async =>
      (await _storage.read(key: _keyAccessToken)) != null;

  /// Opens the Spotify login page in the browser.
  /// Call [handleCallback] with the redirect URI when the app is re-opened.
  Future<void> authenticate() async {
    final verifier = _generateVerifier();
    final challenge = _challengeFor(verifier);
    await _storage.write(key: _keyCodeVerifier, value: verifier);

    final uri = Uri.parse(_authEndpoint).replace(
      queryParameters: {
        'client_id': spotifyClientId,
        'response_type': 'code',
        'redirect_uri': spotifyRedirectUri,
        'scope': _scope,
        'code_challenge_method': 'S256',
        'code_challenge': challenge,
      },
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Exchanges the auth [code] from the redirect URI for access/refresh tokens.
  Future<void> handleCallback(String code) async {
    final verifier = await _storage.read(key: _keyCodeVerifier);
    if (verifier == null) return;

    final response = await _client.post(
      Uri.parse(_tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': spotifyRedirectUri,
        'client_id': spotifyClientId,
        'code_verifier': verifier,
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      await _storage.write(
        key: _keyAccessToken,
        value: json['access_token'] as String,
      );
      await _storage.write(
        key: _keyRefreshToken,
        value: json['refresh_token'] as String,
      );
      await _storage.delete(key: _keyCodeVerifier);
    }
  }

  /// Clears stored tokens, effectively logging out.
  Future<void> logout() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }

  // ── API ───────────────────────────────────────────────────────────────

  /// Returns the currently playing track, or null if nothing is playing or
  /// the request fails (e.g. no network connectivity).
  /// Automatically refreshes the access token if it has expired (HTTP 401).
  Future<NowPlaying?> currentlyPlaying() async {
    try {
      var token = await _storage.read(key: _keyAccessToken);
      if (token == null) return null;

      var response = await _get(_nowPlayingEndpoint, token);

      if (response.statusCode == 401) {
        final refreshed = await _refresh();
        if (!refreshed) return null;
        token = await _storage.read(key: _keyAccessToken);
        response = await _get(_nowPlayingEndpoint, token!);
      }

      if (response.statusCode == 204 || response.statusCode != 200) {
        return null;
      }

      return await _parseNowPlaying(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────

  Future<http.Response> _get(String url, String token) => _client.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

  Future<bool> _refresh() async {
    final refreshToken = await _storage.read(key: _keyRefreshToken);
    if (refreshToken == null) return false;

    final response = await _client.post(
      Uri.parse(_tokenEndpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': spotifyClientId,
      },
    );

    if (response.statusCode != 200) return false;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    await _storage.write(
      key: _keyAccessToken,
      value: json['access_token'] as String,
    );
    if (json['refresh_token'] != null) {
      await _storage.write(
        key: _keyRefreshToken,
        value: json['refresh_token'] as String,
      );
    }
    return true;
  }

  Future<NowPlaying?> _parseNowPlaying(Map<String, dynamic> json) async {
    final item = json['item'] as Map<String, dynamic>?;
    if (item == null) return null;

    final artists = (item['artists'] as List<dynamic>)
        .map((a) => (a as Map<String, dynamic>)['name'] as String)
        .join(', ');
    final album = item['album'] as Map<String, dynamic>;
    final albumName = album['name'] as String;
    final images = album['images'] as List<dynamic>;
    final artUrl =
        images.isNotEmpty ? (images.first as Map)['url'] as String? : null;

    String? artBase64;
    if (artUrl != null) {
      try {
        final res = await _client.get(Uri.parse(artUrl));
        if (res.statusCode == 200) {
          artBase64 = base64Encode(res.bodyBytes);
        }
      } catch (_) {}
    }

    return NowPlaying(
      title: item['name'] as String,
      artist: artists,
      album: albumName,
      albumArtBase64: artBase64,
      progressMs: (json['progress_ms'] as num).toInt(),
      durationMs: (item['duration_ms'] as num).toInt(),
    );
  }

  // ── PKCE helpers ──────────────────────────────────────────────────────

  static String _generateVerifier() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final rng = Random.secure();
    return List.generate(128, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  static String _challengeFor(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url
        .encode(digest.bytes)
        .replaceAll('=', '')
        .replaceAll('+', '-')
        .replaceAll('/', '_');
  }
}
