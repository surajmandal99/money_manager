import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_manager/controllers/db_helper.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/add_transaction.dart';
import 'package:money_manager/widgets/conform_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  DbHelper dbHelper = DbHelper();
  DateTime today = DateTime.now();
  late Box box;
  // DateTime now = DateTime.now();
  int totalBalance = 0;
  int totalIncome = 0;
  int totalExpense = 0;
  late SharedPreferences preferences;
  List<FlSpot> dataSet = [];

  @override
  void initState() {
    super.initState();
    getPreferences();
    box = Hive.box("money");
    fetch();
  }

  getPreferences() async {
    preferences = await SharedPreferences.getInstance();
  }

  Future<List<TransactionModel>> fetch() async {
    if (box.values.isEmpty) {
      return Future.value([]);
    } else {
      List<TransactionModel> items = [];
      box.toMap().values.forEach((element) {
        // print(element);
        items.add(TransactionModel(element["amount"],
            element["date"] as DateTime, element["note"], element["type"]));
      });
      return items;
    }
  }

  ///fun to get plotPoints
  List<FlSpot> getPloatPoints(List<TransactionModel> entireData) {
    dataSet = [];

    List tempDataSet = [];
    for (TransactionModel data in entireData) {
      if (data.date.month == today.month && data.type == "Expense") {
        tempDataSet.add(data);
      }
    }
    //sorting of
    tempDataSet.sort((a, b) => a.date.day.compareTo(b.date.day));

    for (var i = 0; i < tempDataSet.length; i++) {
      dataSet.add(FlSpot(
        tempDataSet[i].date.day.toDouble(),
        tempDataSet[i].amount.toDouble(),
      ));
    }

    return dataSet;
  }

  //fun to get totalBalance
  getTotalBalance(List<TransactionModel> entireData) {
    totalBalance = 0;
    totalExpense = 0;
    totalIncome = 0;
    for (TransactionModel data in entireData) {
      if (data.date.month == today.month) {
        if (data.type == "Income") {
          totalBalance += data.amount;
          totalIncome += data.amount;
        } else {
          totalBalance -= data.amount;
          totalExpense += data.amount;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0.0,
        ),
        backgroundColor: const Color(0xffe2e7ef),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTransaction()),
            ).whenComplete(() {
              setState(() {});
            });
          },
          backgroundColor: Colors.blueAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: const Icon(
            Icons.add,
            size: 31,
          ),
        ),
        body: FutureBuilder<List<TransactionModel>>(
            future: fetch(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text("Unexpected Error"),
                );
              }
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return const Center(child: Text("No Values Found"));
                }

                //card totalbalance
                getTotalBalance(snapshot.data!);
                getPloatPoints(snapshot.data!);
                return ListView(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white70,
                                  ),
                                  child: const CircleAvatar(
                                      maxRadius: 20,
                                      backgroundImage: AssetImage(
                                        'assets/images/profile.png',
                                      )),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Welcome ${preferences.getString('name')}",
                                  style: GoogleFonts.lato(
                                      fontSize: 22,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white70,
                              ),
                              padding: const EdgeInsets.all(5),
                              child: const Icon(
                                Icons.settings,
                                size: 31,
                                color: Color(0xff3E454C),
                              ),
                            ),
                          ],
                        )),

                    //Money Card
                    Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      margin: const EdgeInsets.all(12),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.blueAccent,
                            Colors.lightBlue,
                          ]),
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 8),
                        child: Column(children: [
                          const Text(
                            "Total Balance",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 22,
                                color: Colors.white),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Text(
                            "Rs  $totalBalance",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 28,
                                color: Colors.white),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                cardIncome(totalIncome.toString()),
                                cardExpense(totalExpense.toString()),
                              ],
                            ),
                          )
                        ]),
                      ),
                    ),

                    //recent Expenses
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        "Expenses",
                        style: GoogleFonts.lato(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    //chart

                    dataSet.length < 2
                        ? Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.lightBlue.withOpacity(0.3),
                                    spreadRadius: 4,
                                    offset: const Offset(0, 5),
                                  ),
                                ]),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 34),
                            margin: const EdgeInsets.all(12),
                            child: const Text("Not Enough Data to Ploat"),
                          )
                        : Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.lightBlue.withOpacity(0.3),
                                    spreadRadius: 4,
                                    offset: const Offset(0, 5),
                                  ),
                                ]),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 34),
                            margin: const EdgeInsets.all(12),
                            height: 400,
                            child: LineChart(LineChartData(
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                      spots: getPloatPoints(snapshot.data!),
                                      isCurved: false,
                                      barWidth: 2.5,
                                      color: Colors.blueAccent)
                                ])),
                          ),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        "Recent Transactions",
                        style: GoogleFonts.lato(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    //list of income and expenses

                    ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          TransactionModel dataAtIndex;
                          try {
                            dataAtIndex = snapshot.data![index];
                            try {
                              dataAtIndex = snapshot.data![index];
                            } catch (e) {
                              return Container();
                            }
                          } catch (e) {
                            return Container();
                          }

                          if (dataAtIndex.type == "Income") {
                            return incomeTile(dataAtIndex.amount,
                                dataAtIndex.note, dataAtIndex.date, index);
                          } else {
                            return expenseTile(
                              dataAtIndex.amount,
                              dataAtIndex.note,
                              dataAtIndex.date,
                              index,
                            );
                          }
                        }),
                    const SizedBox(
                      height: 60,
                    ),
                  ],
                );
              } else {
                return const Text("Unexpected Error");
              }
            }));
  }
}

//CARD INCOME

Widget cardIncome(String value) {
  return Row(
    children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(6.0),
        margin: const EdgeInsets.only(right: 8),
        child: Icon(
          Icons.arrow_downward,
          size: 26,
          color: Colors.green[700],
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Income",
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          Text(
            value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white70),
          )
        ],
      )
    ],
  );
}

//CARD EXPENSES

Widget cardExpense(String value) {
  return Row(
    children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(6.0),
        margin: const EdgeInsets.only(right: 8),
        child: Icon(
          Icons.arrow_upward,
          size: 26,
          color: Colors.red[700],
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Expense",
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          Text(
            value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white70),
          )
        ],
      )
    ],
  );
}

//EXPENSE TILE
DbHelper dbHelper = DbHelper();

List<String> months = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec",
];
Widget expenseTile(int value, String note, DateTime date, int index) {
  return InkWell(
    splashColor: Colors.blueAccent,
    onLongPress: () async {
      bool? ans = await showConfirmDialog(
          context, "WARNING", "Do you want to delete this record ?");
      if (ans != null && ans) {
        dbHelper.deleteData(index);
      }
    },
    child: Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: const Color(0xffced4eb),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.arrow_circle_down_outlined,
                    size: 23,
                    color: Colors.green,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    "Expense",
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "${date.day} , ${months[date.month - 1]}",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "- $value",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                " $note",
                style: TextStyle(color: Colors.grey[900]),
              ),
            ],
          )
        ],
      ),
    ),
  );
}

//INCOME TILE

Widget incomeTile(int value, String note, DateTime date, int index) {
  List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  return Container(
    margin: const EdgeInsets.all(8),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
        color: const Color(0xffced4eb), borderRadius: BorderRadius.circular(8)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Row(
              children: [
                Icon(
                  Icons.arrow_circle_down_outlined,
                  size: 23,
                  color: Colors.green,
                ),
                SizedBox(
                  width: 4,
                ),
                Text(
                  "Income",
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "${date.day} , ${months[date.month - 1]}",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "+ $value",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              " $note",
              style: TextStyle(color: Colors.grey[900]),
            ),
          ],
        )
      ],
    ),
  );
}
