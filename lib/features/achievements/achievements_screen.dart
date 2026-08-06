import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final achievements = [

      {
        "title": "Mathematics Olympiad Winner",
        "category": "Academic",
        "date": "15 July 2026",
        "description":
            "Secured First Prize in District Level Mathematics Olympiad.",
        "icon": Icons.calculate,
        "color": Colors.blue,
      },


      {
        "title": "Science Exhibition Champion",
        "category": "Innovation",
        "date": "10 August 2026",
        "description":
            "Created an innovative smart farming project model.",
        "icon": Icons.science,
        "color": Colors.green,
      },


      {
        "title": "District Cricket Winner",
        "category": "Sports",
        "date": "20 September 2026",
        "description":
            "Team won District Level Under-14 Cricket Championship.",
        "icon": Icons.sports_cricket,
        "color": Colors.orange,
      },


      {
        "title": "Best Speaker Award",
        "category": "Communication",
        "date": "05 October 2026",
        "description":
            "Won first place in English Speech Competition.",
        "icon": Icons.mic,
        "color": Colors.purple,
      },

    ];



    return Scaffold(

      backgroundColor:
          const Color(0xffF5F8FC),



      appBar: AppBar(

        backgroundColor:
            Colors.white,

        elevation:
            0,

        centerTitle:
            true,

        title:
            const Text(
              "Achievements",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
      ),



      body: ListView(

        padding:
            const EdgeInsets.all(16),


        children: [



          //--------------------------------
          // Student Summary
          //--------------------------------


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


            child:
                Row(

              children: [


                const CircleAvatar(

                  radius:
                      35,

                  backgroundColor:
                      Colors.white,

                  child:
                      Icon(

                    Icons.emoji_events,

                    size:
                        40,

                    color:
                        Colors.purple,

                  ),
                ),



                const SizedBox(width: 15),



                Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,


                  children: [


                    const Text(

                      "Rahul Kumar",

                      style:
                          TextStyle(

                        color:
                            Colors.white,

                        fontSize:
                            22,

                        fontWeight:
                            FontWeight.bold,

                      ),
                    ),


                    const SizedBox(height: 6),


                    const Text(

                      "12 Achievements",

                      style:
                          TextStyle(

                        color:
                            Colors.white70,

                      ),
                    ),

                  ],
                )

              ],
            ),
          ),




          const SizedBox(height: 25),




          const Text(

            "Awards & Achievements",

            style:
                TextStyle(

              fontSize:
                  22,

              fontWeight:
                  FontWeight.bold,

            ),
          ),




          const SizedBox(height: 15),




          ...achievements.map((item){


            return Card(

              elevation:
                  0,

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

                  crossAxisAlignment:
                      CrossAxisAlignment.start,


                  children: [



                    Row(

                      children: [



                        CircleAvatar(

                          radius:
                              28,

                          backgroundColor:
                              (item["color"]
                                      as Color)
                                  .withOpacity(.15),


                          child:
                              Icon(

                            item["icon"]
                                as IconData,

                            color:
                                item["color"]
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

                                item["title"]
                                    .toString(),


                                style:
                                    const TextStyle(

                                  fontSize:
                                      17,

                                  fontWeight:
                                      FontWeight.bold,

                                ),
                              ),



                              const SizedBox(height: 5),



                              Container(

                                padding:
                                    const EdgeInsets.symmetric(

                                  horizontal:
                                      10,

                                  vertical:
                                      5,

                                ),


                                decoration:
                                    BoxDecoration(

                                  color:
                                      (item["color"]
                                              as Color)
                                          .withOpacity(.15),


                                  borderRadius:
                                      BorderRadius.circular(
                                        20,
                                      ),

                                ),


                                child:
                                    Text(

                                  item["category"]
                                      .toString(),


                                  style:
                                      TextStyle(

                                    color:
                                        item["color"]
                                            as Color,

                                    fontWeight:
                                        FontWeight.bold,

                                  ),
                                ),
                              )


                            ],
                          ),
                        )

                      ],
                    ),



                    const SizedBox(height: 15),



                    Text(

                      item["description"]
                          .toString(),


                      style:
                          TextStyle(

                        color:
                            Colors.grey.shade700,

                        height:
                            1.5,

                      ),
                    ),




                    const SizedBox(height: 12),




                    Row(

                      children: [


                        const Icon(

                          Icons.calendar_today,

                          size:
                              16,

                          color:
                              Colors.grey,

                        ),



                        const SizedBox(width: 6),



                        Text(

                          item["date"]
                              .toString(),

                          style:
                              TextStyle(

                            color:
                                Colors.grey.shade600,

                          ),
                        ),

                      ],
                    )

                  ],
                ),
              ),
            );

          })

        ],
      ),
    );
  }
}