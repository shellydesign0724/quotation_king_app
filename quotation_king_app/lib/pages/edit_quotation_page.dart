import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:confetti/confetti.dart';

class EditQuotationPage extends StatefulWidget {
  const EditQuotationPage({super.key});

  @override
  State<EditQuotationPage> createState() => _EditQuotationPageState();
}

class _EditQuotationPageState extends State<EditQuotationPage> {
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _items = [];
  List<TextEditingController> _itemNameControllers = [];
  List<TextEditingController> _itemPriceControllers = [];

  List<TextEditingController> _noteControllers = [];
  int get _total => List.generate(_items.length, (i) {
    final price = int.tryParse(_itemPriceControllers[i].text) ?? 0;
    return price;
  }).fold(0, (int sum, int price) => sum + price);
  bool get _canSaveQuotation => _titleController.text.trim().isNotEmpty && _items.isNotEmpty;
  List<bool> _itemEditMode = [];
  List<bool> _noteEditMode = [];
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 3500));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _titleController.dispose();
    for (var c in _itemNameControllers) {
      c.dispose();
    }
    for (var c in _itemPriceControllers) {
      c.dispose();
    }
    for (var c in _noteControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && _titleController.text.isEmpty) {
      // 避免重複帶入
      _titleController.text = args['title'] ?? '';
      if (args['date'] != null) {
        _selectedDate = DateTime.tryParse(args['date']);
      }
      final items = (args['items'] as List?) ?? [];
      _items = List.generate(items.length, (i) => {'name': '', 'price': 0});
      _itemNameControllers = List.generate(items.length, (i) => TextEditingController(text: items[i]['name']?.toString() ?? ''));
      _itemPriceControllers = List.generate(items.length, (i) => TextEditingController(text: (items[i]['price'] ?? '').toString()));
      final notes = (args['notes'] as List?) ?? [];
      _noteControllers = List.generate(notes.length, (i) => TextEditingController(text: notes[i]?.toString() ?? ''));
      _itemEditMode = List.generate(_items.length, (_) => false); // 預設檢視狀態
      _noteEditMode = List.generate(_noteControllers.length, (_) => false); // 預設檢視狀態
      setState(() {});
    }
  }

  void _addItem() {
    setState(() {
      _items.add({'name': '', 'price': 0});
      _itemNameControllers.add(TextEditingController());
      _itemPriceControllers.add(TextEditingController());
      _itemEditMode.add(true);
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _itemNameControllers.removeAt(index).dispose();
      _itemPriceControllers.removeAt(index).dispose();
      _itemEditMode.removeAt(index);
    });
  }

  void _addNote() {
    setState(() {
      _noteControllers.add(TextEditingController());
      _noteEditMode.add(true);
    });
  }

  void _removeNote(int index) {
    setState(() {
      _noteControllers.removeAt(index).dispose();
      _noteEditMode.removeAt(index);
    });
  }

  Future<void> _saveQuotation() async {
    _confettiController.play();
    final prefs = await SharedPreferences.getInstance();
    final quotation = {
      'title': _titleController.text,
      'date': _selectedDate?.toIso8601String(),
      'items': List.generate(_items.length, (i) => {
        'name': _itemNameControllers[i].text,
        'price': int.tryParse(_itemPriceControllers[i].text) ?? 0,
      }),
      'notes': _noteControllers.map((c) => c.text).toList(),
      'total': _total,
    };
    final list = prefs.getStringList('quotations') ?? [];
    list.add(jsonEncode(quotation));
    await prefs.setStringList('quotations', list);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已儲存報價')));
      await Future.delayed(const Duration(milliseconds: 3500));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('建立新報價', textAlign: TextAlign.center),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black87,
          ),
          backgroundColor: const Color(0xFFF7F7FA),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final horizontalMargin = isWide ? 240.0 : 16.0;
              return Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
                  child: ListView(
                    children: [
                          // 報價主題
                          Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0.5,
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('報價主題', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _titleController,
                                    decoration: const InputDecoration(
                                      hintText: '輸入報價主題...',
                                      border: InputBorder.none,
                                      filled: true,
                                      fillColor: Color(0xFFF7F7FA),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // 日期
                          Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0.5,
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('日期', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: _selectedDate ?? DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _selectedDate = picked;
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF7F7FA),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Text(
                                            _selectedDate == null
                                                ? '選擇日期'
                                                : '${_selectedDate!.year}年${_selectedDate!.month.toString().padLeft(2, '0')}月${_selectedDate!.day.toString().padLeft(2, '0')}日',
                                            style: TextStyle(
                                              color: _selectedDate == null ? Colors.grey : Colors.black87,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // 報價品項
                          Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0.5,
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('報價品項', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.add, size: 18),
                                        label: const Text('新增品項'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          textStyle: const TextStyle(fontSize: 14),
                                        ),
                                        onPressed: _addItem,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _items.isEmpty
                                      ? const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 24.0),
                                          child: Center(child: Text('尚未新增任何品項', style: TextStyle(color: Colors.grey))),
                                        )
                                      : Column(
                                          children: List.generate(_items.length, (i) => Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: _itemEditMode.length > i && _itemEditMode[i]
                                                ? Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: TextField(
                                                          controller: _itemNameControllers[i],
                                                          decoration: const InputDecoration(
                                                            labelText: '品項名稱',
                                                            labelStyle: TextStyle(color: Color(0xFFBDBDBD)),
                                                            border: OutlineInputBorder(),
                                                            isDense: true,
                                                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                            hintText: '品項名稱',
                                                            hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                                                          ),
                                                          onChanged: (_) => setState(() {}),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        flex: 1,
                                                        child: TextField(
                                                          controller: _itemPriceControllers[i],
                                                          decoration: const InputDecoration(
                                                            labelText: '金額',
                                                            labelStyle: TextStyle(color: Color(0xFFBDBDBD)),
                                                            border: OutlineInputBorder(),
                                                            isDense: true,
                                                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                            hintText: '金額',
                                                            hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                                                          ),
                                                          keyboardType: TextInputType.number,
                                                          onChanged: (_) => setState(() {}),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.save, color: Colors.blue),
                                                        tooltip: '儲存品項',
                                                        onPressed: () {
                                                          setState(() {
                                                            _itemEditMode[i] = false;
                                                          });
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('品項已儲存'), duration: Duration(seconds: 1)),
                                                          );
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete, color: Colors.red),
                                                        onPressed: () => _removeItem(i),
                                                      ),
                                                    ],
                                                  )
                                                : Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(_itemNameControllers[i].text, style: const TextStyle(fontSize: 16)),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Text(_itemPriceControllers[i].text, style: const TextStyle(fontSize: 16)),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                                        tooltip: '編輯品項',
                                                        onPressed: () {
                                                          setState(() {
                                                            _itemEditMode[i] = true;
                                                          });
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete, color: Colors.red),
                                                        onPressed: () => _removeItem(i),
                                                      ),
                                                    ],
                                                  ),
                                          )),
                                        ),
                                ],
                              ),
                            ),
                          ),
                          // 備註
                          Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0.5,
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('備註', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.add, size: 18),
                                        label: const Text('新增備註'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          textStyle: const TextStyle(fontSize: 14),
                                        ),
                                        onPressed: _addNote,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _noteControllers.isEmpty
                                      ? const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 24.0),
                                          child: Center(child: Text('尚未新增任何備註', style: TextStyle(color: Colors.grey))),
                                        )
                                      : Column(
                                          children: List.generate(_noteControllers.length, (i) => Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: _noteEditMode.length > i && _noteEditMode[i]
                                                ? Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextField(
                                                          controller: _noteControllers[i],
                                                          decoration: InputDecoration(
                                                            labelText: '備註 ${i + 1}',
                                                            border: const OutlineInputBorder(),
                                                            isDense: true,
                                                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                          ),
                                                          onChanged: (_) => setState(() {}),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.save, color: Colors.blue),
                                                        tooltip: '儲存備註',
                                                        onPressed: () {
                                                          setState(() {
                                                            _noteEditMode[i] = false;
                                                          });
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('備註已儲存'), duration: Duration(seconds: 1)),
                                                          );
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete, color: Colors.red),
                                                        onPressed: () => _removeNote(i),
                                                      ),
                                                    ],
                                                  )
                                                : Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(_noteControllers[i].text, style: const TextStyle(fontSize: 16)),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                                        tooltip: '編輯備註',
                                                        onPressed: () {
                                                          setState(() {
                                                            _noteEditMode[i] = true;
                                                          });
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete, color: Colors.red),
                                                        onPressed: () => _removeNote(i),
                                                      ),
                                                    ],
                                                  ),
                                          )),
                                        ),
                                ],
                              ),
                            ),
                          ),
                          // 儲存/捨棄按鈕
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 總金額 section
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '總金額: NT\$ $_total',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _canSaveQuotation ? _saveQuotation : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _canSaveQuotation ? Colors.black : Colors.grey.shade400,
                                          foregroundColor: _canSaveQuotation ? Colors.white : Colors.black,
                                          padding: const EdgeInsets.symmetric(vertical: 18),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 0,
                                        ),
                                        child: const Text('儲存報價', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        side: BorderSide(color: Colors.grey.shade400),
                                      ),
                                      child: const Text('捨棄', style: TextStyle(fontSize: 16)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Color(0xFFB3E5FC), // 淡藍
                Color(0xFFFFF9C4), // 淡黃
                Color(0xFFC8E6C9), // 淡綠
                Color(0xFFFFCCBC), // 淡橘
                Color(0xFFD1C4E9), // 淡紫
              ],
              numberOfParticles: 80,
              minBlastForce: 8,
              maxBlastForce: 15,
              emissionFrequency: 0.03,
              gravity: 0.35,
              particleDrag: 0.07,
            ),
          ),
        ),
      ],
    );
  }
} 