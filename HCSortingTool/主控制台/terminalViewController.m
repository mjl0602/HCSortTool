//
//  terminalViewController.m
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/4/2.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import "terminalViewController.h"
#import "BLEManager.h"
#import "Masonry.h"
#import "NetworkManager.h"

#import "NetworkManager.h"
#import "HCOrderDetailView.h"
#import "HCBalanceHistoryView.h"
#import "HCBalanceDataView.h"
#import "HCNextOrderPreviewView.h"

#import "scanCodeViewController.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "UIColor+OVColor.h"

@interface terminalViewController ()<balanceDataDelegate,HCBalanceHistoryDelegate,UIPopoverPresentationControllerDelegate>{
    NSDictionary *missionNow;
    //暂存的res,用于在拿走货物后刷新视图
    NSDictionary *resData;
    
    BOOL printed;
}

@property(nonatomic)HCBalanceDataView *mainView;
@property(nonatomic)HCNextOrderPreviewView *nextGood;
@property(nonatomic)HCOrderDetailView *orderDetail;
@property(nonatomic)HCBalanceHistoryView *historyView;

@end

@implementation terminalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    missionNow = @{
                   
                   };
    
    self.view.backgroundColor = [UIColor ovLightGrayColor];
    self.navigationController.navigationBar.barTintColor = [UIColor ovBlueColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.title = @"深圳海辰配送仓储货物分拣系统";
    
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismiss:)];
    
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(leftButtonClick:)];
    
    //[[BLEManager shareManager]tryConnectPrinter];
    //主视图
    _mainView = [HCBalanceDataView new];
    _mainView.delegate = self;
    _mainView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_mainView];
    
    //下一个的视图
    _nextGood = [HCNextOrderPreviewView new];
    _nextGood.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_nextGood];
    
    //订单详情
    _orderDetail = [HCOrderDetailView new];
    //_mainView.orderDetailView = _orderDetail;
    _orderDetail.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_orderDetail];
    
    //操作历史
    _historyView = [HCBalanceHistoryView new];
    _historyView.delegate =  self;
    _historyView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_historyView];
}


-(void)viewWillAppear:(BOOL)animated{
    //登陆
    //[NetworkManager logInWithWorkerIndex:1 SortPathIndex:1];
    if ([[BabyBluetooth shareBabyBluetooth]findConnectedPeripherals].count==0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"连接蓝牙" message:@"连接蓝牙设备后才能继续\n当前没有连接蓝牙设备，需要连接后继续吗？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *printPage = [UIAlertAction actionWithTitle:@"连接设备"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [[BLEManager shareManager]tryConnectPrinter];
                                                          }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"退出"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) {
                                                                 //[self dismiss:nil];
                                                             }];
        [alertController addAction:printPage];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    [self queryMissionData];
    
   
}

-(void)dealloc{
      [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - delegate

//按钮动作，弹出视图
-(void)pressButton:(NSString *)msg{
    NSLog(@"%@",msg);
    NSNumber *f = [missionNow objectForKey:@"serialnumber"];
    if ([msg isEqual: @"打印单据"]) {
        //直接打印当前数据
        [self completeMissionAndNeedNextMission:f.integerValue
                                         weight:_mainView.balance.realNumber
                                       complete:^(NSDictionary *res) {
                                          
                                         
                                               [SVProgressHUD showWithStatus:@"强制打印成功，请拿走货物"];
                                       
                                           //触发移走操作
                                           //[self goodsRemoved];
                                        }];
    }else if([msg isEqualToString:@"跳过任务"]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"强制跳过菜品" message:@"你可以选择跳过当前任务，或者跳过当前大类，除非后台手动分发，跳过的任务将不会再出现。" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *jumpOne = [UIAlertAction actionWithTitle:@"强制跳过当前任务"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              NSString *s = [NSString stringWithFormat:@"%@",[missionNow objectForKey:@"serialnumber"]];
                                                              //跳过任务
                                                              [NetworkManager passMissionWithFlowNumber:s.integerValue complete:^(NSDictionary *res) {
                                                                  resData = res;
                                                                  [_historyView insertNewCellWith:s
                                                                                           weight:@"被跳过"
                                                                                             name:[missionNow objectForKey:@"name"]
                                                                                        GoodsName:[missionNow objectForKey:@"goodsname"]];
                                                                  [self loadResData:res];
                                                              }];
                                                          }];
        UIAlertAction *jumpAll = [UIAlertAction actionWithTitle:@"跳过当前大类"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              NSString *s = [NSString stringWithFormat:@"%@",[missionNow objectForKey:@"serialnumber"]];
                                                              //跳过任务
                                                              [NetworkManager passAllMissionWithFlowNumber:s.integerValue complete:^(NSDictionary *res) {
                                                                  resData = res;
                                                                  [_historyView insertNewCellWith:s
                                                                                           weight:@"被跳过"
                                                                                             name:[missionNow objectForKey:@"name"]
                                                                                        GoodsName:[missionNow objectForKey:@"goodsname"]];
                                                                  [self loadResData:res];
                                                              }];
                                                          }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) {
                                                                 // do destructive stuff here
                                                             }];
        [alertController addAction:jumpOne];
        [alertController addAction:jumpAll];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

//查询所有任务
-(void)queryMissionData{
    [NetworkManager queryMission:^(NSDictionary *res) {
        resData = res;
        [self loadResData:res];
    }];
}

//完成任务
-(void)completeMissionAndNeedNextMission:(NSInteger)fNumber weight:(CGFloat)weight complete:(void (^)(NSDictionary *res))success{
    
    if(_mainView.balance.realNumber == 0){
        [SVProgressHUD showErrorWithStatus:@"强制打印时，必须放置货物"];
        return;
    }
    NSLog(@"任务完成");
    [NetworkManager completeWithNumber:weight flowNumber:fNumber complete:^(NSDictionary *res) {
        
//        NSLog(@"流水号%ld",fNumber);
//        NSLog(@"任务完成:%@",res);
        
        //打印单据
        [[BLEManager shareManager]printLabelWithStoreName:[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"name"]]
                                                 GoodName:[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"goodsname"]]
                                               GoodWeight:[NSString stringWithFormat:@"%.2f",weight]
                                                GoodsUnit:[missionNow objectForKey:@"goodsunit"]
                                           TranseferIndex:[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"xianluhao"]].integerValue
                                               StoreIndex:[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"kuanghao"]].integerValue
                                                   Seiral:[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"serialnumber"]]
                                                   worker:[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"sortername"]]
         ];
        
         AudioServicesPlaySystemSound(4122);
        

        [SVProgressHUD showWithStatus:@"打印成功，请拿走货物"];
        
        NSString *unitStr = [missionNow objectForKey:@"goodsunit"];
        if (!unitStr|[unitStr isEqualToString:@"(null)"]) {
            unitStr = @"";
        }
        NSLog(@"=======%@",unitStr);
        [_historyView insertNewCellWith:[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"serialnumber"]]
                                 weight:[NSString stringWithFormat:@"%.2f%@",weight,[NSString stringWithFormat:@"%@",unitStr]]
                                   name:[missionNow objectForKey:@"name"]
                              GoodsName:[missionNow objectForKey:@"goodsname"]];
        
        [_mainView addSortCount];

        printed = YES;
        
        //新任务
        resData = res;
        
        //回调
        if (success) {
            success(res);
        }
        
    }];
}

//货物被拿走
-(void)goodsRemoved{
    if (printed) {
        printed = NO;
        [SVProgressHUD dismiss];
        [self loadResData:resData];
    }
}

//加载任务号
-(void)showMissionWithFlowNumber:(NSInteger)f{
    [self historyViewDidSelectButtonWithFlowNumber:f];
}

///点击了任务列表的重做按钮
-(void)historyViewDidSelectButtonWithFlowNumber:(NSInteger)f_number{
    NSString *errMsg = [NSString stringWithFormat:@"重做任务：%ld",(long)f_number];
    [SVProgressHUD showSuccessWithStatus:errMsg];
    [NetworkManager queryOneMissionWithFlowNumber:[NSString stringWithFormat:@"%ld",(long)f_number] Complete:^(NSDictionary *res) {
        missionNow = [res objectForKey:@"data"];
        
        if (!missionNow) {
            [self errorFlowNumber:f_number];
            
            return;
        }
        
        
        //取出值
        NSString *goodName = [NSString stringWithFormat:@"%@",[missionNow objectForKey:@"goodsname"]];
        NSString *targetWeight = [NSString stringWithFormat:@"%@",[missionNow objectForKey:@"goodsnum"]];
        NSString *vehicleName = [NSString stringWithFormat:@"%@",[missionNow objectForKey:@"xianluhao"]];
        NSInteger fNumber =[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"serialnumber"]].integerValue;
        //主要任务区
        [_mainView setRemakeMissionWithGoodName:goodName TargetWeight:targetWeight vehicleName:vehicleName];
        
        [_mainView setTargetWeight:targetWeight.floatValue flowNumber:fNumber];
        
        [_orderDetail loadDataWithFlowIndex:[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"serialnumber"]]
                                  storeName:[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"name"]]
                                    address:@"***********"
                                   goodName:[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"goodsname"]]
                               targetWeight:[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"goodsnum"]]
                                   sortPath:[NSString stringWithFormat:@"%@",[NetworkManager shareManager].workerName]
                                   sendPath:[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"xianluhao"]]
         ];
        
        //[_mainView showInfoWithleftNumber:[NSString stringWithFormat:@"%ld",mission.count-1]];
        NSLog(@"===============queryOneMissionWithFlowNumber===");
    }];
}

//点击历史记录列表
-(void)historyViewDidSelectCellWithFlowNumber:(NSInteger)f_number{
    [NetworkManager queryOneMissionWithFlowNumber:[NSString stringWithFormat:@"%ld",(long)f_number] Complete:^(NSDictionary *res) {
        NSDictionary *missionShow = [res objectForKey:@"data"];
        
        if (!missionShow) {
            [self errorFlowNumber:f_number];
            return;
        }
        
        NSString *detailStr = [NSString stringWithFormat:@"流水号：%@\n商家名：%@\n菜品名：%@\n需求量：%@",[NSString stringWithFormat:@"%@",[missionShow objectForKey:@"serialnumber"]],
                               [NSString stringWithFormat:@"%@",[missionShow objectForKey:@"name"]],
                               [NSString stringWithFormat:@"%@",[missionShow objectForKey:@"goodsname"]],
                               [NSString stringWithFormat:@"%@",[missionShow objectForKey:@"goodsnum"]]
                               ];
        [SVProgressHUD showInfoWithStatus:detailStr];
    }];
}
-(void)errorFlowNumber:(NSInteger)f{
    NSString *msg = [NSString stringWithFormat:@"没有找到对应任务:\n%ld",(long)f];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"任务号异常" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
                                                   [self queryMissionData];
                                               }];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}

//加载最新任务
-(void)loadResData:(NSDictionary *)res{
    NSLog(@"=====%@",res);
    
    NSArray *missionArray = [res objectForKey:@"data"];
    if (![missionArray isKindOfClass:[NSArray class]]) {
        missionArray = @[];
    }
    
    //没有任务
    if (missionArray.count == 0) {
        [SVProgressHUD showSuccessWithStatus:@"没有任务了"];
        [_orderDetail loadDataWithFlowIndex:@""
                                  storeName:@""
                                    address:@"***********"
                                   goodName:@""
                               targetWeight:@""
                                   sortPath:@""
                                   sendPath:@""
         ];
        [_mainView setGoodName:@"没有任务了" TargetWeight:@"0" vehicleName:@"-"];
        [_mainView setTargetWeight:0 flowNumber:0];
        return;
    }
    
    NSArray *mission = [missionArray[0] objectForKey:@"data"];
    if (missionArray.count>1) {
        NSArray *nextMissions = [missionArray[1] objectForKey:@"data"];
        _nextGood.mainLabel.text = [nextMissions.firstObject objectForKey:@"goodsname"];
    }else{
        _nextGood.mainLabel.text = @"---";
    }
    
    //取出当前任务
    missionNow = mission.firstObject;
    
    //取出值
    NSString *goodName = [NSString stringWithFormat:@"%@",[missionNow objectForKey:@"goodsname"]];
    NSString *targetWeight = [NSString stringWithFormat:@"%@",[missionNow objectForKey:@"goodsnum"]];
    NSString *vehicleName = [NSString stringWithFormat:@"%@",[missionNow objectForKey:@"xianluhao"]];
    NSInteger fNumber =[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"serialnumber"]].integerValue;
    //主要任务区
    [_mainView setGoodName:goodName TargetWeight:targetWeight vehicleName:vehicleName];
    
    [_mainView setTargetWeight:targetWeight.floatValue flowNumber:fNumber];
    
    [_orderDetail loadDataWithFlowIndex:[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"serialnumber"]]
                              storeName:[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"name"]]
                                address:@"***********"
                               goodName:[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"goodsname"]]
                           targetWeight:[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"goodsnum"]]
                               sortPath:[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"sortername"]]
                               sendPath:[NSString stringWithFormat:@"%@",[missionNow objectForKey:@"xianluhao"]]
     ];
    
    [_mainView showInfoWithleftNumber:[NSString stringWithFormat:@"%ld",(long)mission.count-1]];
    
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    //主视图
    [_mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(76);
        make.left.offset(12);
        make.right.equalTo(_historyView.mas_left).offset(-12);
        make.bottom.equalTo(_nextGood.mas_top).offset(-12);
    }];
    
    //历史
    [_historyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(0);
        make.top.equalTo(_mainView);
        make.bottom.offset(0);
        make.width.offset(200);
    }];
    
    //订单详情
    [_orderDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_nextGood.mas_right).offset(12);
        make.right.equalTo(_historyView.mas_left).offset(-12);
        make.top.equalTo(_nextGood);
        make.bottom.offset(0);
    }];
    
    //下一个商品
    [_nextGood mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(12);
        make.bottom.offset(0);
        make.height.offset(108);
        make.width.offset(220);
    }];
}

-(void)dismiss:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}

-(void)leftButtonClick:(id)sender{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"蓝牙操作" message:@"蓝牙出现问题，或硬件异常时，可选择以下操作：" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *loadNewMission = [UIAlertAction actionWithTitle:@"通过流水号重做任务"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            [self loadMissionWithMissionNumber];
                                                        }];
    UIAlertAction *refreshPage = [UIAlertAction actionWithTitle:@"刷新任务"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [self queryMissionData];
                                                      }];
    UIAlertAction *printPage = [UIAlertAction actionWithTitle:@"打印测试页"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            // do something here
                                                            [[BLEManager shareManager]printTestPage];
                                                        }];
    UIAlertAction *reconnectAction = [UIAlertAction actionWithTitle:@"重置蓝牙连接"
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction *action) {
                                                              [[BLEManager shareManager]disconnectAllAndReconnect];
                                                              // do destructive stuff here
                                                          }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                              style:UIAlertActionStyleCancel
                                                            handler:^(UIAlertAction *action) {
                                                                // do destructive stuff here
                                                            }];
    [alertController addAction:loadNewMission];
    [alertController addAction:refreshPage];
    [alertController addAction:printPage];
    [alertController addAction:reconnectAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)loadMissionWithMissionNumber{
    /*
    //弹窗
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"输入单号" message:@"请输入任务流水号" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"输入流水号";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"%ld",alertController.textFields.lastObject.text.integerValue);
        [self historyViewDidSelectButtonWithFlowNumber:alertController.textFields.lastObject.text.integerValue];
    }];
    [alertController addAction:action1];
    [self presentViewController:alertController animated:YES completion:nil];
    return;
    
    */
    scanCodeViewController *scVC = [scanCodeViewController new];
    scVC.modalPresentationStyle = UIModalPresentationPopover;
    scVC.popoverPresentationController.sourceView = _orderDetail;  //rect参数是以view的左上角为坐标原点（0，0）
    scVC.popoverPresentationController.sourceRect = _orderDetail.bounds; //指定箭头所指区域的矩形框范围（位置和尺寸），以view的左上角为坐标原点
    scVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown; //箭头方向
    scVC.popoverPresentationController.delegate = self;
    scVC.parentVC = self;
    [self presentViewController:scVC animated:YES completion:nil];
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    return YES;   //点击蒙版popover不消失， 默认yes
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
