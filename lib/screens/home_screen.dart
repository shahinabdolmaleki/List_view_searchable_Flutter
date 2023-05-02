import 'dart:convert';

import 'package:crypto/data/constant/constant.dart';
import 'package:crypto/data/model/crypto.dart';
import 'package:crypto/data/model/user.dart';
import 'package:crypto/screens/coin_list_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';

class home_screen extends StatefulWidget {
  const home_screen({Key? key}) : super(key: key);

  @override
  State<home_screen> createState() => _home_screenState();
}

class _home_screenState extends State<home_screen> {
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image(
                image: AssetImage('assets/images/logo.png'),
              ),
              SpinKitFadingCube(
                color: Colors.green[200],
                size: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getData() async {
    var response = await Dio().get('https://api.coincap.io/v2/assets');

    List<Crypto> cryptoList = response.data['data']
        .map<Crypto>((jsonMapObject) => Crypto.fromMapJson(jsonMapObject))
        .toList()
        .cast<Crypto>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => coin_list_screen(
          cryptoList: cryptoList,
        ),
      ),
    );
  }
}
