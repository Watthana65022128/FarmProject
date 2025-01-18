import 'package:flutter/material.dart';
import '../models/farm_model.dart';
import '../widgets/custom_navigation_bar.dart';
import 'scan.dart';
import '../screens/overview_home.dart';
import '../models/receipt_model.dart';
import '../screens/transaction_list.dart';
import 'budget.dart';
import 'notification.dart';
import '../utils/refreshable_state.dart';

class FarmInfoPage extends StatefulWidget {
  final FarmModel farm;

  const FarmInfoPage({
    super.key,
    required this.farm,
  });

  @override
  State<FarmInfoPage> createState() => _FarmInfoPageState();
}

class _FarmInfoPageState extends State<FarmInfoPage> with RefreshableState {
  int _selectedIndex = 0;
  late FarmModel _currentFarm;

  // เพิ่ม GlobalKey สำหรับแต่ละหน้า
  final _overviewKey = GlobalKey<State<OverviewPage>>();
  final _transactionKey = GlobalKey<State<TransactionListPage>>();
  final _notificationKey = GlobalKey<State<NotificationPage>>();
  final _budgetKey = GlobalKey<State<BudgetPage>>();

  @override
  void initState() {
    super.initState();
    _currentFarm = widget.farm;
  }

  @override
  void refreshData() {
    _refreshAllPages();
  }

  void _updateFarmBudget(double newBudget) {
  setState(() {
    _currentFarm = _currentFarm.copyWith(budget: newBudget);
    
    // refresh เฉพาะหน้า Notification
    if (_notificationKey.currentState != null && _notificationKey.currentState is RefreshableState) {
      (_notificationKey.currentState as dynamic).refreshData();
    }
  });
}

 void _refreshAllPages() {
    // เรียก refresh ของแต่ละหน้า
    (_overviewKey.currentState as RefreshableState?)?.refreshData();
    (_transactionKey.currentState as RefreshableState?)?.refreshData();
    (_notificationKey.currentState as RefreshableState?)?.refreshData();
    (_budgetKey.currentState as RefreshableState?)?.refreshData();
}

  @override
  Widget build(BuildContext context) {
    final navigationIndex =
        _selectedIndex >= 2 ? _selectedIndex + 1 : _selectedIndex;

    final int farmId = _currentFarm.id ?? 0;
    final double budget = _currentFarm.budget ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentFarm.name),
        centerTitle: true,
        backgroundColor: const Color(0xFFF3FCEE),
        foregroundColor: Colors.black,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          OverviewPage(
            key: _overviewKey,
            farm: _currentFarm,
            onBudgetUpdate: _updateFarmBudget,
          ),
          TransactionListPage(
            key: _transactionKey,
            farmId: farmId,
          ),
          NotificationPage(
            key: _notificationKey,
            farmId: farmId,
            budget: budget,
          ),
          BudgetPage(
            key: _budgetKey,
            farmId: farmId,
            budget: budget,
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: navigationIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  void _navigateToScan() async {
    final int farmId = _currentFarm.id ?? 0;
    if (farmId <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่พบข้อมูลฟาร์ม'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final Receipt? newReceipt = await Navigator.push<Receipt>(
        context,
        MaterialPageRoute(
          builder: (context) => ScanPage(farmId: farmId),
          fullscreenDialog: true,
        ),
      );

      if (mounted && newReceipt != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('บันทึกใบเสร็จสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _selectedIndex = 0;
          // เรียก refresh ทุกหน้าหลังจากบันทึกใบเสร็จ
          _refreshAllPages();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _navigateToScan();
    } else {
      setState(() {
        _selectedIndex = index > 2 ? index - 1 : index;
      });
    }
  }
}
