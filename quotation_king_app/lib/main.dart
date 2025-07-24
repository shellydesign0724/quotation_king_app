import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/edit_quotation_page.dart';
import 'pages/quotation_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '報價系統',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/edit': (context) => const EditQuotationPage(),
        '/list': (context) => const QuotationListPage(),
      },
    );
  }
}
