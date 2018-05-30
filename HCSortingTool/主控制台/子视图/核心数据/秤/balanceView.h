//
//  balanceView.h
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/3/30.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEManager.h"
#import "UICountingLabel.h"
#import "Masonry.h"
#import "UIColor+OVColor.h"


@protocol balanceDelegate<NSObject>

-(void)didCompleteMission:(CGFloat)weight;

-(void)missionCancel;

-(void)goodsDidRemoved;
@end

@interface balanceView : UIView

@property(nonatomic)id<balanceDelegate> delegate;
//目标重量
@property(nonatomic,assign)CGFloat targetNumber;
@property(nonatomic,readonly,assign)CGFloat realNumber;

//展示一个重量数据
-(void)showWithRealNumber:(CGFloat)realNumber;

@end
