import 'package:flutter/material.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final albums = [
      {
        "title": "Annual Day",
        "photos": "120 Photos",
        "image":
            "https://images.unsplash.com/photo-1503095396549-807759245b35",
      },
      {
        "title": "Sports Day",
        "photos": "85 Photos",
        "image":
            "https://images.unsplash.com/photo-1461896836934-ffe607ba8211",
      },
      {
        "title": "Science Exhibition",
        "photos": "60 Photos",
        "image":
            "https://images.unsplash.com/photo-1532094349884-543bc11b234d",
      },
      {
        "title": "Classroom Activities",
        "photos": "95 Photos",
        "image":
            "https://images.unsplash.com/photo-1509062522246-3755977927d7",
      },
      {
        "title": "Independence Day",
        "photos": "70 Photos",
        "image":
            "https://images.unsplash.com/photo-1531058020387-3be344556be6",
      },
    ];


    return Scaffold(

      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(

        backgroundColor: Colors.white,

        elevation: 0,

        centerTitle: true,

        title: const Text(
          "School Gallery",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),


      body: GridView.builder(

        padding:
            const EdgeInsets.all(16),

        itemCount: albums.length,

        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(

          crossAxisCount: 2,

          crossAxisSpacing: 15,

          mainAxisSpacing: 15,

          childAspectRatio: .85,

        ),


        itemBuilder: (context,index){

          final album = albums[index];


          return GestureDetector(

            onTap: (){

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) =>
                      PhotoGridScreen(
                        title:
                            album["title"]
                                .toString(),
                      ),

                ),

              );

            },


            child: Container(

              decoration:
                  BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(20),

              ),


              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,


                children: [

                  Expanded(

                    child: ClipRRect(

                      borderRadius:
                          const BorderRadius.only(

                        topLeft:
                            Radius.circular(20),

                        topRight:
                            Radius.circular(20),

                      ),


                      child: Image.network(

                        album["image"]
                            .toString(),

                        width:
                            double.infinity,

                        fit:
                            BoxFit.cover,

                      ),
                    ),
                  ),


                  Padding(

                    padding:
                        const EdgeInsets.all(12),


                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,


                      children: [

                        Text(

                          album["title"]
                              .toString(),

                          style:
                              const TextStyle(

                            fontWeight:
                                FontWeight.bold,

                            fontSize: 16,

                          ),
                        ),


                        const SizedBox(height: 5),


                        Text(

                          album["photos"]
                              .toString(),

                          style:
                              TextStyle(

                            color:
                                Colors.grey.shade600,

                          ),
                        ),

                      ],
                    ),
                  )

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}



class PhotoGridScreen extends StatelessWidget {

  final String title;

  const PhotoGridScreen({
    super.key,
    required this.title,
  });


  @override
  Widget build(BuildContext context) {


    final photos = [

      "https://images.unsplash.com/photo-1503095396549-807759245b35",

      "https://images.unsplash.com/photo-1461896836934-ffe607ba8211",

      "https://images.unsplash.com/photo-1532094349884-543bc11b234d",

      "https://images.unsplash.com/photo-1509062522246-3755977927d7",

      "https://images.unsplash.com/photo-1531058020387-3be344556be6",

      "https://images.unsplash.com/photo-1523050854058-8df90110c9f1",

    ];


    return Scaffold(

      appBar: AppBar(

        title:
            Text(title),

      ),


      body: GridView.builder(

        padding:
            const EdgeInsets.all(12),

        itemCount:
            photos.length,


        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(

          crossAxisCount: 3,

          crossAxisSpacing: 8,

          mainAxisSpacing: 8,

        ),


        itemBuilder:(context,index){

          return ClipRRect(

            borderRadius:
                BorderRadius.circular(12),


            child: Image.network(

              photos[index],

              fit:
                  BoxFit.cover,

            ),
          );

        },
      ),
    );
  }
}