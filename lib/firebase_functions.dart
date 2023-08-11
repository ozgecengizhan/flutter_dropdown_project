import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dropdown_project/global_variable.dart';


final databaseReference_input = FirebaseDatabase.instance.reference();
final databaseReference_output = FirebaseDatabase.instance.reference();
final databaseReference_outputt = FirebaseDatabase.instance.reference();


void VeriGonder(String key, String value) async {
  try {
    await databaseReference_output.child('Outputs/$key').set(value);
    print('Veri gönderildi: Key: $key, Value: $value');
  } catch (e) {
    print('Hata oluştu: $e');
  }
}


void VeriAl() async {
  try {
    DatabaseEvent event = await databaseReference_input.child('Inputs').once();
    DataSnapshot snapshot = event.snapshot;
    List<dynamic> values = snapshot.value is Map ? (snapshot.value as Map).values.toList() : [];
    onOff = values.where((value) => value == "on" || value == "off").toList();
    print('Firebase Input Verileri: $onOff');
  } catch (e) {
    print('Veri okuma hatası: $e');
  }
}


final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
void VeriSifirla() async {
  try {
    DatabaseEvent event = await databaseReference.child('Outputs').once();
    DataSnapshot snapshot = event.snapshot;
    if (snapshot.value == null) {
      print('Outputs yok');
      return;
    }
    Map<dynamic, dynamic> outputs = snapshot.value is Map ? (snapshot.value as Map) : {};
    outputs.forEach((key, value) async {
      await databaseReference.child('Outputs/$key').set('off');
      print('Value kapatıldı: Key: $key, Value: off');
    });
    print('Tüm value değerleri "off" olarak güncellendi.');
  } catch (e) {
    print('Hata oluştu: $e');
  }
}