import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('報價系統', style: TextStyle(color: Color(0xFF222222))),
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
              constraints: const BoxConstraints(maxWidth: 900),
              margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
              child: Flex(
                direction: (MediaQuery.of(context).size.width < 600) ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, color: Color(0xFF111111)),
                    label: const Text('建立新報價', style: TextStyle(color: Color(0xFF111111))),
                    onPressed: () => Navigator.pushNamed(context, '/edit'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(160, 56),
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF111111),
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ).copyWith(
                      overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                        if (states.contains(MaterialState.pressed) || states.contains(MaterialState.hovered)) {
                          return const Color(0xFFF0F0F0);
                        }
                        return null;
                      }),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width < 600 ? 0 : 32, height: MediaQuery.of(context).size.width < 600 ? 24 : 0),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit, color: Color(0xFF111111)),
                    label: const Text('編輯舊報價', style: TextStyle(color: Color(0xFF111111))),
                    onPressed: () => Navigator.pushNamed(context, '/list'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(160, 56),
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF111111),
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ).copyWith(
                      overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                        if (states.contains(MaterialState.pressed) || states.contains(MaterialState.hovered)) {
                          return const Color(0xFFF0F0F0);
                        }
                        return null;
                      }),
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