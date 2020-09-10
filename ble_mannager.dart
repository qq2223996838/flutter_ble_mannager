/*
使用方法
配置好环境： 
Android/iOS 权限设置完毕
导入库 flutter_blue 

1.初始化
initBle();

2.开始搜索蓝牙设备
startBle();

3.得到搜索到所有蓝牙设备名字数组(含名称过滤/空名、错误名)
getBleScanNameAry

4.从名字数组里面选择对应的蓝牙设备进行连接，传入需要连接的设备名在数组的位置
(其实是假连接，停止扫描，准备好需要连接的蓝牙设备参数)
connectionBle(int chooseBle)

5.正式连接蓝牙，并且开始检索特征描述符，并匹配需要用到的特征描述符等
discoverServicesBle()

6.断开蓝牙连接
endBle()

*写入数据  例子：dataCallsendBle([0x00, 0x00, 0x00, 0x00])
dataCallsendBle(List<int> value)

*收到数据
dataCallbackBle()

更多帮助博客：https://www.jianshu.com/p/bab40d5ecdee
*/

import 'dart:math';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';

class ble_data_model {
  /*
  蓝牙参数demo
  */
  FlutterBlue flutterBlue;
  BluetoothDevice device;
  Map<String, ScanResult> scanResults;
  List allBleNameAry;
  BluetoothCharacteristic mCharacteristic;
}

//蓝牙数据模型
ble_data_model model = new ble_data_model();

void initBle() {
  BluetoothDevice device;
  Map<String, ScanResult> scanResults = new Map();
  List allBleNameAry = [];
  BluetoothCharacteristic mCharacteristic;

  model.flutterBlue = FlutterBlue.instance;
  model.device = device;
  model.scanResults = scanResults;
  model.allBleNameAry = allBleNameAry;
  model.mCharacteristic = mCharacteristic;
}

void startBle() async {
  // 开始扫描
  model.flutterBlue.startScan(timeout: Duration(seconds: 4));
  // 监听扫描结果
  model.flutterBlue.scanResults.listen((results) {
    // 扫描结果 可扫描到的所有蓝牙设备
    for (ScanResult r in results) {
      model.scanResults[r.device.name] = r;
      if (r.device.name.length > 0) {
        // print('${r.device.name} found! rssi: ${r.rssi}');
        model.allBleNameAry.add(r.device.name);
        getBleScanNameAry();
      }
    }
  });
}

List getBleScanNameAry() {
  //更新过滤蓝牙名字
  List distinctIds = model.allBleNameAry.toSet().toList();
  model.allBleNameAry = distinctIds;
  return model.allBleNameAry;
}

void connectionBle(int chooseBle) {
  for (var i = 0; i < model.allBleNameAry.length; i++) {
    bool isBleName = model.allBleNameAry[i].contains("bleName");
    if (isBleName) {
      ScanResult r = model.scanResults[model.allBleNameAry[i]];
      model.device = r.device;

      // 停止扫描
      model.flutterBlue.stopScan();

      discoverServicesBle();
    }
  }
}

void discoverServicesBle() async {
  print("连接上蓝牙设备...延迟连接");
  await model.device
      .connect(autoConnect: false, timeout: Duration(seconds: 10));
  List<BluetoothService> services = await model.device.discoverServices();
  services.forEach((service) {
    var value = service.uuid.toString();
    print("所有服务值 --- $value");
    if (service.uuid.toString().toUpperCase().substring(4, 8) == "FFF0") {
      List<BluetoothCharacteristic> characteristics = service.characteristics;
      characteristics.forEach((characteristic) {
        var valuex = characteristic.uuid.toString();
        print("所有特征值 --- $valuex");
        if (characteristic.uuid.toString() ==
            "0000fff1-0000-1000-8000-xxxxxxxx") {
          print("匹配到正确的特征值");
          model.mCharacteristic = characteristic;

          const timeout = const Duration(seconds: 30);
          Timer(timeout, () {
            dataCallbackBle();
          });
        }
      });
    }
    // do something with service
  });
}

dataCallsendBle(List<int> value) {
  model.mCharacteristic.write(value);
}

dataCallbackBle() async {
  await model.mCharacteristic.setNotifyValue(true);
  model.mCharacteristic.value.listen((value) {
    // do something with new value
    // print("我是蓝牙返回数据 - $value");
    if (value == null) {
      print("我是蓝牙返回数据 - 空！！");
      return;
    }
    List data = [];
    for (var i = 0; i < value.length; i++) {
      String dataStr = value[i].toRadixString(16);
      if (dataStr.length < 2) {
        dataStr = "0" + dataStr;
      }
      String dataEndStr = "0x" + dataStr;
      data.add(dataEndStr);
    }
    print("我是蓝牙返回数据 - $data");
  });
}

void endBle() {
  model.device.disconnect();
}
