import 'package:crypto/data/constant/constant.dart';
import 'package:crypto/data/model/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:crypto/data/model/user.dart';
import 'package:searchable_listview/searchable_listview.dart';

class coin_list_screen extends StatefulWidget {
  coin_list_screen({Key? key, this.cryptoList}) : super(key: key);
  List<Crypto>? cryptoList;

  @override
  State<coin_list_screen> createState() => _coin_list_screenState();
}

class _coin_list_screenState extends State<coin_list_screen> {
  bool isUpdating = false;
  List<Crypto>? cryptoList;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cryptoList = widget.cryptoList;
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: blackColor,
        title: Padding(
          padding: EdgeInsets.only(left: 39),
          child: Text(
            'کریپتو بازار',
            style: TextStyle(
              fontFamily: 'mr',
              fontSize: 25,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(child: _refreshPage()),
      ),
    );
  }

  Widget _getList(Crypto crypto) {
    return ListTile(
      title: Text(
        crypto.name,
        style: TextStyle(color: greenColor),
      ),
      subtitle: Text(crypto.symbol, style: TextStyle(color: greyColor)),
      leading: SizedBox(
        width: 30,
        child: Center(
          child:
              Text(crypto.rank.toString(), style: TextStyle(color: greyColor)),
        ),
      ),
      trailing: SizedBox(
        width: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  crypto.priceUsd.toStringAsFixed(2),
                  style: TextStyle(color: greyColor, fontSize: 16),
                ),
                Text(
                  crypto.changePercent24hr.toStringAsFixed(2),
                  style: TextStyle(
                      color: _changeColorText(crypto.changePercent24hr)),
                ),
              ],
            ),
            SizedBox(
              width: 51,
              child: Center(
                child: _getIconChangePercent(crypto.changePercent24hr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIconChangePercent(double percentChange) {
    return percentChange <= 0
        ? Icon(
            Icons.trending_down,
            color: Colors.red,
            size: 25,
          )
        : Icon(
            Icons.trending_up,
            size: 25,
            color: Colors.green,
          );
  }

  Color _changeColorText(double percentChange) {
    return percentChange <= 0 ? redColor : greenColor;
  }

  Widget _refreshPage() {
    return Column(
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: TextField(
            onChanged: (value) {
              _filterList(value);
            },
            decoration: InputDecoration(
                hintText: 'رمز  ارز  را  سرچ  کنید',
                hintStyle: TextStyle(
                  fontFamily: 'mr',
                  fontSize: 14,
                  color: Colors.white,
                ),
                border: OutlineInputBorder(
                    borderSide: BorderSide(width: 0, style: BorderStyle.none),
                    borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: greenColor),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Visibility(
          visible: isUpdating,
          child: Text(
            '...اطلاعات رمز ارز ها در حال آپدیت ',
            style: TextStyle(color: greenColor, fontFamily: 'mr', fontSize: 14),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            color: Colors.white,
            backgroundColor: greenColor,
            strokeWidth: 2.0,
            onRefresh: () async {
              List<Crypto> freshData = await _getData();
              setState(() {
                cryptoList = freshData;
              });
              return Future<void>.delayed(const Duration(seconds: 3));
            },
            // Pull from top to show refresh indicator.
            child: ListView.builder(
              itemCount: cryptoList!.length,
              itemBuilder: (context, index) {
                return _getList(cryptoList![index]);
              },
            ),
          ),
        )
      ],
    );
  }

  Future<List<Crypto>> _getData() async {
    var response = await Dio().get('https://api.coincap.io/v2/assets');

    List<Crypto> cryptoList = response.data['data']
        .map<Crypto>((jsonMapObject) => Crypto.fromMapJson(jsonMapObject))
        .toList()
        .cast<Crypto>();
    return cryptoList;
  }

  Future<void> _filterList(String enteredKeyword) async {
    List<Crypto> cryptoResultList = [];
    if (enteredKeyword.isEmpty) {
      setState(() {
        isUpdating = true;
      });

      var result = await _getData();
      setState(() {
        isUpdating = false;
        cryptoList = result;
      });
      return;
    }
    cryptoResultList = cryptoList!.where((element) {
      return element.name.toLowerCase().contains(enteredKeyword.toLowerCase());
    }).toList();
    setState(() {
      cryptoList = cryptoResultList;
    });
  }
}
