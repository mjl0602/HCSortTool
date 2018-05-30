//
//  sortEntryView.m
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/4/3.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import "sortEntryView.h"
#import "UIColor+OVColor.h"
#import "Masonry.h"
@interface sortEntryView()




@property(nonatomic)UIView* backgroundView;


@end

@implementation sortEntryView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self craetUI];
    }
    return self;
}

-(void)craetUI{
    self.layer.shadowColor = [UIColor colorWithHexString:@"514F4F"].CGColor;
    self.layer.shadowOpacity = 0.63f;
    self.layer.shadowRadius = 12.f;
    self.layer.shadowOffset = CGSizeMake(0,2);
    
    _backgroundView = [UIView new];
    _backgroundView.backgroundColor = [UIColor whiteColor];
    _backgroundView.layer.cornerRadius = 12;
    _backgroundView.userInteractionEnabled = NO;
    [self addSubview:_backgroundView];
    [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.offset(0);
    }];
    
    _imageView = [UIImageView new];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.offset(0);
        make.bottom.offset(-12);
        make.height.lessThanOrEqualTo(@(300));
    }];
    
    _mainText = [UILabel new];
    _mainText.font = [UIFont systemFontOfSize:36 weight:UIFontWeightMedium];
    _mainText.textColor = [UIColor ovBlueColor];
    [self addSubview:_mainText];
    [_mainText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(28);
        make.left.offset(32);
    }];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [UIView animateWithDuration:0.2f animations:^{
        self.transform = CGAffineTransformScale(self.transform, 0.96, 0.96);
        //self.layer.shadowOpacity = 0;
    }];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [UIView animateWithDuration:0.2f animations:^{
        self.transform = CGAffineTransformIdentity;
        //self.layer.shadowOpacity = 0.63f;
    }];
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
