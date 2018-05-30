//
//  HCOrderDetailView.h
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/4/2.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface HCOrderDetailView : UIView

//显示数据
-(void)loadDataWithFlowIndex:(NSString *)fIndex
                   storeName:(NSString *)store
                     address:(NSString *)address
                    goodName:(NSString *)gName
                targetWeight:(NSString *)weight
                    sortPath:(NSString *)sortPath
                    sendPath:(NSString *)sendPath;

@end
