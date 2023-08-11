  import 'dart:async';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';
  import 'firebase_options.dart';
  import 'package:firebase_database/firebase_database.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    readData();
    runApp(MaterialApp(home: MyApp()));
  }

  final databaseReference = FirebaseDatabase.instance.reference();

  void readData() async {
    try {
      DatabaseEvent event = await databaseReference.child('deneme').once();
      DataSnapshot snapshot = event.snapshot;
      print('Data : ${snapshot.value}');
    } catch (e) {
      print('Failed to read data: $e');
    }
  }

  void sendDataToFirebase(List<String> durumlar) {
    try {
      Map<String, String> ioMap = {};
      List<String> io_input = ['IO1', 'IO2', 'IO3', 'IO4'];
      List<String> io_output = ['IO1', 'IO2', 'IO3', 'IO4', 'IO5', 'IO6', 'IO7', 'IO8'];
      for (var i = 0; i <=3; i++) {
          ioMap[io_input[i]] = durumlar[i];
      }

      for (var i = 4; i <=7; i++) {
        ioMap[io_output[i]] = durumlar[i];
        
      }

      databaseReference.child('IOs').set(ioMap);
    } catch (e) {
      print('Error sending data to Firebase: $e');
    }
  }

  void VeriGonder(String key, String value) {
    try {
      databaseReference.child('IOs/$key').set(value);
    } catch (e) {
      print('Error sending data to Firebase: $e');
    }
  }

  class MyApp extends StatefulWidget {
    @override
    MyAppState createState() => MyAppState();
  }

  class MyAppState extends State<MyApp> {
    Color draggableColor_1 = Colors.red;
    Color draggableColor_2 = Colors.yellow;
    Color draggableColor_5 = Colors.white;
    Color _currentColor = Colors.grey;
    List<Color> targetColors = [];
    List<bool> borderStatus = [];
    List<int> timerValues = [];
    List<String> io_input = ['IO1', 'IO2', 'IO3', 'IO4'];
    List<String> io_output = ['IO5', 'IO6', 'IO7', 'IO8'];
    List<String> adimDurumlari = List.generate(8, (index) => 'off');
    List<String> durumlar = ['off', 'off', 'off', 'off', 'off', 'off', 'off', 'off'];
    Map<int, String> choise_deger = {};
    bool _isAnimating = false;
    bool start = true;
    bool _isStopped = false;
    int delayMillis = 500;
    int sira = 0;
    String textValue = "Off";

  void onClick(int index) {
    setState(() {
      if (choise_deger[index].toString() != "null") {
        sira = int.parse(choise_deger[index].toString().substring(2)) - 1;
        print("index: $index");
        if (durumlar[sira] == "off") 
          durumlar[sira] = "on";
        else {
          durumlar[sira] = "off";
        }
      }
    });
    sendDataToFirebase(durumlar);
    print(durumlar);
    print(sira);
  }

    Widget buildDraggable(Color draggableColor) {
      return Draggable<Color>(
        data: draggableColor,
        feedback: Container(
          height: 100.0,
          width: 100.0,
          color: draggableColor.withOpacity(0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Container(
            height: 100.0,
            width: 100.0,
            color: draggableColor,
            child: (draggableColor == draggableColor_1)
                ? Center(
                    child: Text(
                      "INPUT",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  )
                : (draggableColor == draggableColor_2)
                    ? Center(
                        child: Text(
                          "OUTPUT",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      )
                    : (draggableColor == draggableColor_5)
                        ? Center(
                            child: Text(
                              "TIMER",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          )
                        : null,
          ),
        ),
        onDragStarted: () async {
          if (draggableColor == draggableColor_5) {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text(" Timer:"),
                  content: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    maxLines: 1,
                  ),
                  actions: [
                    ElevatedButton(
                      child: const Text("Tamam"),
                      onPressed: () {
                        updateState().then((_) {
                          setState(() {});
                          Navigator.of(context).pop();
                        });
                      },
                    ),
                    ElevatedButton(
                      child: const Text("Kapat"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              },
            );
          }
        },
      );
    }

    Widget buildColorBlock(Color color, int index) {
      bool showBorder = (_isAnimating && borderStatus[index]) || (_isStopped && borderStatus[index]);
      int istenenindex = borderStatus.indexOf(true);
      String currentTextValue;
    if (color == draggableColor_1 || color == draggableColor_2) {
      int ioIndex = int.parse(choise_deger[index]?.substring(2) ?? '0') - 1;
      if (ioIndex >= 0 && ioIndex < durumlar.length) {
        currentTextValue = durumlar[ioIndex]; 
      } else {
        currentTextValue = "off";
      }
    } else {
      currentTextValue = timerValues[index].toString();
    }

      return GestureDetector(
        onTap: () {
          onClick(index);
          sendDataToFirebase(durumlar);
        },
        child: DragTarget<Color>(
          builder: (BuildContext context, List<Color?> candidateData, List<dynamic> rejectedData) {
            Color displayColor = candidateData.isNotEmpty ? candidateData[0]! : color;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Container(
                    decoration: showBorder
                        ? BoxDecoration(
                            border: Border.all(
                              width: 10.0,
                              color: istenenindex == index ? Colors.purple : Colors.transparent,
                            ),
                            color: displayColor,
                          )
                        : BoxDecoration(color: displayColor),
                    height: 100,
                    width: 100,
                    child: Column(
                      children: [
                        Expanded(
                          child: DragTarget<Color>(
                            builder: (BuildContext context, List<Color?> candidateData, List<dynamic> rejectedData) {
                              Color displayColor = candidateData.isNotEmpty ? candidateData[0]! : color;
                              return Container(
                                color: displayColor,
                                child: Center(
                                  child: Text(currentTextValue ,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                  ),
                                ),
                              );
                            },
                            onWillAccept: (data) => true,
                            onAccept: (data) {
                              setState(() {
                                targetColors[index] = data;
                              });
                            },
                          ),
                        ),
                        if (color == draggableColor_1 || color == draggableColor_2)
                          DropdownButton<String>(
                            dropdownColor: displayColor,
                            value: choise_deger[index],
                            items: (color == draggableColor_1 ? io_input : io_output).map((option) {
                              return DropdownMenuItem<String>(
                                value: option,
                                child: Text(
                                  option,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                choise_deger[index] = newValue!;
                                print(choise_deger);
                                print(newValue);
                              });
                            },
                          ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      );
    }

    Widget _buildColorChangingContainer() {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Builder(
          builder: (context) {
            Color displayColor = _isStopped ? _currentColor : Colors.grey;
            return AnimatedContainer(
              duration: const Duration(),
              color: _isAnimating && !_isStopped ? _currentColor : displayColor,
              height: 150.0, //screen
              width: 300.0,
            );
          },
        ),
      );
    }

    Future<void> updateState() async {
      targetColors.add(draggableColor_5);
      _currentColor = draggableColor_5;
      borderStatus = List.filled(targetColors.length, false);
      borderStatus[targetColors.length - 1] = true;
      timerValues.add(int.parse(_controller.text));
      print(timerValues.length);
      print(timerValues);
    }

    Future<void> timerState() async {
      delayMillis = int.parse(_delayMillisController.text);
    }

    void _showDelayMillis() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Saniye gir:"),
            content: TextField(
              controller: _delayMillisController,
              keyboardType: TextInputType.number,
              autofocus: true,
              maxLines: 1,
            ),
            actions: [
              ElevatedButton(
                child: Text("Tamam"),
                onPressed: () {
                  setState(() {
                    timerState().then((_) {
                      setState(() {});
                    });
                  });
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text("Kapat"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }

    int _currentColorIndex = 0;
    Future<void> _startAnimation() async {
      if (_isAnimating = true) {
        List<Color> targetColorsCopy = List<Color>.from(targetColors);
        if (targetColorsCopy.isNotEmpty) {
          setState(() {
            _currentColor = targetColorsCopy[_currentColorIndex];
            borderStatus = List<bool>.filled(targetColorsCopy.length, false);
          });
        }
        while (_isAnimating && targetColorsCopy.isNotEmpty) {
          await Future.delayed(Duration(milliseconds: delayMillis));
          if (!_isAnimating) {
            break;
          }
          setState(() {
            _currentColorIndex = (_currentColorIndex + 1) % targetColorsCopy.length;
            _currentColor = targetColorsCopy[_currentColorIndex];
            borderStatus = List<bool>.filled(targetColorsCopy.length, false);
            borderStatus[_currentColorIndex] = true;
          });
          if (_isAnimating && targetColorsCopy.isNotEmpty) {
            await Future.delayed(Duration(milliseconds: int.parse(delayMillis.toString())));
          } else {
            delayMillis = 500;
          }
          if (_currentColor == Color(0xffffffff)) {
            await Future.delayed(Duration(milliseconds: timerValues[_currentColorIndex]));
          }
          
          VeriGonder(io_output[_currentColorIndex], durumlar[_currentColorIndex]);
          VeriGonder(io_input[_currentColorIndex], durumlar[_currentColorIndex]);
        }
      }
    }

    final _controller = TextEditingController();
    final _delayMillisController = TextEditingController();
    String onOff_durum = "Kapalı";
    int values = 0;

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.green[200],
          appBar: AppBar(title: const Text("Draggable Tutorial")),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildColorChangingContainer(),
                const SizedBox(height: 50.0),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      buildDraggable(draggableColor_1),
                      buildDraggable(draggableColor_2),
                      buildDraggable(draggableColor_5),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                DragTarget<Color>(
                  builder: (BuildContext context, List<Color?> candidateData, List<dynamic> rejectedData) {
                    Color displayColor = Colors.grey;
                    if (candidateData.isNotEmpty) {
                      displayColor = candidateData[0]!;
                    }
                    return Container(
                      height: 100.0,
                      width: 100.0,
                      color: displayColor,
                      child: candidateData.isNotEmpty ? Container(color: candidateData[0]) : null,
                    );
                  },
                  onWillAccept: (data) => true,
                  onAccept: (data) {
                    setState(() {
                      targetColors.add(data);
                      _currentColor = data;
                      borderStatus = List<bool>.filled(targetColors.length, false);
                      borderStatus[targetColors.length - 1] = true;
                      timerValues.add(0);
                      print(timerValues);
                      print(timerValues.length);
                    });
                  },
                ),
                const SizedBox(height: 10.0),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(targetColors.length, (index) => buildColorBlock(targetColors[index], index)),
                  ),
                ),
                const SizedBox(width: 5,),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            start = true;
                            _currentColorIndex = 0;
                          });
                          _startAnimation();
                        },
                        child: Text('Start Button', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            start = false;
                            _isAnimating = false;
                            _isStopped = true;
                          });
                        },
                        child: Text('Stop Button', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            targetColors.clear();
                            start = false;
                            _isAnimating = false;
                            _isStopped = false;
                            timerValues.clear();
                            durumlar = ['off', 'off', 'off', 'off', 'off', 'off', 'off', 'off'];
                            sendDataToFirebase(durumlar);
                            choise_deger.clear();
                          });
                        },
                        child: Text('Reset Button', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      ElevatedButton(
                        onPressed: _showDelayMillis,
                        child: Text('Timer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
  }