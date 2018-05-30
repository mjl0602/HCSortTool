//
//  HCBalanceDataVIew.m
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/4/2.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import "HCBalanceDataView.h"

#import "NetworkManager.h"
#import "UIColor+OVColor.h"
#import "UILabel+OVLabel.h"
#import "Masonry.h"


@interface HCBalanceDataView()<balanceDelegate>

///订单流水号
@property(nonatomic,assign)NSInteger missionFlowNumber;


@property(nonatomic)UIView *lineView;

//重量与任务
@property(nonatomic)UIView *balanceViewBackground;

//描述文字
@property(nonatomic)UILabel *missionNowText;
@property(nonatomic)UILabel *carIndexText;


//信息
@property(nonatomic)UIView *infoViewBackgroundView;
@property(nonatomic)UILabel *dateText;
@property(nonatomic)UILabel *date;
@property(nonatomic)UILabel *operaterText;
@property(nonatomic)UILabel *operater;
@property(nonatomic)UILabel *countText;
@property(nonatomic)UILabel *count;

@end
@implementation HCBalanceDataView


-(instancetype)init{
    if(self = [super init])
    {
        _lineView = [UIView new];
        _lineView.backgroundColor = [UIColor defaultBorderColor];
        [self addSubview:_lineView];
        
        //添加UI约束
        [self makeBalanceUIContraints];
        [self makeInfoUIContraints];
        [self sendSubviewToBack:_lineView];
        
    }
    return self;
}

-(void)makeInfoUIContraints{
    //信息
    _infoViewBackgroundView = [UIView new];
    [self addSubview:_infoViewBackgroundView];
    
    //说明文字
    _dateText = [UILabel grayLabelWithText:@"操作员："];
    [_infoViewBackgroundView addSubview:_dateText];
    
    _operaterText = [UILabel grayLabelWithText:@"分拣计数："];
    [_infoViewBackgroundView addSubview:_operaterText];
    
    _countText = [UILabel grayLabelWithText:@"剩余任务："];
    [_infoViewBackgroundView addSubview:_countText];
    
    //数据
    _date = [UILabel new];
    _date.font = [UIFont systemFontOfSize:24];
    _date.textAlignment = NSTextAlignmentCenter;
    _date.text = [NetworkManager shareManager].workerName;
    [_infoViewBackgroundView addSubview:_date];
    [_date mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_dateText);
        make.top.equalTo(_dateText.mas_bottom).offset(12);
    }];
    
    _operater = [UILabel new];
    _operater.font = [UIFont systemFontOfSize:24];
    _operater.textAlignment = NSTextAlignmentCenter;
    _operater.text = @"-";
    [_infoViewBackgroundView addSubview:_operater];
    [_operater mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_operaterText);
        make.top.equalTo(_operaterText.mas_bottom).offset(12);
    }];
    
    _count = [UILabel new];
    _count.font = [UIFont systemFontOfSize:24];
    _count.textAlignment = NSTextAlignmentCenter;
    _count.text = @"-";
    [_infoViewBackgroundView addSubview:_count];
    [_count mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_countText);
        make.top.equalTo(_countText.mas_bottom).offset(12);
    }];
    
    //按钮
    _printTestPageButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _printTestPageButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _printTestPageButton.backgroundColor = [UIColor ovLightGrayColor];
    _printTestPageButton.layer.cornerRadius = 8;
    _printTestPageButton.layer.masksToBounds = YES;
    [_printTestPageButton setTitle:@"打印标签" forState:UIControlStateNormal];
    [_printTestPageButton addTarget:self action:@selector(printDerectly) forControlEvents:UIControlEventTouchUpInside];
    [_infoViewBackgroundView addSubview:_printTestPageButton];
    
    _bleReconnectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _bleReconnectButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _bleReconnectButton.backgroundColor = [UIColor ovLightGrayColor];
    _bleReconnectButton.layer.cornerRadius = 8;
    _bleReconnectButton.layer.masksToBounds = YES;
    _bleReconnectButton.tintColor = [UIColor ovRedColor];
    [_bleReconnectButton setTitle:@"跳过菜品" forState:UIControlStateNormal];
    [_bleReconnectButton addTarget:self action:@selector(passMission) forControlEvents:UIControlEventTouchUpInside];
    [_infoViewBackgroundView addSubview:_bleReconnectButton];
    
    [self sendSubviewToBack:_infoViewBackgroundView];
    
}


-(void)makeBalanceUIContraints{
    //称量数据
    _balanceViewBackground = [UIView new];
    _balanceViewBackground.backgroundColor = [UIColor whiteColor];
    [self addSubview:_balanceViewBackground];
    
    _balance = [balanceView new];
    _balance.delegate = self;
    [_balanceViewBackground addSubview:_balance];
    [_balance mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(50);
        make.right.offset(-50);
        make.bottom.offset(-32);
        make.top.offset(130);
    }];
    
    _missionNowText = [UILabel grayLabelWithText:@"当前任务"];
    [_balanceViewBackground addSubview:_missionNowText];
    [_missionNowText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_balance.mas_top).offset(-76);
        make.left.equalTo(_balance);
    }];
    
    _missionNow = [UIButton buttonWithType:UIButtonTypeSystem];
    _missionNow.titleLabel.font = [UIFont systemFontOfSize:54];
    [_missionNow setTintColor:[UIColor ovBlueColor]];
    _missionNow.titleLabel.textAlignment = NSTextAlignmentLeft;
    [_missionNow addTarget:self action:@selector(pressGoodName:) forControlEvents:UIControlEventTouchUpInside];
    [_missionNow setTitle:@"--- -斤" forState:UIControlStateNormal];
    _missionNow.titleLabel.adjustsFontSizeToFitWidth = YES;
    //_missionNow.backgroundColor = [UIColor blackColor];
    [_balanceViewBackground addSubview:_missionNow];
    
    
    _carIndexText = [UILabel grayLabelWithText:@"分拣车号"];
    [_balanceViewBackground addSubview:_carIndexText];
    
    _carIndex = [UILabel new];
    _carIndex.font = [UIFont systemFontOfSize:54];
    _carIndex.textColor = [UIColor ovBlueColor];
    _carIndex.text = @"-";
    [_balanceViewBackground addSubview:_carIndex];
    
    
    [_carIndex mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_carIndexText.mas_bottom).offset(4);
        make.right.equalTo(_balance);
    }];
    [_missionNow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.lessThanOrEqualTo(_carIndex.mas_left).offset(-24);
        make.top.equalTo(_missionNowText.mas_bottom).offset(-2);
        make.left.equalTo(_balance);
    }];
    [_carIndexText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_missionNowText);
        make.right.equalTo(_balance);
    }];
}

-(void)pressGoodName:(id)sender{
    [_delegate pressButton:@"打印单据"];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    //区分横竖屏幕的情况
    if ([self isWide]) {
        //宽屏时
        
        [_balanceViewBackground mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.offset(0);
            make.left.offset(134);
        }];
        [_infoViewBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.offset(0);
            make.right.equalTo(_balanceViewBackground.mas_left);
        }];
        
        
        //信息
        [_dateText mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_missionNowText);
            make.centerX.offset(0);
            make.left.offset(16);
            make.right.offset(-16);
        }];
        [_operaterText mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_date.mas_bottom).offset(24);
            make.centerX.offset(0);
            make.left.offset(16);
            make.right.offset(-16);
        }];
        [_countText mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_operater.mas_bottom).offset(24);
            make.centerX.offset(0);
            make.left.offset(16);
            make.right.offset(-16);
        }];
        [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.offset(2);
            make.right.equalTo(_balanceViewBackground.mas_left);
            make.top.offset(28);
            make.bottom.offset(-28);
        }];
        
        //按钮
        [_printTestPageButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(12);
            make.right.offset(-12);
            make.height.offset(46);
            make.bottom.equalTo(_bleReconnectButton.mas_top).offset(-12);
        }];
        [_bleReconnectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(12);
            make.right.offset(-12);
            make.height.offset(40);
            make.bottom.offset(-24);
        }];
       
        
    }else{
        //竖屏时
        [_balanceViewBackground mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.left.bottom.offset(0);
            make.top.offset(134);
        }];
        [_infoViewBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.offset(0);
            make.bottom.equalTo(_balanceViewBackground.mas_top);
        }];
        //信息
        [_dateText mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(36);
            make.left.offset(50);
        }];
        [_operaterText mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_dateText);
            make.left.equalTo(_date.mas_right).offset(64);
        }];
        [_countText mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_operaterText);
            make.left.equalTo(_operater.mas_right).offset(64);
        }];
        
        [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.offset(2);
            make.bottom.equalTo(_balanceViewBackground.mas_top);
            make.left.offset(28);
            make.right.offset(-28);
        }];
        //按钮
        [_printTestPageButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.offset(88);
            make.height.offset(46);
            make.right.offset(-24);
            make.top.offset(24);
        }];
        [_bleReconnectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(_printTestPageButton);
            make.height.offset(40);
            make.top.equalTo(_printTestPageButton.mas_bottom).offset(8);
        }];
    }
    
}

#pragma mark 操作


//直接打单
-(void)printDerectly{
    [_delegate pressButton:@"打印单据"];
}
//跳过菜品
-(void)passMission{
    [_delegate pressButton:@"跳过任务"];
}

-(void)showInfoWithleftNumber:(NSString *)leftNumber{
    _count.text = leftNumber;
}

-(void)addSortCount{
    _operater.text = [NSString stringWithFormat:@"%ld",(long)_operater.text.integerValue+1];
}

///展示商品名，目标重量，车号
-(void)setGoodName:(NSString *)goodName TargetWeight:(NSString *)targetWeight vehicleName:(NSString *)vehicle{
    
    if (targetWeight.floatValue < 0.001) {
        [_missionNow setTitle:@"没有任务了" forState:UIControlStateNormal];
    }else{
        [_missionNow setTitle:[NSString stringWithFormat:@"%@ %@斤",goodName,targetWeight] forState:UIControlStateNormal];
    }
    
    NSInteger vIndex = vehicle.integerValue;
    if (vIndex % 2 == 0) {
        if (vIndex==0) {
            _carIndex.text = @"无";
        }else{
            _carIndex.text = [NSString stringWithFormat:@"%ld-%ld",(long)vIndex-1,(long)vIndex];
        }
    }else{
        _carIndex.text = [NSString stringWithFormat:@"%ld-%ld",(long)vIndex,(long)vIndex+1];
    }
    
    _missionNow.tintColor = [UIColor ovBlueColor];
    _carIndex.textColor = [UIColor ovBlueColor];
    
}


///展示紫色任务
-(void)setRemakeMissionWithGoodName:(NSString *)goodName TargetWeight:(NSString *)targetWeight vehicleName:(NSString *)vehicle{
    [self setGoodName:goodName TargetWeight:targetWeight vehicleName:vehicle];
    _missionNow.tintColor = [UIColor ovPurpleColor];
    _carIndex.textColor = [UIColor ovPurpleColor];
}


-(void)setTargetWeight:(CGFloat)weight flowNumber:(NSInteger)fNumber{
    _missionFlowNumber = fNumber;
    _balance.targetNumber = weight;
}

#pragma mark - delegate

//秤的视图完成操作
-(void)didCompleteMission:(CGFloat)weight{
    NSLog(@"完成任务：%f",weight);
    //流水号和重量
    [_delegate completeMissionAndNeedNextMission:_missionFlowNumber weight:weight complete:nil];
    
}
//打印被取消
-(void)missionCancel{
    
}
//货物被移走
-(void)goodsDidRemoved{
    [_delegate goodsRemoved];
}



#pragma mark - lazyload


-(BOOL)isWide{
    return self.frame.size.width>self.frame.size.height;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
