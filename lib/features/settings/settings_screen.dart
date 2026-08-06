import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              "Settings",
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
          // Account Section
          //--------------------------------


          sectionTitle(
            "Account",
          ),


          settingsTile(
            Icons.person,
            "Edit Profile",
            "Update your personal information",
          ),


          settingsTile(
            Icons.lock,
            "Change Password",
            "Update your login password",
          ),




          //--------------------------------
          // App Settings
          //--------------------------------


          sectionTitle(
            "App Settings",
          ),



          settingsTile(
            Icons.language,
            "Language",
            "English",
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
                SwitchListTile(

              value:
                  false,

              onChanged:
                  (value){},


              secondary:
                  const Icon(
                    Icons.dark_mode,
                    color: Colors.blue,
                  ),


              title:
                  const Text(
                    "Dark Mode",
                  ),


              subtitle:
                  const Text(
                    "Change app appearance",
                  ),

            ),
          ),





          //--------------------------------
          // Notification Settings
          //--------------------------------


          sectionTitle(
            "Notifications",
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
                Column(

              children: [


                notificationTile(
                  "Homework Alerts",
                ),


                notificationTile(
                  "Fee Reminders",
                ),


                notificationTile(
                  "Exam Notifications",
                ),


                notificationTile(
                  "School Notices",
                ),


              ],
            ),
          ),




          //--------------------------------
          // Support
          //--------------------------------


          sectionTitle(
            "Support",
          ),



          settingsTile(
            Icons.help,
            "Help & Support",
            "Contact school support team",
          ),



          settingsTile(
            Icons.privacy_tip,
            "Privacy Policy",
            "Read privacy information",
          ),



          settingsTile(
            Icons.description,
            "Terms & Conditions",
            "App usage rules",
          ),



          settingsTile(
            Icons.info,
            "About App",
            "SmartKids Patashala v1.0",
          ),





          const SizedBox(height: 20),




          //--------------------------------
          // Logout
          //--------------------------------


          ElevatedButton.icon(

            style:
                ElevatedButton.styleFrom(

              backgroundColor:
                  Colors.red,

              padding:
                  const EdgeInsets.symmetric(
                    vertical: 15,
                  ),

              shape:
                  RoundedRectangleBorder(

                borderRadius:
                    BorderRadius.circular(15),

              ),
            ),


            onPressed:
                () {},


            icon:
                const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),


            label:
                const Text(

                  "Logout",

                  style:
                      TextStyle(

                    color:
                        Colors.white,

                    fontSize:
                        16,

                  ),
                ),
          ),

        ],
      ),
    );
  }





  Widget sectionTitle(String title){

    return Padding(

      padding:
          const EdgeInsets.only(
            top: 18,
            bottom: 10,
          ),

      child:
          Text(

        title,

        style:
            const TextStyle(

          fontSize:
              20,

          fontWeight:
              FontWeight.bold,

        ),
      ),
    );
  }





  Widget settingsTile(
      IconData icon,
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
            Text(subtitle),


        trailing:
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),

        onTap: () {},

      ),
    );
  }





  Widget notificationTile(String title){

    return SwitchListTile(

      value:
          true,

      onChanged:
          (value){},


      title:
          Text(title),


      secondary:
          const Icon(
            Icons.notifications,
            color: Colors.blue,
          ),

    );
  }

}
