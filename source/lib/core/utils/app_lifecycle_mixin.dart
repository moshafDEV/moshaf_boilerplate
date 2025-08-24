import 'package:flutter/material.dart';

mixin AppLifecycleMixin on WidgetsBindingObserver {
  void onDetached() {
    // Aplikasi kehilangan fokus
    print('App Detached!');
  }

  void onInactive() {
    // Aplikasi kehilangan fokus tetapi masih aktif
    print('App Inactive!');
  }

  void onPause() {
    // Aplikasi ditangguhkan (misalnya, perangkat keluar dari aplikasi)
    print('App Paused!');
  }

  void onResume() {
    // Aplikasi di-resume dari keadaan ditangguhkan
    print('App Resumed!');
  }
}
