// ignore_for_file: prefer_const_constructors, avoid_print, prefer_interpolation_to_compose_strings, non_constant_identifier_names, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations

import 'package:app_presensi_smantegaldlimo/models/data_absen.dart';
import 'package:app_presensi_smantegaldlimo/pages/page_home.dart';
import 'package:app_presensi_smantegaldlimo/pages/page_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timeline_calendar/timeline/model/calendar_options.dart';
import 'package:flutter_timeline_calendar/timeline/model/datetime.dart';
import 'package:flutter_timeline_calendar/timeline/model/day_options.dart';
import 'package:flutter_timeline_calendar/timeline/model/headers_options.dart';
import 'package:flutter_timeline_calendar/timeline/provider/instance_provider.dart';
import 'package:flutter_timeline_calendar/timeline/utils/calendar_types.dart';
import 'package:flutter_timeline_calendar/timeline/utils/datetime_extension.dart';
import 'package:flutter_timeline_calendar/timeline/widget/timeline_calendar.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PartPageRiwayatAbsensi extends StatefulWidget {
  const PartPageRiwayatAbsensi({super.key});

  @override
  State<PartPageRiwayatAbsensi> createState() => _PartPageRiwayatAbsensiState();
}

class _PartPageRiwayatAbsensiState extends State<PartPageRiwayatAbsensi> {
  late CalendarDateTime selectedDateTime;
  late DateTime? weekStart;
  late DateTime? weekEnd;
  String username = "";

  final DateFormat formatterDate = DateFormat('dd-MM-yyyy H:m:s');
  final DateFormat formatterDate2 = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    TimelineCalendar.calendarProvider = createInstance();
    selectedDateTime = TimelineCalendar.calendarProvider.getDateTime();
    getLatestWeek();
    getPref();
  }

  getLatestWeek() {
    setState(() {
      weekStart = selectedDateTime.toDateTime().findFirstDateOfTheWeek();
      weekEnd = selectedDateTime.toDateTime().findLastDateOfTheWeek();
    });
  }

  _goBack(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const PageHome(),
      ),
      (route) => false,
    );
  }

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var islogin = pref.getBool("is_login");
    if (islogin != null && islogin == true) {
      setState(() {
        username = pref.getString("username")!;
        // pref.setString('username', username);
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

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 250, 250, 252),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: Colors.black,
            height: 0.5,
          ),
        ),
        title: Text("Riwayat Absensi", style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _timelineCalendar(),
          SizedBox(height: 25),
          // Text("Selected Date : $selectedDateTime"),
          Center(
            child: FutureBuilder<List<DataAbsen>>(
                future: fetchAbsensi(selectedDateTime.toString()),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                children: [
                                  SizedBox(height: 10),
                                  snapshot.data![index].username.toString() == 'nothing' 
                                  ? 
                                  Center(
                                    child: Text("Data tidak ditemukan"),
                                  )
                                  :
                                    snapshot.data![index].ijin.toString() == 'YES'
                                    ?
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(blurRadius: 1.5)
                                          ]),
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "User",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  Text(
                                                    snapshot.data![index].namaPegawai
                                                        .toString().toUpperCase(),
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    "Status Ijin",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  snapshot.data![index].statusIjin.toString() == 'YES'
                                                  ?
                                                  Text("APPROVED",
                                                    style: TextStyle(
                                                        color: Colors.green, fontWeight: FontWeight.bold),
                                                  )
                                                  :
                                                  Text("PENDING",
                                                    style: TextStyle(
                                                        color: Colors.red, fontWeight: FontWeight.bold),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Divider(
                                            height: 5,
                                            color: Colors.black,
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Tgl. Ijin Awal",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  Text(formatterDate2.format(DateTime.parse('${snapshot.data![index].tglIjinAwal}')).toString(),
                                                    style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    "Tgl. Ijin Akhir",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  Text(formatterDate2.format(DateTime.parse('${snapshot.data![index].tglIjinAkhir}')).toString(),
                                                    style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text("Keterangan Ijin",style: TextStyle(fontSize: 10)),
                                                      Text("${snapshot.data![index].ketIjin.toString()}")
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                    :
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(blurRadius: 1.5)
                                          ]),
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "User",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  Text(
                                                    snapshot.data![index].namaPegawai
                                                        .toString().toUpperCase(),
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    "Lokasi",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  Text(
                                                    snapshot.data![index].namaLokasi
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Divider(
                                            height: 5,
                                            color: Colors.black,
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Clock-In",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  Text(formatterDate.format(DateTime.parse('${snapshot.data![index].tgl_c_in}')).toString(),
                                                    style: TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    "Clock-Out",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  Text(
                                                    snapshot.data![index].c_out.toString() == ""
                                                    ?
                                                      "-"
                                                    :
                                                    formatterDate.format(DateTime.parse('${snapshot.data![index].tgl_c_out}')).toString(),
                                                    style: TextStyle(
                                                        color: snapshot.data![index].c_out.toString() == ""
                                                        ?
                                                        Colors.red
                                                        :
                                                        Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text("Late",style: TextStyle(fontSize: 10)),
                                                      Text("${snapshot.data![index].lateS.toString()}")
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text("Early",style: TextStyle(fontSize: 10)),
                                                      Text("${snapshot.data![index].early.toString()}")
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      Text("OverTime",style: TextStyle(fontSize: 10)),
                                                      Text("${snapshot.data![index].overtime.toString()}")
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  SizedBox(height: 10)
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }
                  return const CircularProgressIndicator(color: Colors.blue);
                }),
          )
        ],
      ),
    );
  }

  _timelineCalendar() {
    return TimelineCalendar(
      calendarType: CalendarType.GREGORIAN,
      calendarLanguage: "en",
      calendarOptions: CalendarOptions(
        viewType: ViewType.DAILY,
        toggleViewType: true,
        headerMonthElevation: 10,
        headerMonthShadowColor: Colors.black26,
        headerMonthBackColor: Colors.transparent,
        // weekStartDate: weekStart,
        // weekEndDate: weekEnd
      ),
      dayOptions: DayOptions(
        compactMode: true,
        disableDaysAfterNow: true,
        dayFontSize: 14.0,
        disableFadeEffect: true,
        weekDaySelectedColor: const Color(0xff3AC3E2),
        differentStyleForToday: true,
        todayBackgroundColor: Colors.black,
        selectedBackgroundColor: Colors.grey,
        todayTextColor: Colors.white,
      ),
      headerOptions: HeaderOptions(
        weekDayStringType: WeekDayStringTypes.SHORT,
        monthStringType: MonthStringTypes.FULL,
        backgroundColor: Color.fromARGB(255, 250, 250, 252),
        navigationColor: Color.fromARGB(255, 45, 4, 158),
        headerTextColor: Colors.black,
        resetDateColor: Colors.black,
        headerTextSize: 14,
      ),
      onChangeDateTime: (dateTime) {
        print("Date Change $dateTime");
        selectedDateTime = dateTime;
        getLatestWeek();
      },
      onDateTimeReset: (resetDateTime) {
        print("Date Reset $resetDateTime");
        selectedDateTime = resetDateTime;
        getLatestWeek();
      },
      onMonthChanged: (monthDateTime) {
        print("Month Change $monthDateTime");
        selectedDateTime = monthDateTime;
        getLatestWeek();
      },
      onYearChanged: (yearDateTime) {
        print("Year Change $yearDateTime");
        selectedDateTime = yearDateTime;
        getLatestWeek();
      },
      dateTime: selectedDateTime,
    );
  }
}

Future<List<DataAbsen>> fetchAbsensi($tgl) async {
  final prefs = await SharedPreferences.getInstance();
  var ss = prefs.getString('username');
  final response = await http.get(Uri.parse(
      'https://smantegaldlimo.startdev.my.id/api/v1/riwayat-absensi/$ss/' + $tgl));
  if (response.statusCode == 200) {
    final List result = json.decode(response.body);
    return result.map((e) => DataAbsen.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}
