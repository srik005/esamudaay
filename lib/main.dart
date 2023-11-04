import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late bool isLiked = false;
  static const mFavorite = "Favorite";
  List items = [];
  List checkedItem = [];
  late double sum;
  late int prodCount = 0;
  List queryList = [];
  String query = '';
  ValueNotifier<int> valueChanged = ValueNotifier(0);
  late ScrollController controller;
  int count = 5;

  //int counter = 0;

  Future<void> readJson() async {
    final String response = await rootBundle.loadString("assets/products.json");
    final resp = await jsonDecode(response);
    setState(() {
      items = resp["products"];
    });

    print(resp);
  }

  @override
  void initState() {
    readJson();
    getFavorite();
    controller = ScrollController()..addListener(scrollItem);
    super.initState();
  }

  void saveFavorite(bool abc) async {
    /*setState(() {
      isLiked = !isLiked;
    });*/
    var preference = await SharedPreferences.getInstance();
    preference.setBool(mFavorite, abc);
  }

  void getFavorite() async {
    var preference = await SharedPreferences.getInstance();
    var getVal = preference.getBool(mFavorite)!;
    print("gttt $getVal");
    /*setState(() {
      isLiked = getVal;
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        actions: [
          SizedBox(
            width: MediaQuery.of(context).size.width - 100,
            height: 50,
            child: TextField(
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  hintText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  prefixIcon: Icon(Icons.search)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {},
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: const [
            UserAccountsDrawerHeader(
                accountName: Text("Sri"),
                accountEmail: Text("abc@testmail.com")),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            listWidget(),
            prodCount <= 0
                ? Container(
                    child: Container(),
                  )
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text("Go to cart"),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              side: BorderSide(width: 1, color: Colors.black)),
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  void _runFilter(String input) {
    // Refresh the UI
    setState(() {
      query = input;
      queryList = items.where((user) => user["title"].contains(input)).toList();
    });
  }

  void scrollItem() {
    if (controller.offset >= controller.position.maxScrollExtent) {
      setState(() {
        count += 5;
      });
    }
  }

  Widget listWidget() {
    return Expanded(
        child: queryList.isNotEmpty || query.isNotEmpty
            ? queryList.isEmpty
                ? const Center(child: Text("No product found"))
                : ListView.builder(
                    controller: controller,
                    itemCount: queryList.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int index) {
                      bool alsave = checkedItem.contains(queryList[index]);
                      print("cddd $alsave");

                      return Card(
                        color: Colors.white,
                        child: SizedBox(
                          width: 300,
                          height: 150,
                          child: Column(
                            children: [
                              ListTile(
                                leading: Image(
                                  image: NetworkImage(
                                      queryList[index]["thumbnail"]),
                                  width: 100,
                                  height: 100,
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (alsave) {
                                        checkedItem.remove(queryList[index]);
                                        print("fgttt $checkedItem");
                                      } else {
                                        print("222");
                                        checkedItem.add(queryList[index]);
                                        saveFavorite(true);
                                      }
                                    });

                                    //saveFavorite();
                                  },
                                  icon: Icon(
                                    Icons.favorite,
                                    color: alsave ? Colors.red : Colors.grey,
                                  ),
                                ),
                                title: Text(queryList[index]["title"]),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: RatingBarIndicator(
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Color(0xff00796B),
                                    ),
                                    itemCount: items.length,
                                    rating: double.parse(
                                        queryList[index]["rating"].toString()),
                                    itemSize: 30,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${'\u{20B9}'}${queryList[index]["price"].toString()}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  )
            : ListView.builder(
                itemCount: items.length,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  bool alsave = checkedItem.contains(items[index]);
                  print("cddd $alsave");

                  return Card(
                    color: Colors.white,
                    child: SizedBox(
                      width: 300,
                      height: 150,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ListTile(
                              leading: Image(
                                image: NetworkImage(items[index]["thumbnail"]),
                                width: 100,
                                height: 100,
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (alsave) {
                                      checkedItem.remove(items[index]);
                                      print("fgttt $checkedItem");
                                    } else {
                                      print("222");
                                      checkedItem.add(items[index]);
                                      saveFavorite(true);
                                    }
                                  });

                                  //saveFavorite();
                                },
                                icon: Icon(
                                  Icons.favorite,
                                  color: alsave ? Colors.red : Colors.grey,
                                ),
                              ),
                              title: Text(items[index]["title"]),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: RatingBarIndicator(
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Color(0xff00796B),
                                  ),
                                  itemCount: 5,
                                  rating: double.parse(
                                      items[index]["rating"].toString()),
                                  itemSize: 30,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "${'\u{20B9}'}${items[index]["price"].toString()}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(
                                          () {
                                            items[index]["counter"]++;
                                          },
                                        );

                                        checkedItem
                                            .add(items[index]["counter"]);
                                        sum = checkedItem.fold(
                                            0, (a, b) => a + b);
                                        print(sum);
                                        prodCount = items[index]["counter"];
                                        print("count ${checkedItem}");
                                      },
                                      icon: Icon(Icons.add),
                                    ),
                                    Text(
                                      items[index]["counter"].toString(),
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(
                                          () {
                                            items[index]["counter"] <= 0
                                                ? items[index]["counter"] = 0
                                                : items[index]["counter"]--;
                                          },
                                        );
                                        checkedItem
                                            .remove(items[index]["counter"]);
                                        sum = checkedItem.fold(
                                            0, (a, b) => a - b);
                                        print("rmmmm ${sum}");
                                      },
                                      icon: Icon(Icons.remove),
                                    ),
                                    /* Badge(
                                              label: Text(items[index]
                                                      ["counter"]
                                                  .toString()),
                                              child: Icon(Icons.add),
                                            ),*/
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ));
  }
}
