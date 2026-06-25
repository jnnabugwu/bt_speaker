import 'package:bt_speaker/features/led/bloc/led_bloc.dart';
import 'package:bt_speaker_core/led_command.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Screen with LED mode selector, RGB sliders, and a color preview swatch.
class LedScreen extends StatelessWidget {
  /// Creates a [LedScreen].
  const LedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LedBloc, LedState>(
      builder: (context, state) {
        final s = state as LedCurrent;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LED Control',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              DropdownButton<LedMode>(
                value: s.mode,
                items: LedMode.values
                    .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                    .toList(),
                onChanged: (m) {
                  if (m == null) return;
                  context.read<LedBloc>().add(
                    LedCommandChanged(
                      mode: m,
                      r: s.r,
                      g: s.g,
                      b: s.b,
                      brightness: s.brightness,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _ColorSlider(
                label: 'Red',
                color: Colors.red,
                value: s.r,
                onChangeEnd: (v) => context.read<LedBloc>().add(
                  LedCommandChanged(
                    mode: s.mode,
                    r: v,
                    g: s.g,
                    b: s.b,
                    brightness: s.brightness,
                  ),
                ),
              ),
              _ColorSlider(
                label: 'Green',
                color: Colors.green,
                value: s.g,
                onChangeEnd: (v) => context.read<LedBloc>().add(
                  LedCommandChanged(
                    mode: s.mode,
                    r: s.r,
                    g: v,
                    b: s.b,
                    brightness: s.brightness,
                  ),
                ),
              ),
              _ColorSlider(
                label: 'Blue',
                color: Colors.blue,
                value: s.b,
                onChangeEnd: (v) => context.read<LedBloc>().add(
                  LedCommandChanged(
                    mode: s.mode,
                    r: s.r,
                    g: s.g,
                    b: v,
                    brightness: s.brightness,
                  ),
                ),
              ),
              _ColorSlider(
                label: 'Brightness',
                color: Colors.white,
                value: s.brightness,
                onChangeEnd: (v) => context.read<LedBloc>().add(
                  LedCommandChanged(
                    mode: s.mode,
                    r: s.r,
                    g: s.g,
                    b: s.b,
                    brightness: v,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(s.r, s.g, s.b, 1),
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ColorSlider extends StatefulWidget {
  const _ColorSlider({
    required this.label,
    required this.color,
    required this.value,
    required this.onChangeEnd,
  });

  final String label;
  final Color color;
  final int value;
  final void Function(int) onChangeEnd;

  @override
  State<_ColorSlider> createState() => _ColorSliderState();
}

class _ColorSliderState extends State<_ColorSlider> {
  late double _current;

  @override
  void initState() {
    super.initState();
    _current = widget.value.toDouble();
  }

  @override
  void didUpdateWidget(_ColorSlider old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _current = widget.value.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(widget.label)),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: widget.color,
              thumbColor: widget.color,
            ),
            child: Slider(
              value: _current,
              max: 255,
              divisions: 255,
              onChanged: (v) => setState(() => _current = v),
              onChangeEnd: (v) => widget.onChangeEnd(v.round()),
            ),
          ),
        ),
        SizedBox(width: 40, child: Text(_current.round().toString())),
      ],
    );
  }
}
