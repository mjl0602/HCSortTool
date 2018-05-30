//
//  HCOrderDetailView.m
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/4/2.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import "HCOrderDetailView.h"
#import "UILabel+OVLabel.h"

#import "NetworkManager.h"
#import "Masonry.h"
@interface HCOrderDetailView()

@property(nonatomic)UILabel *title;

@property(nonatomic)UILabel *orderDetail;
@property(nonatomic)UILabel *goodDetail;
@property(nonatomic)UILabel *sortDetail;

@end

@implementation HCOrderDetailView


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _title = [UILabel grayLabelWithText:@"订单详情"];
        self.clipsToBounds = YES;
        [self addSubview:_title];
        [_title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(8);
            make.top.offset(4);
        }];
        
        _orderDetail = [UILabel new];
        _orderDetail.font = [UIFont systemFontOfSize:18];
        _orderDetail.text = @"流水号:--\n商户:--\n地址:*********";
        [_orderDetail setNumberOfLines:0];
        [self addSubview:_orderDetail];
        [_orderDetail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(30);
            make.top.offset(30);
        }];
        
        _goodDetail = [UILabel new];
        _goodDetail.font = [UIFont systemFontOfSize:18];
        _goodDetail.text = @"货物:-\n需求:-.--";
        [_goodDetail setNumberOfLines:0];
        [self addSubview:_goodDetail];
        [_goodDetail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_orderDetail.mas_right).offset(30);
            make.top.offset(30);
        }];
        
        _sortDetail = [UILabel new];
        _sortDetail.font = [UIFont systemFontOfSize:18];
        _sortDetail.text = @"分拣人:-\n配送路线:-";
        [_sortDetail setNumberOfLines:0];
        [self addSubview:_sortDetail];
        [_sortDetail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_goodDetail.mas_right).offset(30);
            make.top.offset(30);
        }];
        
    }
    return self;
}

-(void)loadDataWithFlowIndex:(NSString *)fIndex storeName:(NSString *)store address:(NSString *)address goodName:(NSString *)gName targetWeight:(NSString *)weight sortPath:(NSString *)sortPath sendPath:(NSString *)sendPath{
    if (_orderDetail&&_goodDetail&&_sortDetail) {
        _orderDetail.text = [NSString stringWithFormat:@"流水号:%@\n商户:%@\n地址:%@",fIndex,store,address];
        _goodDetail.text = [NSString stringWithFormat:@"货物:%@\n需求:%@",gName,weight];
        _sortDetail.text = [NSString stringWithFormat:@"分拣人:%@\n配送路线:%@",[NetworkManager shareManager].workerName,sendPath];
    }
    
    
    
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
