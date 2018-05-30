//
//  StandardPrintCollectionViewCell.m
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/5/17.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import "StandardPrintCollectionViewCell.h"
#import "NetworkManager.h"
#import "UIImageView+WebCache.h"
@implementation StandardPrintCollectionViewCell

-(void)loadData:(NSString *)goodName url:(NSString *)imageUrl count:(NSInteger)number Type:(HCCellType)type{
    
    if (type == HCCellTypeStandardGood) {
        NSLog(@"初始化新cell");
        self.layer.shadowOffset = CGSizeMake(1, 1);
        self.layer.shadowOpacity = 0.8;
        self.layer.shadowColor = [UIColor defaultBorderColor].CGColor;
        // Cell background
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.masksToBounds = YES;
        self.contentView.layer.cornerRadius = 12;
        
        UIImageView *image = [UIImageView new];
        //image.backgroundColor = [UIColor ovLightGrayColor];
        image.contentMode = UIViewContentModeScaleAspectFit;
        
        
        [self.contentView addSubview:image];
        
        UILabel *name = [UILabel new];
        name.textAlignment = NSTextAlignmentCenter;
        name.font = [UIFont systemFontOfSize:24];
        name.textColor = [UIColor blackColor];
        
        name.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:name];
        
        UILabel *count = [UILabel new];
        count.textAlignment = NSTextAlignmentCenter;
        count.textColor = [UIColor textGrayColor];
        count.font = [UIFont systemFontOfSize:16];
        
        count.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:count];
        
        [image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.size.mas_offset(CGSizeMake(120, 120));
            make.bottom.equalTo(name.mas_top);
        }];
        
        [name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.offset(0);
            make.bottom.equalTo(count.mas_top);
        }];
        
        [count mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.offset(0);
            make.bottom.offset(0);
        }];
        
        //录入数据
        name.text = goodName;
        [image sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
        count.text = [NSString stringWithFormat:@"数量：%ld",(long)number];
    }else if (type == HCCellTypeStoreName){
        NSLog(@"初始化新cell");
        self.layer.shadowOffset = CGSizeMake(1, 1);
        self.layer.shadowOpacity = 0.8;
        self.layer.shadowColor = [UIColor defaultBorderColor].CGColor;
        // Cell background
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.masksToBounds = YES;
        self.contentView.layer.cornerRadius = 12;
        
        UILabel *name = [UILabel new];
        name.textAlignment = NSTextAlignmentCenter;
        name.font = [UIFont systemFontOfSize:24];
        name.textColor = [UIColor blackColor];
        
        name.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:name];
        
        UILabel *count = [UILabel new];
        count.textAlignment = NSTextAlignmentCenter;
        count.textColor = [UIColor textGrayColor];
        count.font = [UIFont systemFontOfSize:16];
        
        count.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:count];
        
        
        [name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.offset(0);
            make.bottom.equalTo(count.mas_top);
        }];
        
        [count mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.offset(0);
            make.bottom.offset(-48);
        }];
        
        //录入数据
        name.text = goodName;
        count.text = [NSString stringWithFormat:@"总价格：%@",imageUrl];
        
    }

   
}



@end
