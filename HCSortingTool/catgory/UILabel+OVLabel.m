//
//  UILabel+OVLabel.m
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/4/2.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import "UILabel+OVLabel.h"
#import "UIColor+OVColor.h"
@implementation UILabel (OVLabel)

//灰色的字
+(UILabel *)grayLabelWithText:(NSString *)text{
    UILabel *label = [UILabel new];
    if (text) {
        label.text = text;
    }
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor textGrayColor];
    return label;
}

/*
//黑色正文
-(UILabel *)mainTextLabelWithText:(NSString *)text{
    UILabel *label = [UILabel new];
    label.text = text;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor blackColor];
    return label;
}

*/



@end
