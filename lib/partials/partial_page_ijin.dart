// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_element, avoid_unnecessary_containers, avoid_print

import 'package:app_presensi_smantegaldlimo/pages/page_login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:intl/intl.dart';

class PartPageIjin extends StatefulWidget {
  const PartPageIjin({super.key});

  @override
  State<PartPageIjin> createState() => _PartPageIjinState();
}

class _PartPageIjinState extends State<PartPageIjin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var txtEditKetIjin = TextEditingController();
  var dateinput1 = TextEditingController();
  var dateinput2 = TextEditingController();

  Widget inputUsername() {
    return TextFormField(
        cursorColor: Colors.black,
        keyboardType: TextInputType.text,
        autofocus: false,
        validator: (String? arg) {
          if (arg == null || arg.isEmpty) {
            return 'Keterangan harus diisi';
          } else {
            return null;
          }
        },
        controller: txtEditKetIjin,
        onSaved: (String? val) {
          txtEditKetIjin.text = val!;
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Masukkan Keterangan Ijin',
          hintStyle: const TextStyle(color: Color.fromARGB(255, 204, 202, 202)),
          labelText: "Keterangan Ijin",
          labelStyle:
              const TextStyle(color: Color.fromARGB(255, 204, 202, 202)),
          prefixIcon: const Icon(
            Icons.text_format_rounded,
            color: Colors.black,
          ),
          fillColor: Colors.grey,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: const BorderSide(
              color: Colors.black,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: const BorderSide(
              color: Colors.black,
              width: 1.0,
            ),
          ),
        ),
        style: const TextStyle(fontSize: 16.0, color: Colors.black));
  }

  Widget date1() {
    return TextFormField(
      cursorColor: Colors.black,
      controller: dateinput1,
      validator: (String? arg) {
        if (arg == null || arg.isEmpty) {
          return 'Tanggal awal harus diisi';
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelStyle: const TextStyle(color: Color.fromARGB(255, 204, 202, 202)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: const BorderSide(
            color: Colors.black,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        prefixIcon: const Icon(
          Icons.calendar_month,
          color: Colors.black,
        ),
        labelText: "Tanggal Awal",
        fillColor: Colors.grey,
      ),
      readOnly: true, //set it true, so that user will not able to edit text
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime
                .now(), //DateTime.now() - not to allow to choose before today.
            lastDate: DateTime.now().add(Duration(days: 366)));

        if (pickedDate != null) {
          print(
              pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          print(
              formattedDate); //formatted date output using intl package =>  2021-03-16
          setState(() {
            dateinput1.text =
                formattedDate; //set output date to TextField value.
          });
        } else {
          String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
          setState(() {
          dateinput1.text = formattedDate;
          });
          print("Date is not selected");
        }
      },
    );
  }
  
  Widget date2() {
    return TextFormField(
      cursorColor: Colors.black,
      controller: dateinput2,
      validator: (String? arg) {
        if (arg == null || arg.isEmpty) {
          return 'Tanggal akhir harus diisi';
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelStyle: const TextStyle(color: Color.fromARGB(255, 204, 202, 202)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: const BorderSide(
            color: Colors.black,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        prefixIcon: const Icon(
          Icons.calendar_month,
          color: Colors.black,
        ),
        labelText: "Tanggal Awal",
        fillColor: Colors.grey,
      ),
      readOnly: true, //set it true, so that user will not able to edit text
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime
                .now(), //DateTime.now() - not to allow to choose before today.
            lastDate: DateTime.now().add(Duration(days: 366)));

        if (pickedDate != null) {
          print(
              pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          print(
              formattedDate); //formatted date output using intl package =>  2021-03-16
          setState(() {
            dateinput2.text =
                formattedDate; //set output date to TextField value.
          });
        } else {
          String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
          setState(() {
          dateinput2.text = formattedDate;
          });
          print("Date is not selected");
        }
      },
    );
  }

  void _validateInputs() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      submitFormIjin(txtEditKetIjin.text, dateinput1.text, dateinput2.text);
    }
  }

  submitFormIjin(keterangan, tglAwal, tglAkhir) async {
    AwesomeDialog(
      context: context,
      dismissOnTouchOutside: false,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      btnOkColor: Colors.blue,
      title: 'Info',
      desc: 'Data $keterangan $tglAwal $tglAkhir',
      btnOkOnPress: () {},
    ).show();
  }

  logOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.remove("is_login");
      preferences.remove("username");
      preferences.remove("fullname");
    });

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const PageLogin(),
        ),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
          "Berhasil logout",
          style: TextStyle(fontSize: 16),
        )),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 250, 252),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: Colors.black,
            height: 0.5,
          ),
        ),
        title: Row(
          children: [
            const Text("Form Ijin", style: TextStyle(color: Colors.black)),
          ],
        ),
        actionsIconTheme: IconThemeData(color: Colors.black),
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              const PopupMenuItem<int>(
                value: 0,
                child: Text("Profile"),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Text("Settings"),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Text("Logout"),
              ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Ke Menu Profile'),
              ));
            } else if (value == 1) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Ke Menu Setting'),
              ));
            } else if (value == 2) {
              logOut();
            }
          }),
        ],
      ),
      body: Container(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                  padding:
                      const EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
                  child: Column(
                    children: <Widget>[
                      inputUsername(),
                      const SizedBox(height: 20.0),
                      date1(),
                      const SizedBox(height: 20.0),
                      date2()
                    ],
                  )),
              Container(
                padding:
                    const EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 16, 36, 151),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(color: Colors.white60),
                        ),
                        elevation: 10,
                        minimumSize: const Size(200, 58)),
                    onPressed: () => _validateInputs(),
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Kirim",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
