//
//  DeviceInfoView.h
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/4/8.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceInfoView : UIView


@property(nonatomic)UILabel *title;
@property(nonatomic)UILabel *context;
@property(nonatomic)UIButton *buttonLeft;
@property(nonatomic)UIButton *buttonRight;


-(void)setTextWithDeviceName:(NSString *)deviceName uuidBinding:(NSString *)uuid stateText:(NSString *)state;

@end
