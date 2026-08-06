import 'package:flutter/material.dart';

class TransportScreen extends StatelessWidget {
  const TransportScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xffF5F8FC),


      appBar: AppBar(

        backgroundColor: Colors.white,

        elevation: 0,

        centerTitle: true,

        title: const Text(
          "School Transport",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),


      body: ListView(

        padding:
            const EdgeInsets.all(16),


        children: [


          //----------------------------------
          // Bus Details Card
          //----------------------------------

          Container(

            padding:
                const EdgeInsets.all(20),


            decoration:
                BoxDecoration(

              gradient:
                  const LinearGradient(

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

                Row(

                  children: [

                    const CircleAvatar(

                      radius: 30,

                      backgroundColor:
                          Colors.white,

                      child: Icon(

                        Icons.directions_bus,

                        size: 35,

                        color:
                            Colors.blue,

                      ),
                    ),


                    const SizedBox(width: 15),


                    Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        const Text(

                          "School Bus - 12",

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


                        const SizedBox(height: 5),


                        Text(

                          "AP 16 AB 4567",

                          style:
                              const TextStyle(

                            color:
                                Colors.white70,

                          ),
                        ),

                      ],
                    )

                  ],
                ),


                const SizedBox(height: 25),


                transportInfo(
                  Icons.route,
                  "Route",
                  "Vijay Nagar - School Campus",
                ),


                const SizedBox(height: 15),


                transportInfo(
                  Icons.access_time,
                  "Pickup Time",
                  "7:30 AM",
                ),


                const SizedBox(height: 15),


                transportInfo(
                  Icons.access_time,
                  "Drop Time",
                  "4:15 PM",
                ),

              ],
            ),
          ),



          const SizedBox(height: 25),



          //----------------------------------
          // Driver Details
          //----------------------------------


          const Text(

            "Driver Details",

            style:
                TextStyle(

              fontSize:
                  22,

              fontWeight:
                  FontWeight.bold,

            ),

          ),



          const SizedBox(height: 15),



          Card(

            elevation:
                0,

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
                  Row(

                children: [


                  const CircleAvatar(

                    radius:
                        35,

                    backgroundImage:
                        NetworkImage(

                      "https://i.pravatar.cc/300?img=12",

                    ),
                  ),



                  const SizedBox(width: 15),



                  const Expanded(

                    child:
                        Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(

                          "Ramesh Kumar",

                          style:
                              TextStyle(

                            fontSize:
                                18,

                            fontWeight:
                                FontWeight.bold,

                          ),
                        ),


                        SizedBox(height: 8),


                        Text(
                          "Driver",
                        ),


                        SizedBox(height: 5),


                        Text(
                          "Experience: 8 Years",
                        ),

                      ],
                    ),
                  ),



                  IconButton(

                    onPressed: () {},

                    icon:
                        const Icon(

                      Icons.call,

                      color:
                          Colors.green,

                    ),
                  )

                ],
              ),
            ),
          ),




          const SizedBox(height: 25),




          //----------------------------------
          // Pickup Points
          //----------------------------------


          const Text(

            "Pickup & Drop Points",

            style:
                TextStyle(

              fontSize:
                  22,

              fontWeight:
                  FontWeight.bold,

            ),
          ),



          const SizedBox(height: 15),



          pickupTile(
            "Morning Pickup",
            "Sai Nagar Junction",
            "7:20 AM",
          ),


          pickupTile(
            "Morning Pickup",
            "Vijay Nagar Colony",
            "7:30 AM",
          ),


          pickupTile(
            "Evening Drop",
            "Vijay Nagar Colony",
            "4:20 PM",
          ),




          const SizedBox(height: 25),




          //----------------------------------
          // Live Tracking
          //----------------------------------


          Container(

            padding:
                const EdgeInsets.all(20),


            decoration:
                BoxDecoration(

              color:
                  Colors.white,

              borderRadius:
                  BorderRadius.circular(20),

            ),


            child:
                Column(

              children: [

                const Icon(

                  Icons.location_on,

                  size:
                      45,

                  color:
                      Colors.blue,

                ),


                const SizedBox(height: 10),


                const Text(

                  "Live Bus Tracking",

                  style:
                      TextStyle(

                    fontSize:
                        20,

                    fontWeight:
                        FontWeight.bold,

                  ),
                ),


                const SizedBox(height: 8),


                Text(

                  "GPS tracking feature coming soon",

                  style:
                      TextStyle(

                    color:
                        Colors.grey.shade600,

                  ),
                ),



                const SizedBox(height: 15),



                ElevatedButton(

                  onPressed: () {},

                  child:
                      const Text(

                    "Track Bus",

                  ),
                )

              ],
            ),
          )

        ],
      ),
    );
  }



  Widget transportInfo(
      IconData icon,
      String title,
      String value,
      ){

    return Row(

      children: [

        Icon(

          icon,

          color:
              Colors.white,

        ),


        const SizedBox(width: 12),


        Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(

              title,

              style:
                  const TextStyle(

                color:
                    Colors.white70,

              ),
            ),


            Text(

              value,

              style:
                  const TextStyle(

                color:
                    Colors.white,

                fontWeight:
                    FontWeight.bold,

              ),
            ),

          ],
        )

      ],
    );
  }



  Widget pickupTile(
      String title,
      String location,
      String time,
      ){

    return Card(

      elevation:
          0,

      margin:
          const EdgeInsets.only(
            bottom: 12,
          ),

      shape:
          RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(16),

      ),


      child:
          ListTile(

        leading:
            const CircleAvatar(

          child:
              Icon(
                Icons.location_on,
              ),

        ),


        title:
            Text(title),


        subtitle:
            Text(location),


        trailing:
            Text(time),

      ),
    );
  }
}