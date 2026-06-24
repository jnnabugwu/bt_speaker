import 'package:bt_speaker/features/eq/bloc/eq_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Screen with three EQ band sliders (bass, mid, treble).
class EqScreen extends StatelessWidget {
  /// Creates an [EqScreen].
  const EqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EqBloc, EqState>(
      builder: (context, state) {
        final s = state as EqCurrent;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Equalizer',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _EqSlider(
                label: 'Bass',
                value: s.bass,
                onChangeEnd: (v) => context.read<EqBloc>().add(
                  EqSettingsChanged(bass: v, mid: s.mid, treble: s.treble),
                ),
              ),
              _EqSlider(
                label: 'Mid',
                value: s.mid,
                onChangeEnd: (v) => context.read<EqBloc>().add(
                  EqSettingsChanged(bass: s.bass, mid: v, treble: s.treble),
                ),
              ),
              _EqSlider(
                label: 'Treble',
                value: s.treble,
                onChangeEnd: (v) => context.read<EqBloc>().add(
                  EqSettingsChanged(bass: s.bass, mid: s.mid, treble: v),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EqSlider extends StatefulWidget {
  const _EqSlider({
    required this.label,
    required this.value,
    required this.onChangeEnd,
  });

  final String label;
  final int value;
  final void Function(int) onChangeEnd;

  @override
  State<_EqSlider> createState() => _EqSliderState();
}

class _EqSliderState extends State<_EqSlider> {
  late double _current;

  @override
  void initState() {
    super.initState();
    _current = widget.value.toDouble();
  }

  @override
  void didUpdateWidget(_EqSlider old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _current = widget.value.toDouble();
    }
  }

  String get _label {
    final v = _current.round();
    if (v > 0) return '+$v dB';
    if (v < 0) return '$v dB';
    return '0 dB';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(widget.label)),
        Expanded(
          child: Slider(
            value: _current,
            min: -12,
            max: 12,
            divisions: 24,
            onChanged: (v) => setState(() => _current = v),
            onChangeEnd: (v) => widget.onChangeEnd(v.round()),
          ),
        ),
        SizedBox(width: 56, child: Text(_label)),
      ],
    );
  }
}
