import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final teachers = [
      {
        "name": "Mrs. Priya Sharma",
        "subject": "Class Teacher - 6A",
        "image": "https://i.pravatar.cc/150?img=47",
        "lastMessage": "Rahul's homework is completed.",
        "time": "10:30 AM",
      },
      {
        "name": "Mr. Rajesh Kumar",
        "subject": "Mathematics Teacher",
        "image": "https://i.pravatar.cc/150?img=12",
        "lastMessage": "Please check the maths assignment.",
        "time": "Yesterday",
      },
      {
        "name": "Mrs. Anitha",
        "subject": "English Teacher",
        "image": "https://i.pravatar.cc/150?img=32",
        "lastMessage": "English competition details shared.",
        "time": "2 days ago",
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
              "Messages",
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
          // Info Card
          //--------------------------------


          Container(

            padding:
                const EdgeInsets.all(18),


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
                const Row(

              children: [

                Icon(
                  Icons.chat,
                  color: Colors.white,
                  size: 35,
                ),


                SizedBox(width: 15),


                Expanded(

                  child: Text(

                    "Communicate directly with your child's teachers",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),

                  ),
                )

              ],
            ),
          ),



          const SizedBox(height: 25),




          const Text(

            "Teachers",

            style:
                TextStyle(

              fontSize:
                  22,

              fontWeight:
                  FontWeight.bold,

            ),
          ),



          const SizedBox(height: 15),




          ...teachers.map((teacher){


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
                  ListTile(

                contentPadding:
                    const EdgeInsets.all(12),



                leading:
                    CircleAvatar(

                  radius:
                      28,

                  backgroundImage:
                      NetworkImage(

                    teacher["image"]
                        .toString(),

                  ),
                ),



                title:
                    Text(

                  teacher["name"]
                      .toString(),

                  style:
                      const TextStyle(

                    fontWeight:
                        FontWeight.bold,

                  ),
                ),



                subtitle:
                    Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,


                  children: [


                    Text(

                      teacher["subject"]
                          .toString(),

                    ),


                    const SizedBox(height: 5),


                    Text(

                      teacher["lastMessage"]
                          .toString(),

                      maxLines:
                          1,

                      overflow:
                          TextOverflow.ellipsis,

                    ),

                  ],
                ),



                trailing:
                    Text(

                  teacher["time"]
                      .toString(),

                  style:
                      const TextStyle(

                    fontSize:
                        11,

                  ),
                ),



                onTap: (){


                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                          TeacherChatDetailScreen(

                            teacherName:
                                teacher["name"]
                                    .toString(),

                          ),

                    ),

                  );

                },

              ),
            );

          })

        ],
      ),
    );
  }
}




class TeacherChatDetailScreen extends StatelessWidget {

  final String teacherName;


  const TeacherChatDetailScreen({

    super.key,

    required this.teacherName,

  });



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor:
          const Color(0xffF5F8FC),


      appBar: AppBar(

        title:
            Text(teacherName),

        backgroundColor:
            Colors.white,

        foregroundColor:
            Colors.black,

      ),



      body:
          Column(

        children: [



          Expanded(

            child:
                ListView(

              padding:
                  const EdgeInsets.all(16),


              children: [


                messageBubble(

                  "Hello, Rahul's parent. Rahul performed well in today's class.",

                  false,

                ),



                messageBubble(

                  "Thank you teacher. Please let us know if any improvement is required.",

                  true,

                ),



                messageBubble(

                  "Please practice Mathematics chapter 5 for tomorrow's class.",

                  false,

                ),

              ],
            ),
          ),




          Container(

            padding:
                const EdgeInsets.all(12),


            color:
                Colors.white,


            child:
                Row(

              children: [


                IconButton(

                  onPressed: () {},

                  icon:
                      const Icon(
                        Icons.attach_file,
                      ),

                ),



                Expanded(

                  child:
                      TextField(

                    decoration:
                        InputDecoration(

                      hintText:
                          "Type message",

                      border:
                          OutlineInputBorder(

                        borderRadius:
                            BorderRadius.circular(25),

                      ),

                    ),
                  ),
                ),



                IconButton(

                  onPressed: () {},

                  icon:
                      const Icon(
                        Icons.send,
                        color: Colors.blue,
                      ),

                )

              ],
            ),
          )

        ],
      ),
    );
  }




  Widget messageBubble(
      String message,
      bool isParent,
      ){

    return Align(

      alignment:
          isParent
              ? Alignment.centerRight
              : Alignment.centerLeft,


      child:
          Container(

        margin:
            const EdgeInsets.only(
              bottom: 15,
            ),


        padding:
            const EdgeInsets.all(14),


        constraints:
            const BoxConstraints(
              maxWidth: 280,
            ),


        decoration:
            BoxDecoration(

          color:
              isParent
                  ? Colors.blue
                  : Colors.white,


          borderRadius:
              BorderRadius.circular(18),

        ),


        child:
            Text(

          message,

          style:
              TextStyle(

            color:
                isParent
                    ? Colors.white
                    : Colors.black,

          ),
        ),
      ),
    );
  }

}