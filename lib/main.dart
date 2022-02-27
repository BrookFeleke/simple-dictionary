import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _url = "https://owlbot.info/api/v4/dictionary/";
  final String token = "0609d9caadf1bafaa61b15f162f52f699f625c24";
  final TextEditingController _searchT = TextEditingController();

  late StreamController _streamController;
  late Stream _stream;
  _search() async {
    if ( _searchT.text.length == 0) {
      _streamController.add(null);
      return;
    }
    _streamController.add("waiting");
    try {
      final String URL = _url + _searchT.text.trim();
      Response response = await get(Uri.parse(URL),
          headers: {"Authorization": "Token " + token});
      _streamController.add(jsonDecode(response.body));
    } catch (e) {
      print(e);
    }
  }

Widget wordDetail(BuildContext context, snapshot, index) {
  return SimpleDialog(
    contentPadding: EdgeInsets.zero,
    children: [
      Container( child: snapshot.data["definitions"][index]
                                      ["image_url"] ==
                                  null
                              ? null
                              : 
                                  Image(image:NetworkImage((snapshot
                                      .data["definitions"][index]["image_url"])),) 
                                ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Text("Definition: " + snapshot.data["definitions"][index]["definition"],),
          const SizedBox(height: 10,),
          Text("Example :" + snapshot.data["definitions"][index]["example"]),
          // Text(snapshot.data["definitions"][index]["emoji"])
        ],),
      )
    ],
  );
}

  @override
  void initState() {
    super.initState();

    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Dictionary"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24)),
                  child: TextFormField(
                    onChanged: (String text) {},
                    controller: _searchT,
                    decoration: const InputDecoration(
                        hintStyle: TextStyle(
                            color: Color.fromARGB(255, 184, 181, 181)),
                        hintText: "Search for word",
                        contentPadding: EdgeInsets.only(left: 24),
                        border: InputBorder.none),
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    _search();
                  },
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ))
            ],
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder(
          stream: _stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Center(child: Text("Enter a word to search"));
            }
            if (snapshot.data == "waiting") {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data["definitions"].length,
              itemBuilder: (BuildContext context, int index) {
                return ListBody(
                  children: [
                    Container(
                      color: const Color.fromARGB(131, 182, 182, 182),
                      child: GestureDetector(
                        onTap: (() => {
                          showDialog(context: (context), builder: (context) => wordDetail(context, snapshot, index) )
                        }),
                        child: ListTile(
                          leading: snapshot.data["definitions"][index]
                                      ["image_url"] ==
                                  null
                              ? null
                              : CircleAvatar(
                                  backgroundImage: NetworkImage((snapshot
                                      .data["definitions"][index]["image_url"])),
                                ),
                          title: Row(
                            children: [
                              Text(_searchT.text.trim()),
                              Text(
                                "   " + snapshot.data["definitions"][index]["type"],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Text("Definition: " + snapshot.data["definitions"][index]["definition"])
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
