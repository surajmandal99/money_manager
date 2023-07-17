import 'package:flutter/material.dart';
import 'package:money_manager/controllers/db_helper.dart';
import 'package:money_manager/pages/home_page.dart';

class AddName extends StatefulWidget {
  const AddName({super.key});

  @override
  State<AddName> createState() => _AddNameState();
}

class _AddNameState extends State<AddName> {
  DbHelper dbHelper = DbHelper();
  String name = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
      ),
      backgroundColor: const Color(0xffe2e7ef),

      //body
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(8),
              width: 64,
              height: 64,
              child: Image.asset("assets/images/money.png"),
            ),
            const SizedBox(
              height: 12,
            ),
            const Text(
              "What Is Your Name ?",
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 12,
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: TextField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Your Name",
                ),
                style: const TextStyle(fontSize: 20),
                onChanged: (val) {
                  name = val;
                },
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            SizedBox(
                height: 52,
                width: MediaQuery.of(context).size.width * 1,
                child: ElevatedButton(
                  onPressed: () {
                    if (name.isNotEmpty) {
                      //add to database
                      dbHelper.addName(name);
                      //move to homepage
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const HomePage()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          action: SnackBarAction(
                              label: "OK",
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                              }),
                          backgroundColor: Colors.white,
                          content: const Text(
                            "Please Enter Your Name",
                            style: TextStyle(color: Colors.black, fontSize: 19),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Next",
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        width: 7,
                        child: Icon(Icons.navigate_next_rounded),
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
