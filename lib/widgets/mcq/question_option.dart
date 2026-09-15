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

  static const List<String> letters = ["A", "B", "C", "D"];

  @override
  Widget build(BuildContext context) {
    final String letter = optionIndex < letters.length
        ? letters[optionIndex]
        : String.fromCharCode(65 + optionIndex);

    return GestureDetector(
      onTap: isDisabled ? null : onTap,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),

        width: double.infinity,

        margin: const EdgeInsets.only(bottom: 12),

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffE8F0FF) : Colors.white,

          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: isSelected ? const Color(0xff4169E1) : Colors.grey.shade300,

            width: isSelected ? 2 : 1,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),

              blurRadius: 6,

              offset: const Offset(0, 2),
            ),
          ],
        ),

        child: Row(
          children: [
            // ==================================================
            // OPTION LETTER
            // ==================================================
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),

              height: 42,
              width: 42,

              alignment: Alignment.center,

              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xff4169E1)
                    : const Color(0xffF1F3F7),

                borderRadius: BorderRadius.circular(12),
              ),

              child: Text(
                letter,

                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,

                  color: isSelected ? Colors.white : const Color(0xff172033),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ==================================================
            // OPTION TEXT
            // ==================================================
            Expanded(
              child: Text(
                option,

                style: TextStyle(
                  fontSize: 15,
                  height: 1.35,

                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,

                  color: isDisabled ? Colors.grey : const Color(0xff172033),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // ==================================================
            // RADIO ICON
            // ==================================================
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),

              child: Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,

                key: ValueKey(isSelected),

                size: 24,

                color: isSelected
                    ? const Color(0xff4169E1)
                    : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
