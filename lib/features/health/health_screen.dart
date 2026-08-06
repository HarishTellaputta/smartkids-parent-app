import 'package:flutter/material.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

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
          "Health Record",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),


      body: ListView(

        padding:
            const EdgeInsets.all(16),


        children: [


          //---------------------------------
          // Student Health Header
          //---------------------------------

          Container(

            padding:
                const EdgeInsets.all(20),


            decoration:
                BoxDecoration(

              gradient:
                  const LinearGradient(

                colors: [

                  Color(0xff00897B),

                  Color(0xff26A69A),

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

                    Icons.health_and_safety,

                    size:
                        40,

                    color:
                        Colors.teal,

                  ),
                ),


                const SizedBox(width: 15),


                const Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,


                  children: [

                    Text(

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


                    SizedBox(height: 6),


                    Text(

                      "Class 6 - A",

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



          //---------------------------------
          // Basic Health Info
          //---------------------------------


          const Text(

            "Basic Information",

            style:
                TextStyle(

              fontSize:
                  22,

              fontWeight:
                  FontWeight.bold,

            ),

          ),


          const SizedBox(height: 15),



          Row(

            children: [

              Expanded(

                child:
                    healthCard(

                  Icons.bloodtype,

                  "Blood Group",

                  "B+",

                  Colors.red,

                ),
              ),


              const SizedBox(width: 12),


              Expanded(

                child:
                    healthCard(

                  Icons.height,

                  "Height",

                  "145 cm",

                  Colors.blue,

                ),
              ),

            ],
          ),



          const SizedBox(height: 12),



          Row(

            children: [

              Expanded(

                child:
                    healthCard(

                  Icons.monitor_weight,

                  "Weight",

                  "38 Kg",

                  Colors.orange,

                ),
              ),


              const SizedBox(width: 12),


              Expanded(

                child:
                    healthCard(

                  Icons.favorite,

                  "BMI",

                  "18.2",

                  Colors.green,

                ),
              ),

            ],
          ),




          const SizedBox(height: 25),



          //---------------------------------
          // Medical Details
          //---------------------------------


          healthDetailCard(

            "Allergies",

            "No known allergies",

            Icons.warning_amber,

            Colors.orange,

          ),



          healthDetailCard(

            "Medical Conditions",

            "No major medical history",

            Icons.medical_information,

            Colors.blue,

          ),



          healthDetailCard(

            "Vaccination",

            "All vaccinations completed",

            Icons.vaccines,

            Colors.green,

          ),



          healthDetailCard(

            "Last Health Checkup",

            "12 June 2026",

            Icons.calendar_month,

            Colors.purple,

          ),




          const SizedBox(height: 25),




          //---------------------------------
          // Emergency Contact
          //---------------------------------


          const Text(

            "Emergency Contact",

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
                const ListTile(

              leading:
                  CircleAvatar(

                child:
                    Icon(

                  Icons.phone,

                ),

              ),


              title:
                  Text(

                "Father - Suresh Kumar",

              ),


              subtitle:
                  Text(

                "+91 9876543210",

              ),

            ),
          )

        ],
      ),
    );
  }



  Widget healthCard(
      IconData icon,
      String title,
      String value,
      Color color,
      ){

    return Container(

      padding:
          const EdgeInsets.all(16),


      decoration:
          BoxDecoration(

        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(18),

      ),


      child:
          Column(

        children: [

          Icon(

            icon,

            color:
                color,

            size:
                30,

          ),


          const SizedBox(height: 10),


          Text(

            value,

            style:
                const TextStyle(

              fontSize:
                  20,

              fontWeight:
                  FontWeight.bold,

            ),
          ),


          const SizedBox(height: 5),


          Text(

            title,

          ),

        ],
      ),
    );
  }



  Widget healthDetailCard(
      String title,
      String value,
      IconData icon,
      Color color,
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
            BorderRadius.circular(18),

      ),


      child:
          ListTile(

        leading:
            CircleAvatar(

          backgroundColor:
              color.withOpacity(.15),


          child:
              Icon(

            icon,

            color:
                color,

          ),
        ),


        title:
            Text(

          title,

          style:
              const TextStyle(

            fontWeight:
                FontWeight.bold,

          ),
        ),


        subtitle:
            Text(value),

      ),
    );
  }
}