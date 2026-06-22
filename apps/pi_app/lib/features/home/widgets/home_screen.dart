import 'package:flutter/material.dart';
import 'package:pi_app/features/connections/widgets/connection_banner.dart';
import 'package:pi_app/features/now_playing/widgets/now_playing_bar.dart';
import 'package:pi_app/features/visualizer/widgets/visualizer_canvas.dart';

/// The main screen of the Pi app.
///
/// Composes [ConnectionBanner], [VisualizerCanvas], and [NowPlayingBar]
/// into a full-screen layout suited for an HDMI display.
class HomeScreen extends StatelessWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black,
      child: Column(
        children: [
          ConnectionBanner(),
          Expanded(child: VisualizerCanvas()),
          NowPlayingBar(),
        ],
      ),
    );
  }
}
