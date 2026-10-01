
import 'package:flutter/material.dart';

class QuestionOption extends StatelessWidget {
  final String option;
  final int optionIndex;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const QuestionOption({
    super.key,
    required this.option,
    required this.optionIndex,
    required this.isSelected,
    required this.onTap,
    this.isDisabled = false,
  });

  static const Color primary = Color(0xFF3155D9);
  static const Color primaryDark = Color(0xFF2343B8);
  static const Color textDark = Color(0xFF172033);
  static const Color textMuted = Color(0xFF697386);
  static const Color border = Color(0xFFE5E9F0);

  static const List<String> letters = [
    'A',
    'B',
    'C',
    'D',
  ];

  @override
  Widget build(BuildContext context) {
    final String letter = optionIndex < letters.length
        ? letters[optionIndex]
        : String.fromCharCode(65 + optionIndex);

    final Color activeColor =
        isDisabled ? const Color(0xFF9AA3B2) : primary;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDisabled
              ? const Color(0xFFF5F6F8)
              : isSelected
                  ? const Color(0xFFF0F4FF)
                  : Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: isDisabled
                ? const Color(0xFFE3E6EB)
                : isSelected
                    ? primary
                    : border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.025),
                    blurRadius: 9,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ==================================================
            // OPTION LETTER
            // ==================================================

            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              height: 44,
              width: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [
                          primaryDark,
                          primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected
                    ? null
                    : isDisabled
                        ? const Color(0xFFE9EBEF)
                        : const Color(0xFFF3F5F9),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : isDisabled
                          ? const Color(0xFFDDE1E7)
                          : const Color(0xFFE8EBF0),
                ),
              ),
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isSelected
                      ? Colors.white
                      : isDisabled
                          ? const Color(0xFF8F97A5)
                          : textDark,
                ),
              ),
            ),

            const SizedBox(width: 13),

            // ==================================================
            // OPTION TEXT
            // ==================================================

            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  color: isDisabled
                      ? const Color(0xFF9AA3B2)
                      : textDark,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
                child: Text(
                  option,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            const SizedBox(width: 10),

            // ==================================================
            // SELECTION INDICATOR
            // ==================================================

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (
                Widget child,
                Animation<double> animation,
              ) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: isSelected
                  ? Container(
                      key: const ValueKey('selected'),
                      height: 27,
                      width: 27,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.20),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 17,
                      ),
                    )
                  : Container(
                      key: const ValueKey('unselected'),
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDisabled
                              ? const Color(0xFFC9CED7)
                              : const Color(0xFFB9C0CC),
                          width: 1.5,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

