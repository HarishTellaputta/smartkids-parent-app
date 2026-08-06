import 'package:flutter/material.dart';

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final certificates = [
      {
        "title": "Bonafide Certificate",
        "description": "Proof that student is currently studying in school.",
        "date": "Issued: 10 June 2026",
        "icon": Icons.school,
        "color": Colors.blue,
      },
      {
        "title": "Study Certificate",
        "description": "Certificate containing academic details.",
        "date": "Issued: 15 March 2026",
        "icon": Icons.menu_book,
        "color": Colors.green,
      },
      {
        "title": "Transfer Certificate",
        "description": "Certificate issued when leaving the school.",
        "date": "Available on Request",
        "icon": Icons.transfer_within_a_station,
        "color": Colors.orange,
      },
      {
        "title": "Fee Receipt",
        "description": "Download paid fee receipts.",
        "date": "Academic Year 2026-27",
        "icon": Icons.receipt_long,
        "color": Colors.purple,
      },
      {
        "title": "Hall Ticket",
        "description": "Exam hall ticket download.",
        "date": "Term 1 Examination",
        "icon": Icons.assignment,
        "color": Colors.red,
      },
    ];


    return Scaffold(

      backgroundColor:
          const Color(0xffF5F8FC),


      appBar: AppBar(

        backgroundColor: Colors.white,

        elevation: 0,

        centerTitle: true,

        title: const Text(
          "Certificates",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),


      body: ListView(

        padding:
            const EdgeInsets.all(16),


        children: [

          Container(

            padding:
                const EdgeInsets.all(20),


            decoration:
                BoxDecoration(

              gradient:
                  const LinearGradient(

                colors: [
                  Color(0xff6A1B9A),
                  Color(0xffAB47BC),
                ],

              ),


              borderRadius:
                  BorderRadius.circular(22),

            ),


            child: const Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,


              children: [

                Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: 45,
                ),


                SizedBox(height: 12),


                Text(
                  "Digital Certificates",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),


                SizedBox(height: 6),


                Text(
                  "Access and download your child's documents anytime.",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),

              ],
            ),
          ),


          const SizedBox(height: 25),


          const Text(

            "Available Documents",

            style: TextStyle(

              fontSize: 22,

              fontWeight: FontWeight.bold,

            ),
          ),


          const SizedBox(height: 15),



          ...certificates.map((certificate){


            return Card(

              elevation: 0,

              margin:
                  const EdgeInsets.only(
                    bottom: 15,
                  ),


              shape:
                  RoundedRectangleBorder(

                borderRadius:
                    BorderRadius.circular(18),

              ),


              child:
                  Padding(

                padding:
                    const EdgeInsets.all(18),


                child:
                    Column(

                  children: [


                    Row(

                      children: [


                        CircleAvatar(

                          radius: 28,

                          backgroundColor:
                              (certificate["color"]
                                      as Color)
                                  .withOpacity(.15),


                          child: Icon(

                            certificate["icon"]
                                as IconData,

                            color:
                                certificate["color"]
                                    as Color,

                          ),
                        ),


                        const SizedBox(width: 15),



                        Expanded(

                          child:
                              Column(

                            crossAxisAlignment:
                                CrossAxisAlignment.start,


                            children: [


                              Text(

                                certificate["title"]
                                    .toString(),

                                style:
                                    const TextStyle(

                                  fontSize: 18,

                                  fontWeight:
                                      FontWeight.bold,

                                ),
                              ),


                              const SizedBox(height: 6),


                              Text(

                                certificate["date"]
                                    .toString(),

                                style:
                                    TextStyle(

                                  color:
                                      Colors.grey.shade600,

                                ),
                              ),


                            ],
                          ),
                        ),

                      ],
                    ),


                    const SizedBox(height: 12),


                    Text(

                      certificate["description"]
                          .toString(),

                      style:
                          TextStyle(

                        color:
                            Colors.grey.shade700,

                      ),
                    ),


                    const SizedBox(height: 15),



                    Row(

                      children: [


                        Expanded(

                          child:
                              OutlinedButton.icon(

                            onPressed: () {},

                            icon:
                                const Icon(
                                  Icons.visibility,
                                ),

                            label:
                                const Text(
                                  "Preview",
                                ),

                          ),
                        ),



                        const SizedBox(width: 12),



                        Expanded(

                          child:
                              ElevatedButton.icon(

                            onPressed: () {},

                            icon:
                                const Icon(
                                  Icons.download,
                                ),

                            label:
                                const Text(
                                  "Download",
                                ),

                          ),
                        ),


                      ],
                    )

                  ],
                ),
              ),
            );
          }),

        ],
      ),
    );
  }
}