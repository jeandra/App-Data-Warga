import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasi_data_warga/main.dart';

void main() {
  /// The status dot pulses forever, so pumpAndSettle would never return.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));
  }

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SipWargaApp());
    await settle(tester);
  }

  testWidgets('dashboard menampilkan ringkasan dan daftar warga', (tester) async {
    await pumpApp(tester);

    expect(find.text('Data Warga'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
    expect(find.text('42 KK'), findsOneWidget);
    expect(find.text('96 orang'), findsOneWidget);
    expect(find.text('Siti Aminah'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
  });

  testWidgets('pencarian menyaring daftar warga', (tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField), 'Budi');
    await settle(tester);

    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('Siti Aminah'), findsNothing);
    expect(find.text('1 data'), findsOneWidget);
  });

  testWidgets('tap warga membuka layar detail', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Siti Aminah'));
    await settle(tester);

    expect(find.text('Detail Warga'), findsOneWidget);
    expect(find.text('Data Kependudukan'), findsOneWidget);
    expect(find.text('Karyawan Swasta'), findsOneWidget);
    expect(find.text('Warga Tetap'), findsWidgets);

    await tester.tap(find.text('Tutup'));
    await settle(tester);

    expect(find.text('Data Warga'), findsOneWidget);
  });

  testWidgets('tombol tambah menyimpan warga baru', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await settle(tester);

    expect(find.text('Tambah Data Warga'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Joko Prasetyo');
    await tester.enterText(fields.at(1), '3271082219900001');
    await tester.enterText(fields.at(2), '29');
    await settle(tester);

    await tester.tap(find.text('Simpan Warga'));
    await settle(tester);

    expect(find.text('Joko Prasetyo'), findsOneWidget);
    expect(find.text('129'), findsOneWidget);
  });
}
