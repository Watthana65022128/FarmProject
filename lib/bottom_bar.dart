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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Selected Index: $_selectedIndex'),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 2,
        color: Colors.green, // ตั้งค่าสีพื้นหลังของ BottomAppBar เป็นสีเขียว
        child: SizedBox(
          height: 50.0, // ปรับขนาดความสูงของ BottomAppBar
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.home,
                      color: _selectedIndex == 0 ? Colors.white : Colors.black, // เปลี่ยนสีไอคอนเมื่อเลือก
                    ),
                    onPressed: () => _onItemTapped(0),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.receipt_long,
                      color: _selectedIndex == 1 ? Colors.white : Colors.black, // เปลี่ยนสีไอคอนเมื่อเลือก
                    ),
                    onPressed: () => _onItemTapped(1),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.account_balance_wallet,
                      color: _selectedIndex == 2 ? Colors.white : Colors.black, // เปลี่ยนสีไอคอนเมื่อเลือก
                    ),
                    onPressed: () => _onItemTapped(2),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.person,
                      color: _selectedIndex == 3 ? Colors.white : Colors.black, // เปลี่ยนสีไอคอนเมื่อเลือก
                    ),
                    onPressed: () => _onItemTapped(3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add scanning function here
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
