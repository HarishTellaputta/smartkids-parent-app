import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
          "Parent Profile",
          style: TextStyle(
            color: Colors.black,
          ),
        ),

        actions: [

          IconButton(

            onPressed: () {},

            icon:
                const Icon(
                  Icons.edit,
                  color: Colors.blue,
                ),

          )

        ],
      ),



      body: ListView(

        padding:
            const EdgeInsets.all(16),


        children: [



          //--------------------------------
          // Profile Header
          //--------------------------------


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
                      45,

                  backgroundImage:
                      NetworkImage(

                    "https://i.pravatar.cc/150?img=12",

                  ),

                ),


                const SizedBox(height: 15),


                const Text(

                  "Suresh Kumar",

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

                  "Father of Rahul Kumar",

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




          //--------------------------------
          // Personal Information
          //--------------------------------


          const Text(

            "Personal Information",

            style:
                TextStyle(

              fontSize:
                  22,

              fontWeight:
                  FontWeight.bold,

            ),
          ),



          const SizedBox(height: 15),



          profileCard(
            Icons.phone,
            "Mobile Number",
            "+91 9876543210",
          ),



          profileCard(
            Icons.email,
            "Email",
            "suresh@gmail.com",
          ),



          profileCard(
            Icons.location_on,
            "Address",
            "Vijay Nagar, Andhra Pradesh",
          ),



          profileCard(
            Icons.work,
            "Occupation",
            "Business Owner",
          ),




          const SizedBox(height: 25),




          //--------------------------------
          // Linked Children
          //--------------------------------


          const Text(

            "Linked Children",

            style:
                TextStyle(

              fontSize:
                  22,

              fontWeight:
                  FontWeight.bold,

            ),
          ),



          const SizedBox(height: 15),



          childCard(
            "Rahul Kumar",
            "Class 6 - A",
            "Roll No: 23",
          ),



          childCard(
            "Priya Kumar",
            "Class 3 - B",
            "Roll No: 14",
          ),





          const SizedBox(height: 25),




          //--------------------------------
          // Actions
          //--------------------------------



          actionButton(
            Icons.lock,
            "Change Password",
          ),



          actionButton(
            Icons.logout,
            "Logout",
          ),


        ],
      ),
    );
  }





  Widget profileCard(
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





  Widget childCard(
      String name,
      String className,
      String roll,
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
            const CircleAvatar(

          child:
              Icon(
                Icons.person,
              ),

        ),


        title:
            Text(

          name,

          style:
              const TextStyle(

            fontWeight:
                FontWeight.bold,

          ),
        ),


        subtitle:
            Text(
              "$className | $roll",
            ),


        trailing:
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),

      ),
    );
  }





  Widget actionButton(
      IconData icon,
      String title,
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
            Icon(
              icon,
              color: Colors.blue,
            ),


        title:
            Text(title),


        trailing:
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),

        onTap: () {},

      ),
    );
  }

}