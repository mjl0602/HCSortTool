//
//  BLEManager.h
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/3/28.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "babyBluetooth.h"
#import "SVProgressHUD.h"



@interface BLEManager : NSObject


+(instancetype)shareManager;

@property(nonatomic)CBPeripheral *printer;
@property(nonatomic)CBPeripheral *balance;


//临时属性，设置为true时，下一次连接不会连上对应设备，然后失效
@property(nonatomic,assign)BOOL noPrinter;
@property(nonatomic,assign)BOOL noBalance;

//@property(nonatomic)balanceView *blView;

-(void)tryConnectPrinter;

-(void)disconnectAllAndStopScan;

-(void)disconnectAllAndReconnect;

-(void)printTestPage;

-(void)printStoreName:(NSString *)name;

-(void)printLabelWithStoreName:(NSString *)storeName
                      GoodName:(NSString *)goodName
                    GoodWeight:(NSString *)weight
                     GoodsUnit:(NSString *)unit
                TranseferIndex:(NSInteger)tIndex
                    StoreIndex:(NSInteger)sIndex
                        Seiral:(NSString *)seiral
                        worker:(NSString *)workerName;

@end
