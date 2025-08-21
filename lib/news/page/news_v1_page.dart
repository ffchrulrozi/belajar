import 'dart:convert';

import 'package:basic_api/news/models/everything.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class NewsV1Page extends StatefulWidget {
  const NewsV1Page({super.key});

  @override
  State<NewsV1Page> createState() => _NewsV1PageState();
}

class _NewsV1PageState extends State<NewsV1Page> {
  final dio = Dio();
  var isLoading = false;
  var apiResponse = Everything();
  var q = "yogyakarta";
  var pageSize = 10;

  @override
  void initState() {
    super.initState();
    getApi();
  }

  getApi() async {
    setState(() {
      isLoading = true;
    });

    final url =
        "https://newsapi.org/v2/everything?from=2025-08-01&sortBy=publishedAt&apiKey=c807a263fd1443a99d906c8959b602d9&q=$q&pagesize=$pageSize";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "News App",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: apiResponse.articles?.length,
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
