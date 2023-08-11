import 'package:flutter/material.dart';



Color draggableColor_1 = Colors.red;
Color draggableColor_2 = Colors.yellow;
Color draggableColor_5 = Colors.white;
Color currentColor = Colors.grey;
List<Color> targetColors = [];
List<bool> borderStatus = [];
List<int> timerValues = [];
List<String> onOffDegerleri = [];
List<String> TargetlarOnOffDurumList = [];
List<String> io_input = ['I1', 'I2', 'I3', 'I4'];
List<String> io_output = ['O5', 'O6', 'O7', 'O8'];
List<String> ioIndexList= [];
List<dynamic> onOff = [];
String defaultSelectedValue = "" ;
int delayMillis = 500;
int saniye = 1 ;
int currentColorIndex = 0;
int stopCurrentColorIndex = 0;
int currentIndexValue = 0; 
bool isAnimating = false;
bool isStopped = false;
bool start = true;
bool dongude_start_kontrol = false;
bool isStartButtonDisabled = false;
bool animasyonadevam = true;
Map<int, String> choise_deger = {};
Map<int, String> targetDurumMap = {};
Map<int, int> targetAdimMap = {};
final controller = TextEditingController();
final delayMillisController = TextEditingController();
TextEditingController millisecondController = TextEditingController();




String infoText = """
INPUT: Esp32 den aldığımız on-off değeri ile kıyaslama yapıp geçişin olup olmamasını kontrol eder.

OUTPUT: Seçilen on-off değerine göre ESp-32 ile haberleşip kartlardan çıkış olup olmamasını gösterir.

TIMER: Geçiş anında timer kutusunda seçilen süre kadar beklenmesini sağlar.

START: Geçişi başlatır.

STOP: Geçişi durdurur.

RESTART: Seçili kutuları sıfırlamaz, geçişi başa sarar.

DELETE: Seçili kutuları ve tüm değerlerini sıfırlar. 

CYCLE SPEED: Geçiş hızını kontrol eder.
""";
