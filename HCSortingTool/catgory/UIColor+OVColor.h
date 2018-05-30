//
//  UIColor+OVColor.h
//  bleConductor
//
//  Created by 马嘉伦 on 2017/10/25.
//  Copyright © 2017年 马嘉伦. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIColor (OVColor)


+(UIColor *)backgroundGrayColor;
+(UIColor *)textGrayColor;
+(UIColor *)defaultBorderColor;

+(UIColor *)ovBlueColor;
+(UIColor *)ovRedColor;
+(UIColor *)ovPurpleColor;
+(UIColor *)ovGreenColor;

+(UIColor *)ovLightGrayColor;
+(UIColor *)ovDarkGreenColor;
+(UIColor *)ovDarkOrangeColor;
+(UIColor *)ovDarkRedColor;






+ (UIColor *)colorWithHexString:(NSString *)color;
@end
