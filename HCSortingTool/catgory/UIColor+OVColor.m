//
//  UIColor+OVColor.m
//  bleConductor
//
//  Created by 马嘉伦 on 2017/10/25.
//  Copyright © 2017年 马嘉伦. All rights reserved.
//

#import "UIColor+OVColor.h"

@implementation UIColor (OVColor)


+(UIColor *)backgroundGrayColor{
    return [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1.0];
}

+(UIColor *)defaultBorderColor{
    return [UIColor colorWithHexString:@"D8D8D8"];
    
}

+(UIColor *)textGrayColor{
    return [UIColor colorWithHexString:@"9B9B9B"];
}
+(UIColor *)ovLightGrayColor{
    return [UIColor colorWithHexString:@"F5F5F4"];
}
+(UIColor *)ovBlueColor{
    return [UIColor colorWithHexString:@"2A8DEC"];
}
+(UIColor *)ovRedColor{
    return [UIColor colorWithHexString:@"FE2851"];
}
+(UIColor *)ovPurpleColor{
    return [UIColor colorWithHexString:@"BD10E0"];
}
+(UIColor *)ovGreenColor{
    return [UIColor colorWithHexString:@"47CB38"];
}
+(UIColor *)ovDarkGreenColor{
    return [UIColor colorWithHexString:@"417505"];
}
+(UIColor *)ovDarkOrangeColor{
    return [UIColor colorWithHexString:@"F5A623"];
}
+(UIColor *)ovDarkRedColor{
    return [UIColor colorWithHexString:@"D0021B"];
}

#pragma mark - 工厂方法

+ (UIColor *)colorWithHexString:(NSString *)color
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:1];
}
@end
