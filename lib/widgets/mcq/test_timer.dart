import 'dart:async';
import 'package:flutter/material.dart';

class TestTimer extends StatefulWidget {
  final int durationMinutes;
  final VoidCallback onTimeUp;
  final bool autoStart;

  const TestTimer({
    super.key,
    required this.durationMinutes,
    required this.onTimeUp,
    this.autoStart = true,
  });

  @override
  State<TestTimer> createState() => _TestTimerState();
}

class _TestTimerState extends State<TestTimer> {
  Timer? _timer;

  late int _remainingSeconds;

  bool _timeUpCalled = false;

  @override
  void initState() {
    super.initState();

    _remainingSeconds = widget.durationMinutes * 60;

    if (widget.autoStart) {
      _startTimer();
    }
  }

  // ============================================================
  // START TIMER
  // ============================================================

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_remainingSeconds <= 1) {
        timer.cancel();

        setState(() {
          _remainingSeconds = 0;
        });

        _handleTimeUp();

        return;
      }

      setState(() {
        _remainingSeconds--;
      });
    });
  }

  // ============================================================
  // TIME UP
  // ============================================================

  void _handleTimeUp() {
    if (_timeUpCalled) return;

    _timeUpCalled = true;

    widget.onTimeUp();
  }

  // ============================================================
  // FORMATTED TIME
  // ============================================================

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;

    final seconds = _remainingSeconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }

  // ============================================================
  // LOW TIME
  // ============================================================

  bool get _isLowTime {
    return _remainingSeconds <= 60;
  }

  bool get _isVeryLowTime {
    return _remainingSeconds <= 10;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

      decoration: BoxDecoration(
        color: _isLowTime ? const Color(0xffffe4e6) : const Color(0xffE8F0FF),

        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: _isLowTime ? Colors.red.shade200 : const Color(0xffD5E0FF),
        ),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          // ====================================================
          // TIMER ICON
          // ====================================================
          Icon(
            _isLowTime ? Icons.timer_off_outlined : Icons.timer_outlined,

            size: 19,

            color: _isLowTime ? Colors.red : const Color(0xff4169E1),
          ),

          const SizedBox(width: 6),

          // ====================================================
          // TIME
          // ====================================================
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),

            style: TextStyle(
              fontSize: 14,

              fontWeight: FontWeight.bold,

              color: _isLowTime ? Colors.red : const Color(0xff4169E1),
            ),

            child: Text(_formattedTime),
          ),
        ],
      ),
    );
  }
}
