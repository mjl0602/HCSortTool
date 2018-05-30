//
//  StandardPrintCollectionViewCell.h
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/5/17.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    HCCellTypeStandardGood,
    HCCellTypeStoreName
} HCCellType;

@interface StandardPrintCollectionViewCell : UICollectionViewCell


-(void)loadData:(NSString *)goodName url:(NSString *)imageUrl count:(NSInteger)number Type:(HCCellType)type;

@end
