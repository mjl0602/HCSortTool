//
//  main.m
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/3/28.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <BmobSDK/Bmob.h>

int main(int argc, char * argv[]) {
    @autoreleasepool {
        NSString *appKey = @"6b43c6a35daba75b8548ad5e180eea00";
        [Bmob registerWithAppKey:appKey];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
