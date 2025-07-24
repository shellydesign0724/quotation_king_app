import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class QuotationListPage extends StatefulWidget {
  const QuotationListPage({super.key});

  @override
  State<QuotationListPage> createState() => _QuotationListPageState();
}

class _QuotationListPageState extends State<QuotationListPage> {
  List<Map<String, dynamic>> _quotations = [];
  List<Map<String, dynamic>> _filteredQuotations = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQuotations();
  }

  Future<void> _loadQuotations() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('quotations') ?? [];
    setState(() {
      _quotations = list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
      _filteredQuotations = List.from(_quotations);
    });
  }

  void _onSearchChanged(String value) {
    final keyword = value.trim().toLowerCase();
    setState(() {
      if (keyword.isEmpty) {
        _filteredQuotations = List.from(_quotations);
      } else {
        _filteredQuotations = _quotations.where((q) {
          final title = (q['title'] ?? '').toString().toLowerCase();
          final date = (q['date'] ?? '').toString().toLowerCase();
          return title.contains(keyword) || date.contains(keyword);
        }).toList();
      }
    });
  }

  void _deleteQuotation(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('quotations') ?? [];
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      await prefs.setStringList('quotations', list);
      setState(() {
        _quotations.removeAt(index);
        _filteredQuotations = List.from(_quotations);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('已刪除報價'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(top: 0, left: 24, right: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.black87,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('舊報價管理', style: TextStyle(color: Color(0xFF222222))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF222222)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final horizontalMargin = isWide ? 240.0 : 16.0;
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
              child: Column(
                children: [
                  // 搜尋/篩選區塊
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      labelText: '搜尋報價主題或日期',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 報價列表
                  Expanded(
                    child: _filteredQuotations.isEmpty
                        ? const Center(child: Text('尚無報價'))
                        : ListView.builder(
                            itemCount: _filteredQuotations.length,
                            itemBuilder: (context, index) {
                              final q = _filteredQuotations[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Card(
                                  color: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                                  ),
                                  child: ListTile(
                                    title: Text(q['title'] ?? ''),
                                    subtitle: Text((q['date'] ?? '').toString().split('T')[0]),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => Navigator.pushNamed(
                                            context,
                                            '/edit',
                                            arguments: q,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => _deleteQuotation(index),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 