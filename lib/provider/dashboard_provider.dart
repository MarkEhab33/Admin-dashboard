
import 'package:flutter/material.dart';

class DashboardProvider with ChangeNotifier {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    // Ensure index is within valid range (0-6 for our current pages)
    if (index >= 0 && index <= 6) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}
