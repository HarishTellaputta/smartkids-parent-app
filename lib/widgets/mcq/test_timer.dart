
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

class _TestTimerState extends State<TestTimer>
    with SingleTickerProviderStateMixin {
  Timer? _timer;

  late int _remainingSeconds;

  bool _timeUpCalled = false;

  late AnimationController _pulseController;

  static const Color primary = Color(0xFF3155D9);
  static const Color primaryDark = Color(0xFF2343B8);
  static const Color textDark = Color(0xFF172033);
  static const Color textMuted = Color(0xFF697386);

  @override
  void initState() {
    super.initState();

    _remainingSeconds = widget.durationMinutes * 60;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.96,
      upperBound: 1.04,
    );

    if (widget.autoStart) {
      _startTimer();
    }
  }

  // ============================================================
  // START TIMER
  // ============================================================

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
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

        _updatePulseAnimation();
      },
    );
  }

  // ============================================================
  // PULSE ANIMATION
  // ============================================================

  void _updatePulseAnimation() {
    if (_isVeryLowTime) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.value = 1;
      }
    }
  }

  // ============================================================
  // TIME UP
  // ============================================================

  void _handleTimeUp() {
    if (_timeUpCalled) return;

    _timeUpCalled = true;

    if (_pulseController.isAnimating) {
      _pulseController.stop();
    }

    widget.onTimeUp();
  }

  // ============================================================
  // FORMATTED TIME
  // ============================================================

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // TIMER STATES
  // ============================================================

  bool get _isLowTime {
    return _remainingSeconds <= 60;
  }

  bool get _isVeryLowTime {
    return _remainingSeconds <= 10;
  }

  // ============================================================
  // TIMER COLOR
  // ============================================================

  Color get _timerColor {
    if (_isVeryLowTime) {
      return const Color(0xFFDC2626);
    }

    if (_isLowTime) {
      return const Color(0xFFF59E0B);
    }

    return primary;
  }

  // ============================================================
  // TIMER BACKGROUND
  // ============================================================

  Color get _timerBackground {
    if (_isVeryLowTime) {
      return const Color(0xFFFFEEF0);
    }

    if (_isLowTime) {
      return const Color(0xFFFFF7E8);
    }

    return const Color(0xFFF0F4FF);
  }

  // ============================================================
  // TIMER BORDER
  // ============================================================

  Color get _timerBorder {
    if (_isVeryLowTime) {
      return const Color(0xFFFECACA);
    }

    if (_isLowTime) {
      return const Color(0xFFFDE7B2);
    }

    return const Color(0xFFDCE5FF);
  }

  // ============================================================
  // TIMER LABEL
  // ============================================================

  String get _timerLabel {
    if (_isVeryLowTime) {
      return 'Hurry up!';
    }

    if (_isLowTime) {
      return 'Time running low';
    }

    return 'Time left';
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final color = _timerColor;

    return ScaleTransition(
      scale: _pulseController,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: _timerBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _timerBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(
                _isVeryLowTime ? 0.12 : 0.05,
              ),
              blurRadius: _isVeryLowTime ? 12 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==================================================
            // TIMER ICON
            // ==================================================

            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 31,
              width: 31,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isVeryLowTime
                    ? Icons.timer_off_rounded
                    : _isLowTime
                        ? Icons.timer_rounded
                        : Icons.timer_outlined,
                size: 17,
                color: color,
              ),
            ),

            const SizedBox(width: 8),

            // ==================================================
            // TIME DETAILS
            // ==================================================

            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                  child: Text(_timerLabel),
                ),

                const SizedBox(height: 3),

                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    height: 1,
                  ),
                  child: Text(_formattedTime),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

