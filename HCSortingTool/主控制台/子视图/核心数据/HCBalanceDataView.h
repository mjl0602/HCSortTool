//
//  HCBalanceDataVIew.h
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/4/2.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "balanceView.h"
#import "HCOrderDetailView.h"


@protocol balanceDataDelegate<NSObject>
//按钮动作，弹出视图
-(void)pressButton:(NSString *)msg;
//完成任务
-(void)completeMissionAndNeedNextMission:(NSInteger)fNumber weight:(CGFloat)weight complete:(void (^)(NSDictionary *res))success;
//货物被拿走
-(void)goodsRemoved;

@end

@interface HCBalanceDataView : UIView

@property(nonatomic)balanceView *balance;
//测试页
@property(nonatomic)UIButton *printTestPageButton;
//蓝牙操作
@property(nonatomic)UIButton *bleReconnectButton;
//弹出view
@property(nonatomic)id<balanceDataDelegate> delegate;
//菜品名，重量 和 车号
@property(nonatomic)UIButton *missionNow;
@property(nonatomic)UILabel *carIndex;

///展示日期，工作姓名 
-(void)showInfoWithleftNumber:(NSString *)leftNumber;
-(void)addSortCount;

///展示商品名，目标重量，车号
-(void)setGoodName:(NSString *)goodName
      TargetWeight:(NSString *)targetWeight
       vehicleName:(NSString *)vehicle;

///展示紫色任务
-(void)setRemakeMissionWithGoodName:(NSString *)goodName
                        TargetWeight:(NSString *)targetWeight
                         vehicleName:(NSString *)vehicle;

//设置一个任务的目标重量，流水号
-(void)setTargetWeight:(CGFloat)weight flowNumber:(NSInteger)fNumber;





@end
