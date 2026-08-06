import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final events = [
      {
        "title": "Independence Day",
        "date": "15 August 2026",
        "type": "Holiday",
        "color": Colors.red,
        "icon": Icons.flag,
      },
      {
        "title": "Parent Teacher Meeting",
        "date": "20 August 2026",
        "type": "Meeting",
        "color": Colors.blue,
        "icon": Icons.people,
      },
      {
        "title": "First Term Examination",
        "date": "05 September 2026",
        "type": "Exam",
        "color": Colors.orange,
        "icon": Icons.edit_note,
      },
      {
        "title": "Annual Sports Day",
        "date": "25 September 2026",
        "type": "Event",
        "color": Colors.green,
        "icon": Icons.sports,
      },
      {
        "title": "Teachers Day",
        "date": "05 September 2026",
        "type": "Celebration",
        "color": Colors.purple,
        "icon": Icons.celebration,
      },
    ];


    return Scaffold(

      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Academic Calendar",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),


      body: ListView(

        padding: const EdgeInsets.all(16),

        children: [

          //--------------------------------
          // Month Card
          //--------------------------------

          Container(

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(

              gradient: const LinearGradient(
                colors: [
                  Color(0xff1565C0),
                  Color(0xff42A5F5),
                ],
              ),

              borderRadius:
                  BorderRadius.circular(22),

            ),


            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Text(
                  "August 2026",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),


                const SizedBox(height: 10),


                const Text(
                  "Academic Year 2026 - 2027",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),


                const SizedBox(height: 20),


                Row(

                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround,

                  children: [

                    calendarSummary(
                      "12",
                      "Working Days",
                    ),

                    calendarSummary(
                      "3",
                      "Holidays",
                    ),

                    calendarSummary(
                      "2",
                      "Events",
                    ),

                  ],
                )
              ],
            ),
          ),


          const SizedBox(height: 25),


          const Text(
            "Upcoming Events",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),


          const SizedBox(height: 15),


          ...events.map((event){

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


              child: Padding(

                padding:
                    const EdgeInsets.all(18),


                child: Row(

                  children: [

                    CircleAvatar(

                      radius: 28,

                      backgroundColor:
                          (event["color"]
                                  as Color)
                              .withOpacity(.15),


                      child: Icon(

                        event["icon"]
                            as IconData,

                        color:
                            event["color"]
                                as Color,

                      ),
                    ),


                    const SizedBox(width: 15),


                    Expanded(

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,


                        children: [

                          Text(

                            event["title"]
                                .toString(),

                            style:
                                const TextStyle(

                              fontSize: 17,

                              fontWeight:
                                  FontWeight.bold,

                            ),
                          ),


                          const SizedBox(height: 8),


                          Row(

                            children: [

                              const Icon(

                                Icons.calendar_today,

                                size: 16,

                                color:
                                    Colors.grey,

                              ),


                              const SizedBox(
                                width: 6,
                              ),


                              Text(
                                event["date"]
                                    .toString(),
                              ),

                            ],
                          ),


                          const SizedBox(height: 8),


                          Container(

                            padding:
                                const EdgeInsets
                                    .symmetric(

                              horizontal: 12,

                              vertical: 5,

                            ),


                            decoration:
                                BoxDecoration(

                              color:
                                  (event["color"]
                                          as Color)
                                      .withOpacity(.15),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                        20,
                                      ),

                            ),


                            child: Text(

                              event["type"]
                                  .toString(),


                              style:
                                  TextStyle(

                                color:
                                    event["color"]
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
              ),
            );

          }),

        ],
      ),
    );
  }



  Widget calendarSummary(
      String value,
      String title,
      ){

    return Column(

      children: [

        Text(

          value,

          style: const TextStyle(

            color: Colors.white,

            fontSize: 24,

            fontWeight:
                FontWeight.bold,

          ),
        ),


        const SizedBox(height: 5),


        Text(

          title,

          style:
              const TextStyle(

            color:
                Colors.white70,

            fontSize: 12,

          ),
        ),

      ],
    );
  }
}