import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager/controllers/db_helper.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({super.key});

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  int? amount;
  String note = "Some Expense";
  String type = "Income";
  DateTime selectedDate = DateTime.now();

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

  //datetime picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        firstDate: DateTime(2021, 12),
        initialDate: selectedDate,
        lastDate: DateTime(2050, 01));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0.0,
        ),
        backgroundColor: const Color(0xffe2e7ef),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Text(
              "Add Transaction",
              style:
                  GoogleFonts.lato(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.attach_money_outlined,
                      color: Colors.white,
                    )),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "0",
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 22),
                    onChanged: (val) {
                      try {
                        amount = int.parse(val);
                      } catch (e) {
                        const Dialog(
                          child: Text("Enter Integer Value"),
                        );
                      }
                    },
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.description_rounded,
                      color: Colors.white,
                    )),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Note on Transaction",
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 20),
                    onChanged: (val) {
                      note = val;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.moving_sharp,
                      color: Colors.white,
                    )),
                const SizedBox(
                  width: 12,
                ),
                ChoiceChip(
                  label: Text(
                    "Income",
                    style: TextStyle(
                        fontSize: 15,
                        color: type == "Income" ? Colors.white : Colors.black),
                  ),
                  selected: type == "Income" ? true : false,
                  selectedColor: Colors.blueAccent,
                  onSelected: (val) => {
                    if (val)
                      {
                        setState(
                          () {
                            type = "Income";
                          },
                        )
                      }
                  },
                ),
                const SizedBox(
                  width: 12,
                ),
                ChoiceChip(
                  label: Text(
                    "Expense",
                    style: TextStyle(
                        fontSize: 15,
                        color: type == "Expense" ? Colors.white : Colors.black),
                  ),
                  selected: type == "Expense" ? true : false,
                  selectedColor: Colors.blueAccent,
                  onSelected: (val) => {
                    if (val)
                      {
                        setState(
                          () {
                            type = "Expense";
                          },
                        )
                      }
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            TextButton(
                onPressed: () {
                  _selectDate(context);
                },
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.zero)),
                child: Row(
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.date_range,
                          color: Colors.white,
                        )),
                    const SizedBox(
                      width: 12,
                    ),
                    Text(
                      "${selectedDate.day} ${months[selectedDate.month - 1]}",
                      style: const TextStyle(fontSize: 20.0),
                    )
                  ],
                )),
            const SizedBox(
              height: 12,
            ),
            SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (amount != null && note.isNotEmpty) {
                      DbHelper dbHelper = DbHelper();
                      await dbHelper.addData(amount!, selectedDate, type, note);
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    } else {
                      print("Not all Value are Provided");
                    }
                  },
                  child: const Text(
                    "Add",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ))
          ],
        ));
  }
}
