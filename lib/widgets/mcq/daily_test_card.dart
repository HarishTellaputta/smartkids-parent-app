
import 'package:flutter/material.dart';
import 'package:parent_app/models/mcq_test.dart';

class DailyTestCard extends StatelessWidget {
  final McqTest test;
  final VoidCallback onStartTest;

  const DailyTestCard({
    super.key,
    required this.test,
    required this.onStartTest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // =====================================================
          // HEADER
          // =====================================================

          Container(
            width: double.infinity,

            padding: const EdgeInsets.all(18),

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff4169E1),
                  Color(0xff6387F5),
                ],
              ),

              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),

            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: const Icon(
                    Icons.quiz_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Text(
                        "DAILY MCQ TEST",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        test.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // =====================================================
          // TEST DETAILS
          // =====================================================

          Padding(
            padding: const EdgeInsets.all(18),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // Subject
                Row(
                  children: [
                    _infoChip(
                      icon: Icons.menu_book_rounded,
                      text: test.subject,
                    ),

                    const SizedBox(width: 8),

                    _infoChip(
                      icon: Icons.help_outline_rounded,
                      text:
                          "${test.totalQuestions} Questions",
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    _infoChip(
                      icon: Icons.timer_outlined,
                      text:
                          "${test.durationMinutes} Minutes",
                    ),

                    const SizedBox(width: 8),

                    _infoChip(
                      icon: Icons.access_time_rounded,
                      text: test.startTime,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Chapter
                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Icon(
                      Icons.topic_outlined,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Chapter",
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  Colors.grey.shade500,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            test.chapter,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 17,
                      color: Colors.grey.shade600,
                    ),

                    const SizedBox(width: 8),

                    Text(
                      "Test Date: ${test.testDate}",
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Divider
                Divider(
                  color: Colors.grey.shade200,
                ),

                const SizedBox(height: 14),

                // Start button
                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton.icon(
                    onPressed: onStartTest,

                    icon: const Icon(
                      Icons.play_arrow_rounded,
                    ),

                    label: const Text(
                      "Start Test",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xff4169E1),

                      foregroundColor:
                          Colors.white,

                      elevation: 0,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Information
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      "Test will auto-submit when time ends",
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO CHIP
  // ============================================================

  Widget _infoChip({
    required IconData icon,
    required String text,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 9,
        ),

        decoration: BoxDecoration(
          color: const Color(0xffF4F6FA),
          borderRadius: BorderRadius.circular(10),
        ),

        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: const Color(0xff4169E1),
            ),

            const SizedBox(width: 6),

            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,

                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

