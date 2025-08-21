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
  final dio = Dio();
  var isLoading = false;
  var apiResponse = Everything();
  var search = "yogyakarta";
  var pageSize = 5;

  @override
  void initState() {
    super.initState();
    getApi();
  }

  getApi() async {
    setState(() {
      isLoading = true;
    });

    if (search == "") {
      setState(() {
        apiResponse = Everything();
        isLoading = false;
      });
    } else {
      final url =
          "https://newsapi.org/v2/everything?language=id&from=2025-08-01&sortBy=publishedAt&apiKey=c807a263fd1443a99d906c8959b602d9&q=$search&pagesize=$pageSize";
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        var encodedData = jsonEncode(response.data);
        var parsedResponse = everythingFromJson(encodedData);

        setState(() {
          apiResponse = parsedResponse;
          isLoading = false;
        });
      } else {
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
          ? Center(child: CircularProgressIndicator())
          : apiResponse.articles == null || apiResponse.articles?.length == 0
              ? Center(
                  child: Text("Tidak ada data"),
                )
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
