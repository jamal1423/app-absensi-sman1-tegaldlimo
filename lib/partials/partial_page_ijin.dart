// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_element, avoid_unnecessary_containers, avoid_print, use_build_context_synchronously, depend_on_referenced_packages, sort_child_properties_last, unnecessary_brace_in_string_interps, sized_box_for_whitespace

import 'package:app_presensi_smantegaldlimo/pages/page_home.dart';
import 'package:app_presensi_smantegaldlimo/pages/page_login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_presensi_smantegaldlimo/globals/apiUrl.dart' as url_api;

class PartPageIjin extends StatefulWidget {
  const PartPageIjin({super.key});

  @override
  State<PartPageIjin> createState() => _PartPageIjinState();
}

class _PartPageIjinState extends State<PartPageIjin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var txtEditDeskIjin = TextEditingController();
  var dateinput1 = TextEditingController();
  var dateinput2 = TextEditingController();
  final List<File> selectedImages = [];
  String username = "";
  String? kodeLok;
  String? namaLok;
  double? latit = 0;
  double? longit = 0;
  double? radius = 0;

  List<String> list = <String>['','Sakit', 'Ijin', 'Dinas Luar'];
  String valueIjin = '';

  Future<void> addImages() async {
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      maxWidth: 300, // can be customized
      maxHeight: 400, // can be customized
    );

    if (images != null) {
      for (XFile image in images) {
        selectedImages.add(File(image.path));
      }
    }
  }

  Widget dropDownIjin() {
    String dropdownValue = list.first;
    return DropdownButtonFormField<String>(
      autofocus: true,
      validator: (String? arg) {
        if (arg == null || arg.isEmpty) {
          return 'Jenis ijin harus diisi';
        } else {
          return null;
        }
      },
      isExpanded: false,
      isDense: true,
      alignment: Alignment.center,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.black,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
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
        prefixIcon: const Icon(
          Icons.moving_rounded,
          color: Colors.black,
        ),
        hintText: 'Pilih Jenis Ijin',
        hintStyle: const TextStyle(color: Color.fromARGB(255, 204, 202, 202)),
        labelText: "Jenis Ijin",
        labelStyle:
            const TextStyle(color: Color.fromARGB(255, 204, 202, 202)),
        filled: false,
      ),
      value: dropdownValue,
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      style: const TextStyle(color: Colors.black),
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
          valueIjin = dropdownValue;
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget inputDeskripsi() {
    return TextFormField(
        cursorColor: Colors.black,
        keyboardType: TextInputType.text,
        autofocus: false,
        // validator: (String? arg) {
        //   if (arg == null || arg.isEmpty) {
        //     return 'Keterangan harus diisi';
        //   } else {
        //     return null;
        //   }
        // },
        controller: txtEditDeskIjin,
        onSaved: (String? val) {
          txtEditDeskIjin.text = val!;
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Masukkan Deskripsi Ijin (optional)',
          hintStyle: const TextStyle(color: Color.fromARGB(255, 204, 202, 202)),
          labelText: "Deskripsi Ijin",
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
          String formattedDate =
              DateFormat('yyyy-MM-dd').format(DateTime.now());
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
        labelText: "Tanggal Akhir",
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
          String formattedDate =
              DateFormat('yyyy-MM-dd').format(DateTime.now());
          setState(() {
            dateinput2.text = formattedDate;
          });
          print("Date is not selected");
        }
      },
    );
  }

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var islogin = pref.getBool("is_login");
    if (islogin != null && islogin == true) {
      setState(() {
        username = pref.getString("username")!;
        // pref.setString('username', username);
        getDataLokasiUser(username);
      });
    } else {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const PageLogin(),
          ),
          (route) => false,
        );
      }
    }
  }

  Future getDataLokasiUser(usr) async {
    try {
      final response = await http.get(Uri.parse(
          "${url_api.baseUrl}/api/v1/get-cek-lokasi/$usr"));

      Map<String, dynamic> temp = json.decode(response.body);
      if (response.statusCode == 200) {
        if (context.mounted) {
          setState(() {
            kodeLok = temp['kode_lokasi'].toString();
            namaLok = temp['nama_lokasi'].toString();
            latit = double.parse(temp['latitude'].toString());
            longit = double.parse(temp['longitude'].toString());
            radius = double.parse(temp['radius'].toString());
          });
        }
      }
    } catch (e) {
      Navigator.pop(context, '$e');
      debugPrint('$e');
    }
  }

  void _validateInputs() async {
    final prefs = await SharedPreferences.getInstance();
    var usr = prefs.getString('username');
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      submitFormIjin(usr, latit, longit, kodeLok, valueIjin,
          txtEditDeskIjin.text ,dateinput1.text, dateinput2.text);
      // submitFormIjin(usr, latit, longit, kodeLok, txtEditKetIjin.text,
      //     dateinput1.text, dateinput2.text);
    }
  }

  submitFormIjin(
      username, lat, long, lokasi, keterangan, deskripsi, tglAwal, tglAkhir) async {
    AwesomeDialog(
      context: context,
      dismissOnTouchOutside: false,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      btnOkColor: Colors.blue,
      title: 'Konfirmasi',
      desc: 'Yakin akan melanjutkan proses ijin?\n Press OK untuk melanjutkan.',
      btnOkOnPress: () {
        postDataIjin(
            username, lat, long, lokasi, keterangan, deskripsi, tglAwal, tglAkhir);
      },
    ).show();
  }

  postDataIjin(usernamePost, latitPost, longitPost, lokasiPost, ketIjinPost, deskIjinPost,
    tglIjinAwPost, tglIjinAkPost) async {
    String apiUrl = "${url_api.baseUrl}/api/v1/proses-absensi-user";
    final response = await http.post(
        Uri.parse(apiUrl),
        // headers: {
        //   'Content-Type': 'multipart/form-data',
        // },
        body: {
          "username": usernamePost,
          "latitude": latitPost.toString(),
          "longitude": longitPost.toString(),
          "lokasi": lokasiPost,
          "ket_ijin": ketIjinPost,
          "deskripsi": deskIjinPost,
          "tgl_ijin_awal": tglIjinAwPost,
          "tgl_ijin_akhir": tglIjinAkPost,
          // "doc_ijin": fotoPost,
        });

        // final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
        // for (File image in selectedImages) {
        //   request.files.add(await http.MultipartFile.fromPath(
        //     'doc_ijin[]',
        //     image.path,
        //   ));
        // }

    final resp = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (resp['status'] == 'success') {
        AwesomeDialog(
          context: context,
          dismissOnTouchOutside: false,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Sukses',
          desc: 'Ijin berhasil, selanjutnya menunggu approval.',
          btnOkOnPress: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => PageHome(),
              ),
              (route) => false,
            );
          },
        ).show();
      } else {
        AwesomeDialog(
          context: context,
          dismissOnTouchOutside: false,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          btnOkColor: Colors.red,
          title: 'Failed',
          desc: 'Ijin gagal, silahkan ulangi proses.',
          btnOkOnPress: () {},
        ).show();
      }
    } else {
      AwesomeDialog(
        context: context,
        dismissOnTouchOutside: false,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        btnOkColor: Colors.red,
        title: 'Failed',
        desc: 'Ijin gagal, silahkan ulangi proses.',
        btnOkOnPress: () {},
      ).show();
    }
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
    getPref();
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
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
                child: Text("Keluar"),
              ),
              // const PopupMenuItem<int>(
              //   value: 1,
              //   child: Text("Settings"),
              // ),
              // const PopupMenuItem<int>(
              //   value: 2,
              //   child: Text("Logout"),
              // ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
              logOut();
            }
            // else if (value == 1) {
            //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //     content: Text('Ke Menu Setting'),
            //   ));
            // } else if (value == 2) {
            //   logOut();
            // }
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
                      dropDownIjin(),
                      const SizedBox(height: 20.0),
                      inputDeskripsi(),
                      const SizedBox(height: 20.0),
                      date1(),
                      const SizedBox(height: 20.0),
                      date2(),
                      // Text("Value : ${valueIjin}"),
                      // const SizedBox(height: 20.0),
                      // ElevatedButton.icon(
                      //   icon: Icon(Icons.image, color: Colors.black),
                      //   onPressed: () async {
                      //     await addImages();
                      //     setState(() {});
                      //   },
                      //   label: Text('Lampiran'),
                      //   style: ElevatedButton.styleFrom(
                      //       minimumSize:
                      //           Size.fromHeight(screenSize.height / 15),
                      //       foregroundColor: Colors.black),
                      // ),
                      const SizedBox(height: 20.0),
                      InkWell(
                        onTap: () {
                          // selectedImages.removeAt(imagesPath.values.toList().indexOf(f));
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(
                          //       content: Column(
                          //       children: selectedImages.map((image) => Image.file(image)).toList(),
                          //   )),
                          // );
                        },
                        child: Column(
                          children: selectedImages
                              .map((image) => Image.file(image))
                              .toList(),
                        ),
                      ),
                    ],
                  )),
              Container(
                padding:
                    const EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 168, 17, 156),
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
              ),
              const SizedBox(height: 30.0)
            ],
          ),
        ),
      ),
    );
  }
}
