import 'package:flutter/material.dart';

class TourKeys {
  static final GlobalKey japaCounterKey = GlobalKey();
  static final GlobalKey malaProgressKey = GlobalKey();
  static final GlobalKey mantraSelectorKey = GlobalKey();
  static final GlobalKey historyKey = GlobalKey();
  static final GlobalKey settingsKey = GlobalKey();

  static List<GlobalKey> get allKeys => [
        japaCounterKey,
        malaProgressKey,
        mantraSelectorKey,
        historyKey,
        settingsKey,
      ];
}
