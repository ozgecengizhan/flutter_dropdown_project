import 'dart:async';
import 'package:flutter/material.dart';
import 'firebase_functions.dart';
import 'global_variable.dart';


class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}


class MyAppState extends State<MyApp> {
    Widget buildDraggable(Color draggableColor) {      // INPUT,OUTPUT VE TIMER OLUŞTURUR
      return Draggable<Color>(
        data: draggableColor,
        feedback: Container(                           // Sürüklenirken oluşan kutu
          height: 100.0,
          width: 100.0,
          color: draggableColor.withOpacity(0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),          // Input,Output ve Timer kutuları arası boşluğu ayarlar
          child: Container( 
            width: 100.0,
            height: 100.0,
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
        onDraggableCanceled: (velocity, offset) {
          if (!isAnimating) {      
          }
        },
        onDragStarted: () async {                     // sürüklemeye başlanan anda 
          if (draggableColor == draggableColor_5) {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text(" Timer: (in millisecond)"),
                  content: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    maxLines: 1,
                  ),
                  actions: [
                    ElevatedButton(
                      child: const Text("Tamam"),
                      onPressed: () {
                        updateState().then((_) {
                          setState(() {
                            controller.text = '';
                          });
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
      bool showBorder = (isAnimating && borderStatus[index]) || (isStopped && borderStatus[index]);
      int istenenindex = borderStatus.indexOf(true);                                              
      currentIndexValue = index + 1; 
      targetAdimMap[index] = currentIndexValue;
      ioIndexList= choise_deger.values.toList();
      if (color == draggableColor_1 || color == draggableColor_2) {
            targetDurumMap[index] = onOffDegerleri[index];
      } else {
        targetDurumMap[index] = timerValues[index].toString() + " ms";
      }
      if(color == draggableColor_1 ){
        defaultSelectedValue = "I1";
      } else {
        defaultSelectedValue = "O5";
      }
      if (!choise_deger.containsKey(index)) {
      choise_deger[index] = defaultSelectedValue;
      }
      bool isInsideBorder = showBorder && isAnimating && borderStatus[index];
      if(isInsideBorder == true){
        print("şuan border içindesin,hoşgeldin. Border adım: " + istenenindex.toString()); 
      if(currentColor == draggableColor_2 )
        VeriGonder(ioIndexList[istenenindex], onOffDegerleri[istenenindex]);
      if(currentColor == draggableColor_1 )
        VeriAl();
    }
      return GestureDetector(
        onTap: () {
          onClick(index);
        },
        onLongPress:() {
          kutuyuSil(index);
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
                                  child: Text( targetAdimMap[index].toString() + ": " + targetDurumMap[index].toString(),
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


    Widget buildColorChangingContainer() {
      return Padding(
        padding: const EdgeInsets.only(top: 12),                              // Animasyon ekranının yukardan aşağı uzaklığı
        child: Builder(
          builder: (context) {
            Color displayColor = isStopped ? currentColor : Colors.grey;
            return AnimatedContainer(
              duration: const Duration(),
              color: isAnimating && !isStopped ? currentColor : displayColor,
              height: 150.0, //screen
              width: 300.0,
            );
          },
        ),
      );
    }


    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.green[200],
          appBar: AppBar(title: const Text("Draggable Tutorial"),
          actions: [
            ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("KULLANMA KILAVUZU"),
                                content: Text(infoText),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Tamam"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Icon(Icons.info),
                        style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(5),
                        shape: CircleBorder(),
                        ),
                      ),
          ]),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                buildColorChangingContainer(),           // En üstte animasyon ekranı 
                const SizedBox(height: 10.0),            // Animasyon ekranı ile input,output,timer kutularının mesafesi
                SizedBox(
                  height: 100.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[                  // INPUT,OUTPUT,TIMER 
                      buildDraggable(draggableColor_1),
                      buildDraggable(draggableColor_2),
                      buildDraggable(draggableColor_5),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                DragTarget<Color>(
                  builder: (BuildContext context, List<Color?> candidateData, List<dynamic> rejectedData) {
                    Color displayColor = Colors.grey;
                    if (candidateData.isNotEmpty) {
                      displayColor = candidateData[0]!;
                    }
                    return Container(                                                               // gri boş target 
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
                      currentColor = data;
                      borderStatus = List<bool>.filled(targetColors.length, false);
                      borderStatus[targetColors.length - 1] = true;
                      timerValues.add(0);                                                            // timer fonksiyonundan input ve outputu ayrıştırmak için 
                      onOffDegerleri.add("off");               
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
                        onPressed: isStartButtonDisabled ? null : () { // start butonun görünürlüğünü
                          setState(() {
                            isStartButtonDisabled = true;
                            start = true;
                            isAnimating = true;
                            isStopped = false;
                            currentColorIndex = stopCurrentColorIndex ;
                          });
                          startAnimation();
                        },
                        child: Text('Start', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            start = false;
                            isAnimating = false;
                            isStopped = true;
                            stopCurrentColorIndex = currentColorIndex;
                            isStartButtonDisabled = false;
                          });
                        },
                        child: Text('Stop', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            start = false;
                            isAnimating = false;
                            isStopped = false;
                            targetColors.clear();
                            timerValues.clear();
                            choise_deger.clear();
                            targetDurumMap.clear();
                            onOffDegerleri.clear();
                            ioIndexList.clear();
                            currentColorIndex = 0;
                            stopCurrentColorIndex = 0;
                            isStartButtonDisabled = false;
                            delayMillisController.clear();
                            saniye = 1 ;
                            VeriSifirla();
                          });
                        },
                        child: Text('Delete', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isAnimating = false;
                          stopCurrentColorIndex = 0;
                          currentColor = targetColors.isNotEmpty ? targetColors[0] : Colors.grey;
                          borderStatus = List<bool>.filled(targetColors.length, false);
                          isStartButtonDisabled = false;
                          VeriSifirla();
                        });
                      },
                      child: Text('Restart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    ElevatedButton(
                        onPressed: () {
                          if(!isAnimating){
                            oneCycleAnimation();
                          }
                        },
                        child: Text('One Cycle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      // ElevatedButton(
                      //   onPressed:() {
                      //     if(!isAnimating){
                      //       stepForwardAnimation();
                      //       VeriSifirla();
                      //     }
                      //   },
                      //    child: Text('Step Forward', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      //   ),
                        // ElevatedButton(
                        // onPressed:() {
                        //   if(!isAnimating){
                        //     backStepAnimation();
                        //   }
                        // },
                        //  child: Text('Back Step', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        // ),
                        ElevatedButton(
                        onPressed: showDelayMillis,
                        child: Text('Cycle Speed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                ],)
                ),
              ],
            ),
          ),
        ),
      );
    }


/////////////////////////////////////////////// FUNCTIONS ///////////////////////////////////////////////// 


void onClick(int index) {
  setState(() {
    if (targetColors[index] == draggableColor_1 || targetColors[index] == draggableColor_2) {
      if (onOffDegerleri[index] == "off") {
        onOffDegerleri[index] = "on";
      } else {
        onOffDegerleri[index] = "off";
      }
      targetDurumMap[index] = onOffDegerleri[index];
    } else if (targetColors[index] == draggableColor_5) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Change Timer: (in milliseconds)"),
            content: TextField(
              controller: millisecondController,
              keyboardType: TextInputType.number,
              autofocus: true,
              maxLines: 1,
            ),
            actions: [
              ElevatedButton(
                child: const Text("Ok"),
                onPressed: () {
                  int newMilliseconds = int.parse(millisecondController.text);
                  setState(() {
                    timerValues[index] = newMilliseconds;
                    millisecondController.text = '';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }
  });
}


  Future<void> updateState() async {
      targetColors.add(draggableColor_5);                    // eklenen kutuyu görsün ve border da sorun yaratmasın diye
      currentColor = draggableColor_5;
      borderStatus = List.filled(targetColors.length, false);
      borderStatus[targetColors.length - 1] = true;
      timerValues.add(int.parse(controller.text));
      onOffDegerleri.add("off");
      choise_deger.addAll({choise_deger.length: "Timer"});
    }


    Future<void> timerState() async {
      delayMillis = saniye*1000;
    }


    void showDelayMillis() {                                 // cycle speed
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Please enter the cycle speed : (in second)"),
            content: TextField(
              controller: delayMillisController,
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
                      setState(() {
                        saniye = int.parse(delayMillisController.text);
                        delayMillisController.text = '';
                      });
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


    void kutuyuSil(int index) {
    setState(() {
    targetColors.removeAt(index);
    timerValues.removeAt(index);
    choise_deger.remove(index);
    targetDurumMap.remove(index);
    onOffDegerleri.remove(index);
    ioIndexList.remove(index);
  });
  }


void stepForwardAnimation() {
  if (!isAnimating) {  
    setState(() {
      isAnimating = true;  
      if (currentColorIndex < targetColors.length) {
        if (currentColor == Color(0xffffffff)) {
          Future.delayed(Duration(milliseconds: timerValues[currentColorIndex])).then((_) {
            setState(() {
              currentStepIndex++;
              if (currentColorIndex < targetColors.length) {
                currentColor = targetColors[currentColorIndex];
                borderStatus = List<bool>.filled(targetColors.length, false);
                borderStatus[currentColorIndex] = true;
                stepForwardAnimation();
              } else {
                isAnimating = false;
              }
            });
          });
        } else {
          currentColor = targetColors[currentColorIndex];
          borderStatus = List<bool>.filled(targetColors.length, false);
          borderStatus[currentColorIndex] = true;
        }
      } else {
        isAnimating = false;
      }
    });
  }
}


void backStepAnimation() {
  setState(() {
    if (currentColorIndex > 0) {
      currentColorIndex--; 
      currentColor = targetColors[currentColorIndex];
      borderStatus = List<bool>.filled(targetColors.length, false);
      borderStatus[currentColorIndex] = true;
    }

    if (currentColor == Color(0xffffffff)) {
      Future.delayed(Duration(milliseconds: timerValues[currentColorIndex])).then((_) {
        setState(() {
          stepForwardAnimation(); 
        });
      });
    }
  });
}


void oneCycleAnimation() {
  if (!isAnimating) {
    setState(() {
      isAnimating = true;
      if (dongude_start_kontrol) {
        currentColorIndex = 0;
        currentColor = targetColors.isNotEmpty ? targetColors[0] : Colors.grey;
        borderStatus = List<bool>.filled(targetColors.length, false);
        borderStatus[currentColorIndex] = true;
        dongude_start_kontrol = false;
      }
    });
    if (targetColors.isNotEmpty) {
      List<Color> targetColorsCopy = List<Color>.from(targetColors);
      void runAnimation(int index) async {
        if (!isAnimating) {
          return;
        }
        if (targetColorsCopy[index] == draggableColor_1) {
          int sira = int.parse(ioIndexList[index].substring(1)) - 1;
          if (onOff[sira] != onOffDegerleri[index]) {
            animasyonadevam = false;
          } else {
            animasyonadevam = true;
          }
        }
        setState(() {
          currentColorIndex = index;
          currentColor = targetColorsCopy[index];
          borderStatus = List<bool>.filled(targetColorsCopy.length, false);
          borderStatus[index] = true;
        });
        if (currentColor == Color(0xffffffff)) {
          await Future.delayed(Duration(milliseconds: timerValues[index]));
        }
        await Future.delayed(Duration(milliseconds: delayMillis));
        index = (index + 1) % targetColorsCopy.length;
        if (index == 0 && animasyonadevam) {
          setState(() {
            isAnimating = false;
          });
        } else {
          runAnimation(index);
        }
      }
      runAnimation(0); // sıfırıncı indeksten başlatır.
    }
  }
}


  Future<void> startAnimation() async {
  isAnimating = true;
  if (dongude_start_kontrol) {
    return;
  }
  if (isAnimating && targetColors.isNotEmpty) {
    List<Color> targetColorsCopy = List<Color>.from(targetColors);
    setState(() {
      currentColor = targetColorsCopy[0];
      currentColor = targetColorsCopy[stopCurrentColorIndex];
      borderStatus = List<bool>.filled(targetColorsCopy.length, false);
    });
    borderStatus[stopCurrentColorIndex] = true; // animasyonun durduğu yerden başlaması için
    while (isAnimating && targetColorsCopy.isNotEmpty) {
      await Future.delayed(Duration(milliseconds: delayMillis));
      if (!isAnimating) {
        break;
      }
      if (targetColorsCopy[currentColorIndex] == draggableColor_1) {
        int sira = int.parse(ioIndexList[currentColorIndex].substring(1))-1 ;
        if (onOff[sira] != onOffDegerleri[currentColorIndex]) {
          animasyonadevam = false ;
          VeriAl() ;
      }
      else{
        animasyonadevam = true ;
        VeriAl() ;
      }
      }
      if (animasyonadevam) {
        setState(() {
          currentColorIndex = (currentColorIndex + 1) % targetColorsCopy.length;
          currentColor = targetColorsCopy[currentColorIndex];
          borderStatus = List<bool>.filled(targetColorsCopy.length, false);
          borderStatus[currentColorIndex] = true;
        });

      if (isAnimating && targetColorsCopy.isNotEmpty) {
        await Future.delayed(Duration(milliseconds: int.parse(delayMillis.toString())));
      } else {
        delayMillis = 500;
      }
      if (currentColor == Color(0xffffffff)) {
        await Future.delayed(Duration(milliseconds: timerValues[currentColorIndex]));
      }
    }
  }
  dongude_start_kontrol = false;
  isAnimating = false;
}
}
}