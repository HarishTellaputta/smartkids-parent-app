import 'package:flutter/material.dart';

class AboutSchoolScreen extends StatelessWidget {
  const AboutSchoolScreen({super.key});

  @override
  Widget build(BuildContext context) {

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
              "About School",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
      ),


      body: ListView(

        children: [


          //--------------------------------
          // Banner
          //--------------------------------

          Stack(

            children: [

              Image.network(

                "https://images.unsplash.com/photo-1509062522246-3755977927d7",

                height:
                    220,

                width:
                    double.infinity,

                fit:
                    BoxFit.cover,

              ),


              Container(

                height:
                    220,

                decoration:
                    BoxDecoration(

                  gradient:
                      LinearGradient(

                    colors: [

                      Colors.black.withOpacity(.5),

                      Colors.transparent,

                    ],

                  ),

                ),
              ),



              const Positioned(

                left:
                    20,

                bottom:
                    25,

                child:
                    Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(

                      "SmartKids Patashala",

                      style:
                          TextStyle(

                        color:
                            Colors.white,

                        fontSize:
                            28,

                        fontWeight:
                            FontWeight.bold,

                      ),
                    ),


                    SizedBox(height: 6),


                    Text(

                      "Building Future Generations",

                      style:
                          TextStyle(

                        color:
                            Colors.white70,

                        fontSize:
                            16,

                      ),
                    ),

                  ],
                ),
              )

            ],
          ),




          Padding(

            padding:
                const EdgeInsets.all(16),


            child:
                Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,


              children: [



                //--------------------------------
                // About
                //--------------------------------


                sectionTitle(
                  "About SmartKids Patashala",
                ),



                infoText(

                  "SmartKids Patashala is committed to providing quality education with modern teaching methods, experienced faculty, and a safe learning environment for students.",

                ),





                //--------------------------------
                // Vision
                //--------------------------------


                sectionTitle(
                  "Our Vision",
                ),



                featureCard(

                  Icons.visibility,

                  "Vision",

                  "To create confident, creative and responsible students ready for the future.",

                  Colors.blue,

                ),




                //--------------------------------
                // Mission
                //--------------------------------


                featureCard(

                  Icons.flag,

                  "Mission",

                  "Provide excellent education with technology, values and practical learning.",

                  Colors.green,

                ),





                //--------------------------------
                // Facilities
                //--------------------------------


                sectionTitle(
                  "Facilities",
                ),



                Wrap(

                  spacing:
                      10,

                  runSpacing:
                      10,


                  children: [


                    facilityChip(
                      "Smart Classrooms",
                    ),


                    facilityChip(
                      "Library",
                    ),


                    facilityChip(
                      "Science Lab",
                    ),


                    facilityChip(
                      "Computer Lab",
                    ),


                    facilityChip(
                      "Sports Ground",
                    ),


                    facilityChip(
                      "Transport",
                    ),

                  ],
                ),




                //--------------------------------
                // Achievements
                //--------------------------------


                sectionTitle(
                  "Achievements",
                ),



                achievementCard(
                  "100% Board Exam Results",
                  "2025 Academic Year",
                ),



                achievementCard(
                  "District Level Sports Winners",
                  "Multiple Awards",
                ),



                achievementCard(
                  "Best School Award",
                  "Education Excellence Award",
                ),




                //--------------------------------
                // Admission
                //--------------------------------


                const SizedBox(height: 20),



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
                        BorderRadius.circular(20),

                  ),


                  child:
                      Column(

                    children: [


                      const Text(

                        "Admissions Open 2026-27",

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


                      const SizedBox(height: 10),


                      ElevatedButton(

                        onPressed:
                            () {},


                        child:
                            const Text(
                              "Enquire Now",
                            ),
                      )

                    ],
                  ),
                )

              ],
            ),
          )

        ],
      ),
    );
  }




  Widget sectionTitle(String title){

    return Padding(

      padding:
          const EdgeInsets.only(
            top: 20,
            bottom: 12,
          ),


      child:
          Text(

        title,

        style:
            const TextStyle(

          fontSize:
              22,

          fontWeight:
              FontWeight.bold,

        ),
      ),
    );
  }





  Widget infoText(String text){

    return Text(

      text,

      style:
          TextStyle(

        color:
            Colors.grey.shade700,

        height:
            1.6,

        fontSize:
            15,

      ),
    );
  }





  Widget featureCard(
      IconData icon,
      String title,
      String text,
      Color color,
      ){

    return Card(

      elevation:
          0,

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
            Text(text),

      ),
    );
  }





  Widget facilityChip(String title){

    return Chip(

      label:
          Text(title),


      avatar:
          const Icon(
            Icons.check_circle,
            size: 18,
          ),

    );
  }





  Widget achievementCard(
      String title,
      String subtitle,
      ){

    return Card(

      elevation:
          0,

      margin:
          const EdgeInsets.only(
            bottom: 12,
          ),


      child:
          ListTile(

        leading:
            const CircleAvatar(

          child:
              Icon(
                Icons.emoji_events,
              ),

        ),


        title:
            Text(title),


        subtitle:
            Text(subtitle),

      ),
    );
  }

}