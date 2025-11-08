import 'package:flutter/foundation.dart';

class DashboardViewModel extends ChangeNotifier {
  // doar un exemplu, aici intra logica specifica Dashboard-ului
  int counter = 0;

  void increment() {
    counter++;
    notifyListeners();
  }
}
