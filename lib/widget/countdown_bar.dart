import 'dart:async';
import 'package:flutter/material.dart';

class CountdownBar extends StatefulWidget {
  final bool isOn;
  final Duration duration; // quanto dura il countdown totale
  final VoidCallback? onFinished; // callback quando arriva a zero
  final VoidCallback? onStart; // callback quando si inizia il countdown
  const CountdownBar({
    super.key,
    required this.isOn,
    this.duration = const Duration(seconds: 3),
    this.onStart,
    this.onFinished,
  });

  @override
  State<CountdownBar> createState() => _CountdownBarState();
}

class _CountdownBarState extends State<CountdownBar> {
  Timer? _timer;
  double _progress = 1.0;

  @override
  void initState() {
    super.initState();
    if (widget.isOn) {
      _startCountdown();
    }
  }

  @override
  void didUpdateWidget(covariant CountdownBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isOn != widget.isOn) {
      if (widget.isOn) {
        _startCountdown();
      } else {
        _stopCountdown();
      }
    }
  }

  void _startCountdown() {
    if (widget.onStart != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onStart!();
      });
    }
    _stopCountdown(); // reset eventuale timer già in corso
    setState(() => _progress = 1);

    final int tickMillis = 20; // ogni quanto aggiornare la barra
    final totalMillis = widget.duration.inMilliseconds;
    final decrement = tickMillis / totalMillis;

    _timer = Timer.periodic(Duration(milliseconds: tickMillis), (timer) {
      setState(() {
        _progress -= decrement;
        if (_progress <= 0) {
          _progress = 0;
          _stopCountdown();
          widget.onFinished?.call();
        }
      });
    });
  }

  void _stopCountdown() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopCountdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isOn,
      child: SizedBox(
        height: 7,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[300],
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
