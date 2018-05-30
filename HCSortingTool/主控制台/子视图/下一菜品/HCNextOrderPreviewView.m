//
//  HCNextOrderPreviewView.m
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/4/2.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import "HCNextOrderPreviewView.h"
#import "UILabel+OVLabel.h"
#import "Masonry.h"

@interface HCNextOrderPreviewView(){
    
}

@property(nonatomic)UILabel *nextOrderLabel;



@property(nonatomic)UILabel *prepareLabel;


@end

@implementation HCNextOrderPreviewView


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _nextOrderLabel = [UILabel grayLabelWithText:@"下一分拣类目"];
        [self addSubview:_nextOrderLabel];
        
        _mainLabel = [UILabel new];
        _mainLabel.font = [UIFont systemFontOfSize:36];
        _mainLabel.textAlignment = NSTextAlignmentCenter;
        _mainLabel.adjustsFontSizeToFitWidth = YES;
        _mainLabel.text = @"---";
        [self addSubview:_mainLabel];
        
        _prepareLabel = [UILabel grayLabelWithText:@"请注意提前备货"];
        _prepareLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_prepareLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [_nextOrderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(6);
        make.top.offset(2);
    }];
  
    [_mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(-2);
        make.left.right.offset(0);
    }];
    
    [_prepareLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.bottom.offset(-4);
    }];
    
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end


