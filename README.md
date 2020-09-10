# flutter_ble_mannager
Flutter 插件 flutter_blue 的二次封装，以便简洁调用

### 添加flutter_blue库
```
//文件名：pubspec.yaml
    flutter_blue: ^0.7.2
```

### 添加蓝牙权限
Android 端权限添加：
```
//文件名：AndroidManifest.xml
        <uses-permission android:name="android.permission.BLUETOOTH"/>
        <uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
```

iOS 端权限添加：
```
//文件名：Info.plist
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>App需要您的同意,才能访问蓝牙,进行设备连接,数据通讯服务</string>
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>App需要您的同意,才能访问蓝牙,进行设备连接,数据通讯服务</string>
```

# 使用方法
## 1.初始化
initBle();

## 2.开始搜索蓝牙设备
startBle();

## 3.得到搜索到所有蓝牙设备名字数组(含名称过滤)
getBleScanNameAry

## 4.从名字数组里面选择对应的蓝牙设备进行连接，传入需要连接的设备名在数组的位置
(其实是假连接，停止扫描，准备好需要连接的蓝牙设备参数)
connectionBle(int chooseBle)

## 5.正式连接蓝牙，并且开始检索特征描述符，并匹配需要用到的特征描述符等
discoverServicesBle()

## 6.断开蓝牙连接
endBle()

## *写入数据  例子：dataCallsendBle([0x00, 0x00, 0x00, 0x00])
dataCallsendBle(List<int> value)

## *收到数据
dataCallbackBle()

### 更多帮助博客：https://www.jianshu.com/p/bab40d5ecdee
