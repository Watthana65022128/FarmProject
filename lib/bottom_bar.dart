import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onScanPressed() {
    // ฟังก์ชั่นสำหรับเปิดสแกน QR Code
    print('Scan button pressed');
    // TODO: เพิ่มโค้ดสำหรับเปิดกล้องและสแกน QR Code
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Selected Index: $_selectedIndex'),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 4,
        color: Colors.green,
        child: SizedBox(
          height: 60.0,  // เพิ่มความสูงเล็กน้อยเพื่อรองรับปุ่มสแกน
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // ปุ่มภาพรวม
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.dashboard,
                    color: _selectedIndex == 0 ? Colors.white : Colors.black,
                  ),
                  onPressed: () => _onItemTapped(0),
                ),
              ),
              // ปุ่มรายการ
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.receipt_long,
                    color: _selectedIndex == 1 ? Colors.white : Colors.black,
                  ),
                  onPressed: () => _onItemTapped(1),
                ),
              ),
              // เพิ่มช่องว่างตรงกลางสำหรับปุ่มสแกน
              const Expanded(
                child: SizedBox(),
              ),
              // ปุ่มงบประมาณ
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.account_balance_wallet,
                    color: _selectedIndex == 2 ? Colors.white : Colors.black,
                  ),
                  onPressed: () => _onItemTapped(2),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: _onScanPressed,
        child: const Icon(
          Icons.qr_code_scanner,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}