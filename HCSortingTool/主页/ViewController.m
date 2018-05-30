//
//  ViewController.m
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/3/28.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import "ViewController.h"
#import "BLEManager.h"
#import "NetworkManager.h"
#import "Masonry.h"

#import "sortEntryView.h"
#import "terminalViewController.h"
#import "deviceManageViewController.h"
#import "loginViewController.h"
#import "standardPrinterCollectionViewController.h"
#import "scanCodeViewController.h"

#import "UIColor+OVColor.h"

#import <AudioToolbox/AudioToolbox.h>

@interface ViewController ()<UIPopoverPresentationControllerDelegate>

//顶部文字
@property(nonatomic)UILabel *bigTitleLabel;




//两个入口视图
@property(nonatomic)sortEntryView *sortCenterView;
@property(nonatomic)sortEntryView *deviceCenter;

//@property(nonatomic)loginViewController *lgVC;

@property(nonatomic)sortEntryView *uselessView;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor ovBlueColor];
    [self createUI];
    [self logInWithWorkerIndex];
    // Do any additional setup after loading the view, typically from a nib. 
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    AudioServicesPlaySystemSound(4122);
    NSString *name = [NetworkManager shareManager].workerName;
    if ([name isEqualToString:@"(null)"]|!name) {
        name = @"点击此处登陆";
    }
    
    

    NSString *helloWord = [NSString stringWithFormat:@"你好！%@",name];
    [_welcomeWord setTitle:helloWord forState:UIControlStateNormal];

}

-(void)logInWithWorkerIndex{
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"等待登录..."];
    
    [NetworkManager logInWithWorkerIndex:[NetworkManager shareManager].worker.integerValue
                           SortPathIndex:[NetworkManager shareManager].sortPath.integerValue
                                complete:^(NSDictionary *res) {
                                    
                                    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
                                    
                                    NSNumber *errCode = [res objectForKey:@"code"];
                                    if (errCode.integerValue == 0) {
                                        //登陆成功，查询任务
                                        [NetworkManager queryMission:^(NSDictionary *res) {
                                            NSArray *missionArray = [res objectForKey:@"data"];
                                            NSString *msg = @"没有找到任务，请点击名字重试";
                                            if ([missionArray isKindOfClass:[NSArray class]]) {
                                                msg = [NSString stringWithFormat:@"登陆成功，查询到%ld个任务",missionArray.count];
                                            }else{
                                                NSLog(@"返回值错误");
                                            }
                                            [SVProgressHUD showSuccessWithStatus:msg];
                                            [self.welcomeWord setTitle:[NSString stringWithFormat:@"你好！%@",[NetworkManager shareManager].workerName]  forState:UIControlStateNormal];
                                            NSLog(@"------%@",res);
                                        }];
                                    }else{
                                        [SVProgressHUD showErrorWithStatus:[res objectForKey:@"msg"]];
                                        NSLog(@"%@",[res objectForKey:@"msg"]);
                                    }
                                }];
}


-(void)createUI{
    _bigTitleLabel = [UILabel new];
    _bigTitleLabel.font = [UIFont systemFontOfSize:32 weight:UIFontWeightMedium];
    _bigTitleLabel.text = @"深圳市海辰配送有限公司";
    _bigTitleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_bigTitleLabel];
    [_bigTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(24);
        make.top.offset(38);
    }];
    
    
    _welcomeWord = [UIButton buttonWithType:UIButtonTypeSystem];
    [_welcomeWord setTitle:@"你好！马嘉伦" forState:UIControlStateNormal];
    _welcomeWord.titleLabel.font = [UIFont systemFontOfSize:32 weight:UIFontWeightRegular];
    //_welcomeWord.font = [UIFont systemFontOfSize:32 weight:UIFontWeightRegular];
    //_welcomeWord.text = @"你好！马嘉伦";
    [_welcomeWord addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    _welcomeWord.tintColor = [UIColor whiteColor];
    [self.view addSubview:_welcomeWord];
    [_welcomeWord mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-24);
        make.top.equalTo(_bigTitleLabel);
    }];
    
    _sortCenterView = [sortEntryView new];
    _sortCenterView.mainText.text = @"分拣中心";
    [_sortCenterView.imageView setImage:[UIImage imageNamed:@"logo.png"]];
    [self.view addSubview:_sortCenterView];
    [_sortCenterView addTarget:self action:@selector(toSortCenter:) forControlEvents:UIControlEventTouchUpInside];
    [_sortCenterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bigTitleLabel.mas_bottom).offset(24);
        make.left.equalTo(_bigTitleLabel);
        make.width.equalTo(self.view.mas_width).multipliedBy(630/1024.0);
        make.height.offset(480);
        //make.height.equalTo(_sortCenterView.mas_width).multipliedBy(480/630.0);
    }];
    
    _deviceCenter = [sortEntryView new];
    _deviceCenter.mainText.text = @"设备管理";
    [_deviceCenter.imageView setImage:[UIImage imageNamed:@"很吊的机械.png"]];
    [self.view addSubview:_deviceCenter];
    [_deviceCenter addTarget:self action:@selector(toDeviceCenter:) forControlEvents:UIControlEventTouchUpInside];
    [_deviceCenter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_sortCenterView);
        make.left.equalTo(_sortCenterView.mas_right).offset(24);
        make.right.equalTo(_welcomeWord);
        make.bottom.equalTo(_sortCenterView);
    }];
    
    _uselessView = [sortEntryView new];
    _uselessView.mainText.text = @"标品打印";
    //_uselessView.backgroundColor = [UIColor whiteColor];
    [_uselessView addTarget:self action:@selector(toStandPrinterCenter:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_uselessView];
    [_uselessView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_sortCenterView.mas_bottom).offset(24);
        make.left.offset(24);
        make.right.bottom.offset(-24);
    }];
    
}



-(IBAction)login:(id)sender{
    UIButton *button = (UIButton *)sender;
    loginViewController *lgVC= [[loginViewController alloc]init];
    lgVC.superVC = self;
    lgVC.modalPresentationStyle = UIModalPresentationPopover;
    lgVC.popoverPresentationController.sourceView = button;  //rect参数是以view的左上角为坐标原点（0，0）
    lgVC.popoverPresentationController.sourceRect = button.bounds; //指定箭头所指区域的矩形框范围（位置和尺寸），以view的左上角为坐标原点
    lgVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp; //箭头方向
    lgVC.popoverPresentationController.delegate = self;
    //lgVC.delegate = self;
    [self presentViewController:lgVC animated:YES completion:nil];
    
}


- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    return YES;   //点击蒙版popover不消失， 默认yes
}


-(void)toSortCenter:(id)sender{
    NSLog(@"to sort view");
     UINavigationController *naVC = [[UINavigationController alloc]initWithRootViewController:[terminalViewController new]];
    
    [self presentViewController:naVC animated:YES completion:nil];
}

-(void)toDeviceCenter:(id)sender{
    //设备管理
    NSLog(@"to device view");
    UINavigationController *naVC = [[UINavigationController alloc]initWithRootViewController:[deviceManageViewController new]];

    [self presentViewController:naVC animated:YES completion:nil];
}

-(void)toStandPrinterCenter:(id)sender{
    
    NSLog(@"to Stand Printer Center");
    UINavigationController *spVC = [[UINavigationController alloc]initWithRootViewController:
                                    [
                                     [standardPrinterCollectionViewController alloc]initWithCollectionViewLayout:
                                     [UICollectionViewFlowLayout new]
                                     ]
                                    ];

    [self presentViewController:spVC animated:YES completion:nil];
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
