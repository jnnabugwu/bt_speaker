import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:bt_speaker/features/now_playing/data/spotify_service.dart';

/// Listens for the `btspkr://callback` redirect for the lifetime of the app
/// and exchanges the auth code as soon as it arrives.
///
/// This must run from app start (not from a screen further down the
/// navigation stack) — iOS can kill the app while Safari is showing the
/// Spotify login, so the redirect may be the event that relaunches the
/// process. Exchanging the code here, independent of which screen is
/// mounted, means the token is already in secure storage by the time the
/// user navigates back to a screen that needs it.
class SpotifyAuthGateway {
  /// Creates a [SpotifyAuthGateway] backed by [spotifyService].
  SpotifyAuthGateway({required SpotifyService spotifyService})
      : _spotify = spotifyService;

  final SpotifyService _spotify;
  final _authCompleted = StreamController<void>.broadcast();
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;

  /// Fires each time an auth code is successfully exchanged for tokens.
  Stream<void> get authCompleted => _authCompleted.stream;

  /// Begins listening for the OAuth redirect. Call once at app startup.
  Future<void> start() async {
    _linkSub = _appLinks.uriLinkStream.listen(_handleLink);
    final initial = await _appLinks.getInitialLink();
    if (initial != null) await _handleLink(initial);
  }

  Future<void> _handleLink(Uri uri) async {
    if (uri.scheme != 'btspkr' || uri.host != 'callback') return;
    final code = uri.queryParameters['code'];
    if (code == null) return;
    await _spotify.handleCallback(code);
    _authCompleted.add(null);
  }

  /// Cancels the link subscription and closes the completion stream.
  void dispose() {
    _linkSub?.cancel();
    _authCompleted.close();
  }
}
