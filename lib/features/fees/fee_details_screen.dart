import 'package:flutter/material.dart';

class FeeDetailsScreen extends StatelessWidget {
  const FeeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feeHistory = [
      {
        "title": "Term 1 Fee",
        "amount": "₹15,000",
        "date": "10 Jun 2026",
        "status": "Paid",
        "color": Colors.green,
      },
      {
        "title": "Transport Fee",
        "amount": "₹3,000",
        "date": "10 Jul 2026",
        "status": "Paid",
        "color": Colors.green,
      },
      {
        "title": "Term 2 Fee",
        "amount": "₹15,000",
        "date": "15 Aug 2026",
        "status": "Pending",
        "color": Colors.orange,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Fee Details",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          //-------------------------------------------------
          // Outstanding Card
          //-------------------------------------------------

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xffEF6C00),
                  Color(0xffFFA726),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [

                Icon(
                  Icons.account_balance_wallet,
                  size: 55,
                  color: Colors.white,
                ),

                SizedBox(height: 15),

                Text(
                  "Outstanding Amount",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  "₹15,000",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  "Due Date : 15 Aug 2026",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [

              Expanded(
                child: summaryCard(
                  "Paid",
                  "₹18,000",
                  Colors.green,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: summaryCard(
                  "Pending",
                  "₹15,000",
                  Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          const Text(
            "Fee History",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          ...feeHistory.map((fee) {
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [

                    Row(
                      children: [

                        CircleAvatar(
                          backgroundColor:
                              (fee["color"] as Color).withOpacity(.15),
                          child: Icon(
                            Icons.receipt_long,
                            color: fee["color"] as Color,
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              Text(
                                fee["title"].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(fee["date"].toString()),
                            ],
                          ),
                        ),

                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [

                            Text(
                              fee["amount"].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (fee["color"] as Color)
                                        .withOpacity(.15),
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: Text(
                                fee["status"].toString(),
                                style: TextStyle(
                                  color: fee["color"] as Color,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [

                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.receipt),
                            label:
                                const Text("Receipt"),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.download),
                            label:
                                const Text("Download"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          SizedBox(
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.payment),
              label: const Text(
                "Pay Fee (Coming Soon)",
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget summaryCard(
      String title,
      String amount,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [

          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),

          const SizedBox(height: 8),

          Text(title),
        ],
      ),
    );
  }
}