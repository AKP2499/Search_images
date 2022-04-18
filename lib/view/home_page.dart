import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_images/constant/colors.dart';
import 'package:get_images/model/photo_model.dart';
import 'package:get_images/networking/repository/repository.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool showSpinner =false;
  ScrollController? controller;

  final TextEditingController search = TextEditingController();
  final key = GlobalKey<ScaffoldState>();
  int pageNumber = 1;
  int limit = 10;
  bool isLastPage=false;
  String? query="Math";
  List<Results?> photoResponse = [];


  @override
  void initState() {
    // TODO: implement initState
    Repository.getPic(pageNumber,query!,limit).then((value) {
      photoResponse = value;
      setState(() {});
    });
    super.initState();
    controller = ScrollController();
    controller!.addListener(() {
      if (controller!.hasClients) {
        if (controller!.position.maxScrollExtent == controller!.offset) {
          if(isLastPage==false){
            pageNumber++;
            Repository.getPic(pageNumber,query!,limit).then((value) {
              if(value.isNotEmpty){
                if(value.length<=limit){
                  photoResponse.addAll(value);
                  isLastPage=false;
                  setState(() {});
                }else{
                  isLastPage=true;
                  setState(() {});
                }
              }else{
                isLastPage=true;
                setState(() {});
              }
            });
          }else{

          }
        }
      }
    });
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Form(
      key: key,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Constant.primary,
            toolbarHeight: 80,
            title: Container(
              alignment: AlignmentDirectional.topCenter,
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(5)),
              child: Center(
                child: TextFormField(
                  controller: search,
                  keyboardType: TextInputType.url,
                  onChanged: (value){
                    // Repository.getPic(pageNumber,query!,limit).then((value) {
                    //   photoResponse = value;
                    //   setState(() {});
                    // });
                    query = value;
                  },
                  onFieldSubmitted: (val){
                    Repository.getPic(pageNumber,query!,limit).then((value) {
                      photoResponse = value;
                      setState(() {});
                    });
                    setState(() {
                      showSpinner= true;
                    });
                    photoResponse.clear();
                    val=query!;

                    setState(() {
                      showSpinner= true;
                    });
                  },
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          print("text");
                          search.clear();
                        },
                      ),
                      hintText: 'Search...',
                      border: InputBorder.none),
                ),
              ),
            )
          ),
          body:SingleChildScrollView(
            controller: controller,
            child: Column(
              children: [
                photoResponse.isNotEmpty?Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 30,
                        crossAxisSpacing: 20,
                        childAspectRatio: 3 / 4,
                      ),
                      itemCount: photoResponse.length,
                      itemBuilder: (BuildContext context, int index) {
                        return photoResponse[index]!.urls != []?Container(
                          color: Colors.grey,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Expanded(
                                  child: InkWell(
                                    child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image.network(
                                            "${photoResponse[index]!.urls!.regular}",
                                            fit: BoxFit.cover,
                                          ),
                                        )),
                                    onLongPress: () async {
                                      print("preeee");
                                      final ByteData imageData = await NetworkAssetBundle(Uri.parse("${photoResponse[index]!.urls!.regular}")).load("");
                                      final Uint8List bytes = imageData.buffer.asUint8List();
                                      Image.memory(bytes);
                                    },
                                  ),
                                ),
                              ]),
                        ):Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Center(
                              child: Text("No Data Found"),
                            )
                          ],
                        );
                      },
                    )):Column(
                  children: const [
                    Center(
                      child: Text("No Data Found",style: TextStyle(
                        fontSize: 30,
                      ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}


