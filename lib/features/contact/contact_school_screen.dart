import 'package:flutter/material.dart';

class ContactSchoolScreen extends StatelessWidget {
  const ContactSchoolScreen({super.key});

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
              "Contact School",
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
          // School Header
          //---------------------------------

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


            child:
                Column(

              children: [


                const CircleAvatar(

                  radius:
                      40,

                  backgroundColor:
                      Colors.white,

                  child:
                      Icon(

                    Icons.school,

                    size:
                        45,

                    color:
                        Colors.blue,

                  ),
                ),



                const SizedBox(height: 15),



                const Text(

                  "SmartKids Patashala",

                  style:
                      TextStyle(

                    color:
                        Colors.white,

                    fontSize:
                        24,

                    fontWeight:
                        FontWeight.bold,

                  ),
                ),



                const SizedBox(height: 6),



                const Text(

                  "Excellence in Education",

                  style:
                      TextStyle(

                    color:
                        Colors.white70,

                  ),
                ),


              ],
            ),
          ),





          const SizedBox(height: 25),





          //---------------------------------
          // School Address
          //---------------------------------


          sectionTitle(
            "School Information",
          ),



          infoCard(

            Icons.location_on,

            "Address",

            "MG Road, Vijayawada, Andhra Pradesh",

          ),



          infoCard(

            Icons.phone,

            "Phone",

            "+91 9876543210",

          ),



          infoCard(

            Icons.email,

            "Email",

            "info@smartkidspatashala.com",

          ),



          infoCard(

            Icons.language,

            "Website",

            "www.smartkidspatashala.com",

          ),




          const SizedBox(height: 25),




          //---------------------------------
          // Principal Details
          //---------------------------------


          sectionTitle(
            "Principal Details",
          ),



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

              contentPadding:
                  EdgeInsets.all(16),


              leading:
                  CircleAvatar(

                radius:
                    30,

                backgroundImage:
                    NetworkImage(

                  "https://i.pravatar.cc/300?img=47",

                ),
              ),



              title:
                  Text(

                "Dr. Anil Kumar",

                style:
                    TextStyle(

                  fontWeight:
                      FontWeight.bold,

                ),
              ),



              subtitle:
                  Text(

                "Principal\n15 Years Experience",

              ),

            ),
          ),




          const SizedBox(height: 25),





          //---------------------------------
          // Map Placeholder
          //---------------------------------


          sectionTitle(
            "Location",
          ),



          Container(

            height:
                180,


            decoration:
                BoxDecoration(

              color:
                  Colors.grey.shade300,

              borderRadius:
                  BorderRadius.circular(20),

            ),


            child:
                const Center(

              child:
                  Column(

                mainAxisAlignment:
                    MainAxisAlignment.center,


                children: [

                  Icon(

                    Icons.map,

                    size:
                        45,

                    color:
                        Colors.blue,

                  ),


                  SizedBox(height: 8),


                  Text(

                    "Google Map Location",

                  ),

                ],
              ),
            ),
          ),





          const SizedBox(height: 25),




          //---------------------------------
          // Actions
          //---------------------------------



          Row(

            children: [


              Expanded(

                child:
                    ElevatedButton.icon(

                  onPressed:
                      () {},


                  icon:
                      const Icon(
                        Icons.call,
                      ),


                  label:
                      const Text(
                        "Call",
                      ),

                ),
              ),



              const SizedBox(width: 12),




              Expanded(

                child:
                    OutlinedButton.icon(

                  onPressed:
                      () {},


                  icon:
                      const Icon(
                        Icons.email,
                      ),


                  label:
                      const Text(
                        "Email",
                      ),

                ),
              ),


            ],
          ),



          const SizedBox(height: 12),



          SizedBox(

            width:
                double.infinity,


            child:
                ElevatedButton.icon(

              onPressed:
                  () {},


              icon:
                  const Icon(
                    Icons.directions,
                  ),


              label:
                  const Text(
                    "Open Maps",
                  ),

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




  Widget infoCard(
      IconData icon,
      String title,
      String value,
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
              Colors.blue.shade50,


          child:
              Icon(

            icon,

            color:
                Colors.blue,

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