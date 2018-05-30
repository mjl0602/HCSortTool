//
//  HCBalanceHistoryView.h
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/4/2.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HCBalanceHistoryDelegate<NSObject>


-(void)historyViewDidSelectButtonWithFlowNumber:(NSInteger)f_number;

-(void)historyViewDidSelectCellWithFlowNumber:(NSInteger)f_number;

@end

@interface HCBalanceHistoryView : UIView

@property(nonatomic)id<HCBalanceHistoryDelegate> delegate;

- (void)insertNewCellWith:(NSString *)flowNumber weight:(NSString *)weight name:(NSString *)name GoodsName:(NSString *)goodsName;




@end
