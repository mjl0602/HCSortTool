//
//  DeviceInfoView.m
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/4/8.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import "DeviceInfoView.h"
#import "UILabel+OVLabel.h"
#import "UIColor+OVColor.h"
#import "Masonry.h"
@interface DeviceInfoView()



@end

@implementation DeviceInfoView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _title = [UILabel grayLabelWithText:nil];
        [self addSubview:_title];
        
        _context = [UILabel new];
        _context.text = @"设备名称:\nUUID绑定:\n状态:";
        _context.font = [UIFont systemFontOfSize:16];
        [_context setNumberOfLines:0];
        _context.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_context];
        
        _buttonLeft = [UIButton buttonWithType:UIButtonTypeSystem];
        _buttonLeft.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_buttonLeft setTitle:@"左边按钮" forState:UIControlStateNormal];
        [self addSubview:_buttonLeft];
        
        _buttonRight = [UIButton buttonWithType:UIButtonTypeSystem];
        _buttonRight.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_buttonRight setTitle:@"右边按钮" forState:UIControlStateNormal];
        _buttonRight.tintColor = [UIColor ovRedColor];
        [self addSubview:_buttonRight];
        
        //约束
        [_title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(12);
            make.top.offset(2);
        }];
        [_context mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(38);
            make.left.offset(26);
            make.right.offset(-12);
            make.bottom.equalTo(_buttonLeft.mas_top).offset(-12);
        }];
        [_buttonLeft mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(26);
            make.bottom.offset(-8);
            make.height.offset(36);
            make.right.equalTo(self.mas_centerX).offset(-18);
        }];
        
        [_buttonRight mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.offset(-26);
            make.bottom.offset(-8);
            make.height.offset(36);
            make.left.equalTo(self.mas_centerX).offset(18);
        }];
    }
    return self;
}


-(void)setTextWithDeviceName:(NSString *)deviceName uuidBinding:(NSString *)uuid stateText:(NSString *)state{
    _context.text = [NSString stringWithFormat:@"设备名称:%@\nUUID绑定:%@\n状态:%@",deviceName,uuid,state];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
