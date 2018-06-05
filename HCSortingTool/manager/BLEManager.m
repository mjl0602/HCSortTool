//
//  BLEManager.m
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/3/28.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import "BLEManager.h"
#import "NetworkManager.h"
#import "GprinterBluetooth.h"
#import "GprinterLabelCommand.h"

#define balanceName @"FAYA"
#define targetCharacteristicId @"-1E4D-4BD9-"
@interface BLEManager(){
    BabyBluetooth *baby;
}
///设备的CBPeripheral
@property(strong,nonatomic)CBPeripheral *myPeripheral;
///设备的CBCharacteristic
@property(strong,nonatomic)CBCharacteristic *myControlCharacteristic;

@property(strong,nonatomic)CBCharacteristic *myLoginCharacteristic;


@end

@implementation BLEManager

+(instancetype)shareManager{
    static BLEManager *a = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        a = [[self alloc] init];
    });
    return a;
}


-(void)tryConnectPrinter{
    baby = [BabyBluetooth shareBabyBluetooth];
    __weak typeof(self) weakSelf = self;
    
    __block BOOL hasConnectPrinter = false;
    
    [[GprinterBluetooth sharedInstance]isDisconnect:^(CBPeripheral *perpheral, NSError *error) {
        NSLog(@"打印机断开");
    }];
    
    //显示扫描
    [SVProgressHUD showWithStatus:@"请打开蓝牙设备，扫描中..."];
    [SVProgressHUD dismissWithDelay:60.0f];
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        if (peripheral.name) {
            NSLog(@"=====%@",peripheral.name);
        }
        
        
        NSString *printerUUID = [[NSUserDefaults standardUserDefaults]objectForKey:@"printer_uuid"];
        NSString *balanceUUID = [[NSUserDefaults standardUserDefaults]objectForKey:@"balance_uuid"];
        
        //确认uuid，如果没有绑定uuid，不需要确认
        if ( (printerUUID.length<8) | [printerUUID isEqualToString:peripheral.identifier.UUIDString] ) {
            
            if ([peripheral.name containsString:@"Printer"]) {
                //打印机内部调用
                [[GprinterBluetooth sharedInstance] connectPeripheral:peripheral completion:^(CBPeripheral *perpheral, NSError *error) {
                    
                    _printer = peripheral;
                    [[NSUserDefaults standardUserDefaults]setValue:peripheral.identifier.UUIDString forKey:@"printer_uuid"];
                    
                    hasConnectPrinter = true;
                    
                    if (self.noBalance) {
                        [SVProgressHUD showSuccessWithStatus:@"连接打印机成功"];
                        _noBalance = false;
                        [self->baby cancelScan];
                        return;
                    }else{
                        [SVProgressHUD showWithStatus:@"连接打印机成功,等待连接电子秤"];
                    }
                }];
            }
        }
        
        if ( (balanceUUID.length<8) | [balanceUUID isEqualToString:peripheral.identifier.UUIDString] ) {
            NSString *deviceName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
            if ([deviceName containsString:balanceName] && hasConnectPrinter) {
                NSLog(@"开始连接电子秤:%@",peripheral.name);
                _balance = peripheral;
                _myPeripheral = peripheral;
                [[NSUserDefaults standardUserDefaults]setValue:peripheral.identifier.UUIDString forKey:@"balance_uuid"];
                [weakSelf continueToConnect];
            }
        }
        
    }];
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:@[] discoverWithServices:nil discoverWithCharacteristics:nil];
    //先取消
    [baby cancelAllPeripheralsConnection];
    //开始扫描
    baby.scanForPeripherals().begin();
}


-(void)disconnectAllAndStopScan{
    [[GprinterBluetooth sharedInstance] cancelPeripheral:_printer];
    if (self.myControlCharacteristic) {
        [baby cancelNotify:self.myPeripheral characteristic:self.myControlCharacteristic];
    }
    [baby cancelScan];
    [baby cancelAllPeripheralsConnection];
}

-(void)disconnectAllAndReconnect{
    [self disconnectAllAndStopScan];
    [self tryConnectPrinter];
}

-(void)continueToConnect{
    NSLog(@"continueToConnect");
    
    [baby cancelScan];
    __weak typeof(self)weakSelf = self;
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [baby setBlockOnConnectedAtChannel:@"aaa" block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [[NSUserDefaults standardUserDefaults]setObject:peripheral.identifier.UUIDString forKey:@"device"];
        //[SVProgressHUD showInfoWithStatus:@"连接成功"];
    }];
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnectAtChannel:@"aaa" block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Connect fail"];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"Disconnect" object:nil];
    }];
    //设置设备断开连接的委托
    [baby setBlockOnDisconnectAtChannel:@"aaa" block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"！！电子秤断开！！"];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"Disconnect" object:nil];
    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:@"aaa" block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
        
        
        //找到characteristic
        if ([characteristics.UUID.UUIDString containsString:targetCharacteristicId]) {
            
            weakSelf.myControlCharacteristic = characteristics;
            [weakSelf setNotifyOfBalance];
        }
        
        if (error) {
//            [SVProgressHUD showWithStatus:@"连接电子秤服务失败！请重启app"];
            NSLog(@"==========error:%@",error);
            
        }
        
    }];
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@NO};
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@NO,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@NO,
                                     /*CBConnectPeripheralOptionNotifyOnNotificationKey:@YES*/};
    
    [baby setBabyOptionsAtChannel:@"aaa" scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
    //[baby AutoReconnect:self.myPeripheral];
    baby.having(self.myPeripheral).and.channel(@"aaa").then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
}


-(void)setNotifyOfBalance{
    [SVProgressHUD showSuccessWithStatus:@"连接电子秤成功"];
    
    [baby notify:self.myPeripheral characteristic:self.myControlCharacteristic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSString *targetStr = [[NSString alloc]initWithData:characteristics.value encoding:NSUTF8StringEncoding];
        
        NSArray *a = [targetStr componentsSeparatedByString:@"="];
        //NSLog(@"A:%@",a);
        if (a.count==2) {
            NSString *targetValue = [a objectAtIndex:0];
            //倒序字符串
            NSMutableString * reverseString = [NSMutableString string];
            for(int i = 0 ; i < targetValue.length; i ++){
                //倒序读取字符并且存到可变数组数组中
                unichar c = [targetValue characterAtIndex:targetValue.length- i -1];
                [reverseString appendFormat:@"%c",c];
            }
            targetValue = reverseString;
            NSLog(@"读取到重量:%@",targetValue);
            [[NSNotificationCenter defaultCenter]postNotificationName:@"balanceChange" object:targetValue];
        }
    }];
}


#pragma mark - 打印

-(void)printStoreName:(NSString *)name{
    GprinterLabelCommand *labelCommand = [[GprinterLabelCommand alloc]init];
    NSLog(@"打印商家名称");
    [labelCommand clearBuffer];
    //初始化
    [labelCommand setupForWidth:@"54" heigth:@"70" speed:SPEED1 density:DENSITY12 sensor:GAP vertical:@"2" offset:@"0"];
    //商户名与菜名
    if (name.length<7) {
        [labelCommand printerfontFormX:@"230" Y:@"60" fontName:SIMPLIFIED_CHINESE rotation:ROTATION_90 magnificationRateX:MUL_3 magnificationRateY:MUL_3 content:name];
    }else if(name.length < 15){
         [labelCommand printerfontFormX:@"230" Y:@"60" fontName:SIMPLIFIED_CHINESE rotation:ROTATION_90 magnificationRateX:MUL_2 magnificationRateY:MUL_2 content:name];
    }

    [labelCommand Bar:@"30" y:@"30" width:@"8" height:@"500"];
    [labelCommand Bar:@"42" y:@"30" width:@"4" height:@"500"];
    
    [labelCommand Bar:@"352" y:@"30" width:@"4" height:@"500"];
    [labelCommand Bar:@"360" y:@"30" width:@"8" height:@"500"];
    //数量
    [labelCommand printLabelWithNumberOfSets:@"1" copies:@"1"];
    [labelCommand Direction:@"0"];
    
    [[GprinterBluetooth sharedInstance]sendPrintData:labelCommand.sendData completion:^(CBPeripheral *connectPerpheral, BOOL completion, NSString *error) {
        NSLog(@"%@,%@:%@",[GprinterBluetooth sharedInstance].str, connectPerpheral.name,error);
    }];
    
}

-(void)printLabelWithStoreName:(NSString *)storeName GoodName:(NSString *)goodName GoodWeight:(NSString *)weight GoodsUnit:(NSString *)unit TranseferIndex:(NSInteger)tIndex StoreIndex:(NSInteger)sIndex Seiral:(NSString *)seiral worker:(NSString *)workerName{
    GprinterLabelCommand *labelCommand = [[GprinterLabelCommand alloc]init];
    workerName = [NetworkManager shareManager].workerName;
    if ([unit hasPrefix:@"1"]) {
        unit = [unit substringFromIndex:1];
    }
    
    if (!(storeName&&goodName&&weight&&unit&&tIndex&&sIndex&&seiral&&workerName)) {
        [SVProgressHUD showErrorWithStatus:@"打印信息有误"];
        return;
    }
    
    [NetworkManager uploadPrintEventwithStoreName:storeName GoodName:goodName GoodWeight:weight GoodsUnit:unit TranseferIndex:tIndex StoreIndex:sIndex Seiral:seiral worker:workerName];
    
    [labelCommand clearBuffer];
    //初始化
    [labelCommand setupForWidth:@"54" heigth:@"70" speed:SPEED1 density:DENSITY12 sensor:GAP vertical:@"2" offset:@"0"];
    //商户名与菜名
    if(goodName.length>5){
        [labelCommand printerfontFormX:@"34" Y:@"98" fontName:SIMPLIFIED_CHINESE rotation:ROTATION_0 magnificationRateX:MUL_1 magnificationRateY:MUL_1 content:goodName];
    }else{
        [labelCommand printerfontFormX:@"34" Y:@"90" fontName:SIMPLIFIED_CHINESE rotation:ROTATION_0 magnificationRateX:MUL_2 magnificationRateY:MUL_2 content:goodName];
    }
    
    [labelCommand printerfontFormX:@"34" Y:@"158" fontName:SIMPLIFIED_CHINESE rotation:ROTATION_0 magnificationRateX:MUL_1 magnificationRateY:MUL_1 content:storeName];
    
    //线路号，替换成字母
    NSString *abc = @"#ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    [labelCommand printerfontFormX: tIndex>9 ? @"234":@"266" Y:@"90" fontName:SIMPLIFIED_CHINESE rotation:ROTATION_0 magnificationRateX:MUL_2 magnificationRateY:MUL_2 content:[NSString stringWithFormat:@"【%@】",[abc substringWithRange:NSMakeRange(tIndex, 1)]]];
    

    //框号
    [labelCommand printerfontFormX: sIndex>9 ? @"284":@"314" Y:@"146" fontName:SIMPLIFIED_CHINESE rotation:ROTATION_0 magnificationRateX:MUL_2 magnificationRateY:MUL_2 content:[NSString stringWithFormat:@"%ld",(long)sIndex]];
    //重量
    [labelCommand printerfontFormX:@"44" Y:@"424" fontName:SIMPLIFIED_CHINESE rotation:ROTATION_0 magnificationRateX:MUL_2 magnificationRateY:MUL_2 content:[weight stringByAppendingString:unit]];
    //条码
    [labelCommand barcodeFromX:@"40" Y:@"226" barcodeType:CODE128 height:@"126" readable:ENABEL rotation:ROTATION_0 narrow:@"3.9" wide:@"50" code:seiral];
    
    //公司名称
    [labelCommand printerfontFormX:@"70" Y:@"20" fontName:SIMPLIFIED_CHINESE rotation:ROTATION_0 magnificationRateX:MUL_1 magnificationRateY:MUL_1 content:@"深圳市海辰配送有限公司"];
    
    //分拣人
    [labelCommand printerfontFormX:@"110" Y:@"512" fontName:SIMPLIFIED_CHINESE rotation:ROTATION_0 magnificationRateX:MUL_1 magnificationRateY:MUL_1 content:[NSString stringWithFormat:@"分拣人：%@",workerName]];
    
    //线条
    [labelCommand Box:@"10" y:@"60" xend:@"380" yend:@"500" thickness:@"2"];
    [labelCommand Bar:@"34" y:@"200" width:@"320" height:@"3"];
    [labelCommand Bar:@"34" y:@"400" width:@"320" height:@"3"];
    
    //数量
    [labelCommand printLabelWithNumberOfSets:@"1" copies:@"1"];
    [labelCommand Direction:@"0"];
    
    [[GprinterBluetooth sharedInstance]sendPrintData:labelCommand.sendData completion:^(CBPeripheral *connectPerpheral, BOOL completion, NSString *error) {
        NSLog(@"%@,%@:%@",[GprinterBluetooth sharedInstance].str, connectPerpheral.name,error);
    }];
}


-(void)printTestPage{
    [self printLabelWithStoreName:@"0000-测试商家" GoodName:@"测试商品" GoodWeight:@"123.45" GoodsUnit:@"斤" TranseferIndex:9 StoreIndex:1 Seiral:@"000012345678" worker:@"测试员"];

}

@end
