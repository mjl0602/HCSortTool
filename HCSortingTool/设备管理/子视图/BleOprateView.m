//
//  BleOprateView.m
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/4/8.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import "BleOprateView.h"
#import "UILabel+OVLabel.h"
#import "UIColor+OVColor.h"
#import "Masonry.h"
@implementation BleOprateView


- (instancetype)init
{
    self = [super init];
    if (self) {
        _title = [UILabel grayLabelWithText:@"蓝牙中心"];
        [_title setNumberOfLines:1];
        [self addSubview:_title];
        
        _buttonBig = [UIButton buttonWithType:UIButtonTypeSystem];
        _buttonBig.titleLabel.adjustsFontSizeToFitWidth = YES;
        _buttonBig.backgroundColor = [UIColor ovLightGrayColor];
        _buttonBig.layer.cornerRadius = 12;
        _buttonBig.layer.masksToBounds = YES;
        [_buttonBig setTitle:@"大按钮" forState:UIControlStateNormal];
        [self addSubview:_buttonBig];
        
        _buttonButtom = [UIButton buttonWithType:UIButtonTypeSystem];
        _buttonButtom.titleLabel.adjustsFontSizeToFitWidth = YES;
        _buttonButtom.layer.cornerRadius = 12;
        _buttonButtom.layer.masksToBounds = YES;
        _buttonButtom.tintColor = [UIColor ovRedColor];
        _buttonButtom.backgroundColor = [UIColor ovLightGrayColor];
        [_buttonButtom setTitle:@"小按钮" forState:UIControlStateNormal];
        [self addSubview:_buttonButtom];
        
        //约束
        [_title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(12);
            make.top.offset(2);
        }];
        
        [_buttonBig mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(12);
            make.right.offset(-12);
            make.top.offset(36);
            make.bottom.equalTo(_buttonButtom.mas_top).offset(-8);
        }];
        
        [_buttonButtom mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(12);
            make.right.offset(-12);
            make.bottom.offset(-12);
            make.height.offset(64);
        }];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
