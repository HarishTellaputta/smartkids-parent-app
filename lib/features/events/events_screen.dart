import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final events = [
      {
        "title": "Annual Day Celebration",
        "date": "25 September 2026",
        "time": "5:00 PM",
        "venue": "School Auditorium",
        "description":
            "Students will participate in cultural programs, dance, music and performances.",
        "image":
            "https://images.unsplash.com/photo-1503095396549-807759245b35",
      },
      {
        "title": "Science Exhibition",
        "date": "10 October 2026",
        "time": "10:00 AM",
        "venue": "Science Block",
        "description":
            "Students showcase innovative science projects and models.",
        "image":
            "https://images.unsplash.com/photo-1532094349884-543bc11b234d",
      },
      {
        "title": "Sports Day",
        "date": "15 November 2026",
        "time": "8:00 AM",
        "venue": "School Ground",
        "description":
            "Annual sports competition with various indoor and outdoor games.",
        "image":
            "https://images.unsplash.com/photo-1461896836934-ffe607ba8211",
      },
    ];


    return Scaffold(

      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(

        backgroundColor: Colors.white,

        elevation: 0,

        centerTitle: true,

        title: const Text(
          "School Events",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),


      body: ListView.builder(

        padding: const EdgeInsets.all(16),

        itemCount: events.length,

        itemBuilder: (context,index){

          final event = events[index];


          return Card(

            elevation: 0,

            margin:
                const EdgeInsets.only(
                  bottom: 20,
                ),

            shape:
                RoundedRectangleBorder(

              borderRadius:
                  BorderRadius.circular(22),

            ),


            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,


              children: [

                ClipRRect(

                  borderRadius:
                      const BorderRadius.only(

                    topLeft:
                        Radius.circular(22),

                    topRight:
                        Radius.circular(22),

                  ),


                  child: Image.network(

                    event["image"]
                        .toString(),

                    height: 180,

                    width: double.infinity,

                    fit: BoxFit.cover,

                  ),
                ),



                Padding(

                  padding:
                      const EdgeInsets.all(18),


                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,


                    children: [

                      Text(

                        event["title"]
                            .toString(),

                        style:
                            const TextStyle(

                          fontSize: 21,

                          fontWeight:
                              FontWeight.bold,

                        ),
                      ),


                      const SizedBox(height: 12),


                      Row(

                        children: [

                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Colors.grey,
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Text(
                            event["date"]
                                .toString(),
                          ),

                        ],
                      ),


                      const SizedBox(height: 8),


                      Row(

                        children: [

                          const Icon(
                            Icons.access_time,
                            size: 18,
                            color: Colors.grey,
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Text(
                            event["time"]
                                .toString(),
                          ),

                        ],
                      ),


                      const SizedBox(height: 8),


                      Row(

                        children: [

                          const Icon(
                            Icons.location_on,
                            size: 18,
                            color: Colors.grey,
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Text(
                            event["venue"]
                                .toString(),
                          ),

                        ],
                      ),


                      const SizedBox(height: 15),


                      Text(

                        event["description"]
                            .toString(),

                        style:
                            TextStyle(

                          color:
                              Colors.grey.shade700,

                          height: 1.5,

                        ),
                      ),


                      const SizedBox(height: 18),


                      Row(

                        children: [

                          Expanded(

                            child:
                                OutlinedButton.icon(

                              onPressed: () {},

                              icon:
                                  const Icon(
                                    Icons.photo,
                                  ),

                              label:
                                  const Text(
                                    "Gallery",
                                  ),

                            ),
                          ),


                          const SizedBox(
                            width: 12,
                          ),


                          Expanded(

                            child:
                                ElevatedButton.icon(

                              onPressed: () {},

                              icon:
                                  const Icon(
                                    Icons.info,
                                  ),

                              label:
                                  const Text(
                                    "Details",
                                  ),

                            ),
                          ),

                        ],
                      )

                    ],
                  ),
                )

              ],
            ),
          );
        },
      ),
    );
  }
}