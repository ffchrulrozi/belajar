import 'dart:convert';

import 'package:basic_api/news/models/everything.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class NewsV2Page extends StatefulWidget {
  const NewsV2Page({super.key});

  @override
  State<NewsV2Page> createState() => _NewsV2PageState();
}

class _NewsV2PageState extends State<NewsV2Page> {
  // dio adalah library buat integrasi api
  final dio = Dio();
  var isLoading = false;
  // everything adalah sebuah class model (format/struktur response api)
  var apiResponse = Everything();
  var search = "yogyakarta";
  var pageSize = 5;

  // initState adalah sebuah function yang pertama kali dipanggil
  @override
  void initState() {
    super.initState();
    // panggil function getApi() ketika baru init app
    getApi();
  }

  getApi() async {
    // pada saat get api, untuk awalnya set loading tre
    setState(() {
      isLoading = true;
    });

    if (search == "") {
      setState(() {
        // jika search kosong, maka set data kosong
        apiResponse = Everything();
        isLoading = false;
      });
    } else {
      final url =
          "https://newsapi.org/v2/everything?language=id&from=2025-08-01&sortBy=publishedAt&apiKey=c807a263fd1443a99d906c8959b602d9&q=$search&pagesize=$pageSize";

      // dio.get adalah proses get data dari api
      final response = await dio.get(url);

      // statusCode=200 berarti data berhasil diambil, sedangkan yang lain kemungkinan error
      // misal: 400=error body, 401=gagal autentikasi, 404=data tidak ada, 500=error server
      if (response.statusCode == 200) {
        // jika statusCode=200, maka encode kan data api tersebut
        var encodedData = jsonEncode(response.data);
        // lalu di parsing ke dalam class model dengan memanggil function everythingFromJson
        var parsedResponse = everythingFromJson(encodedData);

        // setelah sukses, maka set state apiResponse dan loading=false
        setState(() {
          apiResponse = parsedResponse;
          isLoading = false;
        });
      } else {
        // tampilkan errornya apa di console
        debugPrint("API error: ${response.statusMessage}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          initialValue: search,
          decoration: InputDecoration(hintText: "Cari..."),
          onChanged: (value) {
            setState(() {
              search = value;
            });

            getApi();
          },
        ),
        actions: [
          DropdownButton(
            value: pageSize,
            items: [
              DropdownMenuItem(value: 3, child: Text("3")),
              DropdownMenuItem(value: 5, child: Text("5")),
              DropdownMenuItem(value: 10, child: Text("10")),
              DropdownMenuItem(value: 15, child: Text("15")),
              DropdownMenuItem(value: 20, child: Text("20")),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  pageSize = value;
                });
                getApi();
              }
            },
          )
        ],
      ),
      body: isLoading
          // jika loading=true, maka show icon loading
          ? Center(child: CircularProgressIndicator())
          // jika artikel kosong, maka tampilkan pesan "tidak ada data"
          : apiResponse.articles == null || apiResponse.articles?.length == 0
              ? Center(
                  child: Text("Tidak ada data"),
                )
              // jika datanya ada
              : ListView.builder(
                  itemCount: apiResponse.articles!.length,
                  itemBuilder: (context, index) {
                    final data = apiResponse.articles![index];

                    return Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          data.urlToImage != null
                              ? Image.network(
                                  data.urlToImage!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.broken_image,
                                        size: 100, color: Colors.grey);
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                )
                              : SizedBox(
                                  width: 100,
                                  height: 100,
                                ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.title ?? "",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(data.description ?? "")
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
