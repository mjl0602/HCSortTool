//
//  deviceManageViewController.m
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/4/3.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import "deviceManageViewController.h"
#import "BLEManager.h"
#import "Masonry.h"

#import "DeviceInfoView.h"
#import "BleOprateView.h"

#import "UIColor+OVColor.h"
#import "UILabel+OVLabel.h"

@interface deviceManageViewController (){
    BOOL onNotifyBalanceData;
}

@property(nonatomic)DeviceInfoView *printerInfoView;

@property(nonatomic)DeviceInfoView *balanceInfoView;

@property(nonatomic)BleOprateView *bleInfoView;


@property(nonatomic)UIView *terminalView;


@end

@implementation deviceManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor ovLightGrayColor];
    self.title = @"设备管理";
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss:)];
    
    //测试区
    _terminalView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"HalfSortMachine.png"]];
    _terminalView.backgroundColor = [UIColor whiteColor];
    _terminalView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_terminalView];
    [_terminalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-24);
        make.top.offset(36+65);
        make.bottom.offset(-36);
        make.width.offset(500);
    }];

    //打印机状态区
    _printerInfoView = [DeviceInfoView new];
    _printerInfoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_printerInfoView];
    _printerInfoView.title.text = @"打印机状态";
    [_printerInfoView.buttonLeft setTitle:@"打印测试页" forState:UIControlStateNormal];
    [_printerInfoView.buttonLeft addTarget:self action:@selector(printTestPage) forControlEvents:UIControlEventTouchUpInside];
    [_printerInfoView.buttonRight addTarget:self action:@selector(clearPrinterBinding) forControlEvents:UIControlEventTouchUpInside];
    [_printerInfoView.buttonRight setTitle:@"清除设备绑定" forState:UIControlStateNormal];
    [_printerInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(24);
        make.right.equalTo(_terminalView.mas_left).offset(-12);
        make.top.equalTo(_terminalView);
        make.height.equalTo(_terminalView).multipliedBy(0.25f);
    }];
    
    //秤状态区
    _balanceInfoView = [DeviceInfoView new];
    _balanceInfoView.backgroundColor = [UIColor whiteColor];
    _balanceInfoView.title.text = @"电子秤状态";
    [_balanceInfoView.buttonLeft setTitle:@"打开接收数据" forState:UIControlStateNormal];
    [_balanceInfoView.buttonRight setTitle:@"清除设备绑定" forState:UIControlStateNormal];
    [_balanceInfoView.buttonLeft addTarget:self action:@selector(balanceTestData) forControlEvents:UIControlEventTouchUpInside];
    [_balanceInfoView.buttonRight addTarget:self action:@selector(clearBalanceBinding) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_balanceInfoView];
    [_balanceInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_printerInfoView.mas_bottom).offset(12);
        make.left.height.width.equalTo(_printerInfoView);
    }];
    
    //蓝牙状态区
    _bleInfoView = [BleOprateView new];
    _bleInfoView.backgroundColor = [UIColor whiteColor];
    _bleInfoView.title.text = @"蓝牙中心";
    [_bleInfoView.buttonBig setTitle:@"连接设备" forState:UIControlStateNormal];
    [_bleInfoView.buttonBig addTarget:self action:@selector(connectDevices) forControlEvents:UIControlEventTouchUpInside];
    [_bleInfoView.buttonButtom setTitle:@"断开连接" forState:UIControlStateNormal];
    [_bleInfoView.buttonButtom addTarget:self action:@selector(disConnectAllDevice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_bleInfoView];
    [_bleInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_balanceInfoView.mas_bottom).offset(12);
        make.left.width.equalTo(_balanceInfoView);
        make.bottom.equalTo(_terminalView);
    }];
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [self refreshDeviceInfo];
}


#pragma mark - 打印机操作

-(void)printTestPage{
    //NSLog(@"尝试打印测试页");
    [[BLEManager shareManager]printTestPage];
}

-(void)clearPrinterBinding{
    
    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"printer_uuid"];
     [self refreshDeviceInfo];
}



#pragma mark - 电子秤操作
-(void)balanceTestData{
    NSLog(@"尝试打印测试页");
    
    [[BLEManager shareManager]printTestPage];
    
}

-(void)clearBalanceBinding{
    [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:@"balance_uuid"];
     [self refreshDeviceInfo];
}


#pragma mark - 蓝牙操作
-(void)connectDevices{
    if ([[BabyBluetooth shareBabyBluetooth]findConnectedPeripherals].count) {
        [self refreshDeviceInfo];
    }else{
        [[BLEManager shareManager]tryConnectPrinter];
    }
}

-(void)refreshDeviceInfo{
    //秤数据
   [_balanceInfoView setTextWithDeviceName:[BLEManager shareManager].balance.name
                               uuidBinding:[[NSUserDefaults standardUserDefaults]objectForKey:@"balance_uuid"]
                                 stateText:@""];
    //打印机数据
   [_printerInfoView setTextWithDeviceName:[BLEManager shareManager].printer.name
                               uuidBinding:[[NSUserDefaults standardUserDefaults]objectForKey:@"printer_uuid"]
                                 stateText:@""];
}

-(void)disConnectAllDevice{
    [[BLEManager shareManager]disconnectAllAndStopScan];
    [self refreshDeviceInfo];
    [SVProgressHUD showSuccessWithStatus:@"断开成功"];
}

#pragma mark - 退出页面
-(void)dismiss:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
