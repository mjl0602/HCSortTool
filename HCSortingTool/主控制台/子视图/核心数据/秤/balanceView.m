//
//  balanceView.m
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/3/30.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import "balanceView.h"

//比例系数
#define scale self.frame.size.width/566.0

@interface balanceView(){
    UIImageView *targetImg;
    UIView *whiteView;
    CGFloat oldWeight;//上一次的重量
    
    CGFloat weight;
    BOOL isStable;
    
    BOOL didTarget;
    BOOL isTargetWeight;
}

@property(nonatomic)NSMutableArray *dataArray;

//画秤的组件
@property(nonatomic)UIImageView *balanceHolder;
@property(nonatomic)UIImageView *balanceFootLeft;
@property(nonatomic)UIImageView *balanceFootRight;

//显示重量的进度
@property(nonatomic)UIView *balanceProgressView;
@property(nonatomic)UIView *balanceProgressBackground;
//重量计数
@property(nonatomic)UICountingLabel *balanceNumber;

//进度条
@property(nonatomic)UILabel *printProgressLabel;
@property(nonatomic)UIView *printProgressBackground;
@property(nonatomic)UIView *printProgress;

@property(nonatomic)UILabel *bottomTextLabel;

@end

@implementation balanceView


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.targetNumber = 0.0;
        [[NSNotificationCenter defaultCenter]addObserverForName:@"balanceChange" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            
            NSString *value = note.object;
            [self showWithRealNumber:value.floatValue*2];
            //NSLog(@"计算数据:%@",_balanceNumber.text);
        }];
        
    
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor ovLightGrayColor];
        
        //画好秤
        [self drawBalance];
        
        _bottomTextLabel = [UILabel new];
        _bottomTextLabel.font = [UIFont systemFontOfSize:18];
        _bottomTextLabel.textColor = [UIColor whiteColor];
        _bottomTextLabel.text = @"请放置货物";
        [self addSubview:_bottomTextLabel];
        
        
        //画计数器
        _balanceProgressBackground = [UIView new];
        _balanceProgressBackground.backgroundColor = [UIColor clearColor];
        [self addSubview:_balanceProgressBackground];
        [self sendSubviewToBack:_balanceProgressBackground];
       
        //显示计数条
        _balanceProgressView = [UIView new];
        _balanceProgressView.backgroundColor = [UIColor colorWithHexString:@"D8D8D8"];
        [_balanceProgressBackground addSubview:_balanceProgressView];
        _balanceProgressView.frame = CGRectMake(0, self.frame.size.height-80*scale, self.frame.size.width, 0);
        
        //目标的小三角
        targetImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"target.png"]];
        [self addSubview:targetImg];
       
        //计数器
        _balanceNumber = [UICountingLabel new];
        _balanceNumber.format = @"%.2f斤";
        _balanceNumber.font = [UIFont fontWithName:@"Helvetica Neue" size:120];
        _balanceNumber.text = @"-.--斤";
        _balanceNumber.textAlignment = NSTextAlignmentCenter;
        _balanceNumber.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_balanceNumber];
        
        _printProgressBackground = [UIView new];
        _printProgressBackground.backgroundColor = [UIColor ovLightGrayColor];
        [self addSubview:_printProgressBackground];
        [_printProgressBackground mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_printProgressBackground);
            make.top.equalTo(_balanceNumber.mas_bottom).offset(24);
            make.height.offset(12);
            make.left.offset(124);
            make.right.offset(-124);
        }];
        
        _printProgressLabel = [UILabel new];
        _printProgressLabel.textColor = [UIColor ovLightGrayColor];
        _printProgressLabel.font = [UIFont systemFontOfSize:16];
        _printProgressLabel.textAlignment = NSTextAlignmentCenter;
        _printProgressLabel.text = @"等待自动打印";
        [self addSubview:_printProgressLabel];
        [_printProgressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_balanceNumber);
            make.top.equalTo(_balanceNumber.mas_bottom);
        }];
        
        _printProgress = [UIView new];
        _printProgress.backgroundColor = [UIColor ovGreenColor];
        [_printProgressBackground addSubview:_printProgress];
        [_printProgress mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.offset(2);
            make.bottom.offset(-2);
        }];
        
    }
    return self;
}


-(void)layoutSubviews{
    
    //[BLEManager shareManager].blView = self;
    [_bottomTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_balanceHolder);
    }];
    
    [_balanceProgressBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.bottom.equalTo(_balanceHolder.mas_centerY);
        make.top.offset(80*scale);
    }];
    
    [targetImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(18*scale, 40*scale));
        make.right.equalTo(_balanceProgressBackground.mas_right);
        make.centerY.equalTo(_balanceProgressBackground.mas_top);
    }];
    
    [_balanceNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.height.offset(174*scale);
        make.centerY.offset(-48*scale);
    }];
    
    [_balanceFootLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(67*scale);
        make.height.offset(23*scale);
        make.width.offset(39*scale);
        make.bottom.offset(0);
    }];
    
    [_balanceFootRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-67*scale);
        make.height.offset(23*scale);
        make.width.offset(39*scale);
        make.bottom.offset(0);
    }];
    
    [_balanceHolder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.height.equalTo(self.mas_width).multipliedBy(59.0/566);
        make.bottom.equalTo(_balanceFootLeft.mas_top);
    }];
    
    [whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.top.equalTo(_balanceHolder.mas_centerY);
    }];
    
    _balanceProgressView.frame = [self frameWithProgress:0 fatherViewSize:_balanceProgressBackground.frame.size];
    
    
    [self bringSubviewToFront:_balanceNumber];
}


-(void)drawBalance{
    //左边的秤脚
    _balanceFootLeft = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"balanceFoot"]];
    _balanceFootLeft.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_balanceFootLeft];
    
    //右边的秤脚
    _balanceFootRight = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"balanceFoot"]];
    _balanceFootRight.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_balanceFootRight];
    
    //秤盘
    _balanceHolder = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"balanceHolder"]];
    _balanceHolder.contentMode = UIViewContentModeScaleAspectFit;
    //_balanceHolder.backgroundColor = [UIColor blueColor];
    [self addSubview:_balanceHolder];
    
    //底部遮挡一下秤的底座
    whiteView = [UIView new];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:whiteView];
    
    [self sendSubviewToBack:whiteView];
}


//展示数据
-(void)showWithRealNumber:(CGFloat)realNumber{
    //判断稳定
    CGFloat delta = [self checkDataChange:realNumber];
    _realNumber = realNumber;
    [self deltaChange:delta Number:realNumber];
    
    weight = realNumber;
    
    if (oldWeight != realNumber ) {
        //计数
        [_balanceNumber countFrom:_balanceNumber.text.floatValue to:realNumber withDuration:0.2f];
    }
    oldWeight = realNumber;
    
    
    CGFloat progress = 0;
    if (_targetNumber) {
        progress = realNumber/_targetNumber;
    }else{
        progress = realNumber/60.0;
    }
    //NSLog(@"%f,%f",realNumber,progress);
    //目标大小
    CGRect targetFrame = [self frameWithProgress:progress fatherViewSize:_balanceProgressBackground.frame.size];
    //初始化
    UIColor *targetColor = [UIColor colorWithHexString:@"D8D8D8"];
    UIColor *fontColor = [UIColor blackColor];
    isTargetWeight = NO;

    //判断溢出率
    if (progress>1.15) {
        targetColor = [UIColor ovRedColor];
    }else if (progress<=1.15&&progress>=0.95){
        isTargetWeight = YES;
        targetColor = [UIColor ovGreenColor];
        fontColor = [UIColor whiteColor];
    }
    
    
    CGRect rect = _balanceProgressView.frame;
    if (rect.size.width == 0) {
        _balanceProgressView.frame = targetFrame;
        return;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        _balanceProgressView.frame = targetFrame;
        if (_targetNumber) {
            _balanceProgressView.backgroundColor = targetColor;
            _balanceNumber.textColor = fontColor;
        }
        
    }];
}

//稳定度变化
-(void)deltaChange:(CGFloat)delta Number:(CGFloat)realNumber{
    if (delta<0.001) {
        //NSLog(@"稳定");
        if (realNumber < 0.10) {
            //判断text来回调
            if (![_bottomTextLabel.text isEqualToString:@"请放置货物"]) {
                [_delegate goodsDidRemoved];
                _bottomTextLabel.text = @"请放置货物";
            }
        }else{
            NSLog(@"===稳定：%@,%@,%f",
                  didTarget?@"本次已经打印":@"本次还未打印",
                  isTargetWeight?@"在目标重量":@"不在目标重量",
                  _targetNumber
                  );
            //条件：没有打印过（需要重量归零来重置），在目标重量上，目标重量不是0
            if (!didTarget&&isStable&&isTargetWeight&&_targetNumber!=0) {
                NSLog(@"===触发打印");
                [self readyToAutoPrint];
                didTarget = true;
                
            }else{
                
            }
            
            _bottomTextLabel.text = @"稳定状态";
        }
        isStable = true;
    }else{
        //不稳定
        _bottomTextLabel.text = @"等待稳定";
        if (isStable) {
            [self cancelPrint];
            NSLog(@"===取消打印状态");
            
            
        }
        isStable = false;
    }
    //重量归零后，重置打印条件，可以准备下一次打印
    if(realNumber < 0.2){
        didTarget = false;
    }
}


-(void)readyToAutoPrint{
    [UIView animateWithDuration:1.0 animations:^{
        _printProgress.frame = CGRectMake(2, 2, _printProgressBackground.frame.size.width-4, _printProgressBackground.frame.size.height-4);
    } completion:^(BOOL finished) {
        if (finished) {
            NSLog(@"打印");
            [_delegate didCompleteMission:weight];
        }else{
            NSLog(@"打印被取消");
            
            //建议此处断点调试
            
            //取消打印状态
            didTarget = false;
            [SVProgressHUD showErrorWithStatus:@"打印取消"];
        }
    }];
}

-(void)cancelPrint{
    [_printProgress.layer removeAllAnimations];
    _printProgress.frame = CGRectMake(2, 2, 0, _printProgressBackground.frame.size.height-4);
}



#pragma mark - 数据

-(CGFloat)checkDataChange:(CGFloat)NewNumber{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    
    [_dataArray insertObject:@(NewNumber) atIndex:0];
    //最多装10个数据
    int maxNumberCheck = 6;
    if (_dataArray.count>maxNumberCheck) {
        _dataArray = [NSMutableArray arrayWithArray:[_dataArray subarrayWithRange:NSMakeRange(0, maxNumberCheck)]];
    }
    CGFloat variance = [self varianceOfArray:_dataArray];
    // NSLog(@"%f",variance);
    
    return variance;
}

//计算方差
-(CGFloat)varianceOfArray:(NSArray<NSNumber *> *)array{
    
    CGFloat sum = 0;
    for (int i = 0; i<array.count; i++) {
        sum+=array[i].floatValue;
    }
    CGFloat meanNumber = sum/array.count;
    //方差
    CGFloat variance = 0;
    
    for (int i = 0; i<array.count; i++) {
        variance+= (array[i].floatValue-meanNumber)*(array[i].floatValue-meanNumber);
    }
    variance = variance/array.count;

    return variance;
}

//让一个view处在另一个view的底部并按比例算高度
-(CGRect)frameWithProgress:(CGFloat)progress fatherViewSize:(CGSize)size{
    return CGRectMake(0,
                      size.height - progress * size.height,
                      size.width,
                      progress * size.height);
}


@end
