//
//  HCBalanceHistoryView.m
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/4/2.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import "HCBalanceHistoryView.h"
#import "UILabel+OVLabel.h"
#import "UIColor+OVColor.h"

#import "Masonry.h"

@interface HCBalanceHistoryView()<UITableViewDelegate,UITableViewDataSource>{
    BOOL showGoodName;
}

@property(nonatomic)UITableView *tableView;
@property(nonatomic)UILabel *titleLabel;


@property(nonatomic)UISegmentedControl *seg;
@property(nonatomic)NSMutableArray<NSDictionary *> *historyArray;


@end

@implementation HCBalanceHistoryView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _titleLabel = [UILabel grayLabelWithText:@"历史操作"];
        [self addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(8);
            make.top.offset(4);
        }];
        
        _tableView = [UITableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_tableView];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLabel.mas_bottom);
            make.left.right.bottom.offset(0);
        }];
        
        _seg = [[UISegmentedControl alloc]initWithItems:@[@"商家",@"菜品"]];
        _seg.selectedSegmentIndex = 0;
        
        [_seg addTarget:self action:@selector(segDidSelectItem:) forControlEvents:UIControlEventValueChanged];
        _seg.tintColor = [UIColor ovBlueColor];
        [self addSubview:_seg];
        [_seg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_titleLabel);
            make.height.equalTo(_titleLabel).offset(-12);
            make.right.offset(-4);
            make.width.equalTo(_titleLabel);
        }];
        
      
    }
    return self;
}

-(void)segDidSelectItem:(UISegmentedControl *)seg{
    showGoodName = seg.selectedSegmentIndex;
    [self.tableView reloadData];
}



- (void)insertNewCellWith:(NSString *)flowNumber weight:(NSString *)weight name:(NSString *)name GoodsName:(NSString *)goodsName{
    if (!flowNumber|[flowNumber isEqualToString:@"(null)"]) {
        flowNumber = @"0000";
    }
    if (!weight) {
        weight = @"0.00";
    }
    if (!name) {
        name = @"未知商家";
    }
    if (!goodsName) {
        goodsName = @"未知商品";
    }
    
    
    [self.historyArray insertObject:@{
                                      @"fNumber":flowNumber,
                                      @"weight":weight,
                                      @"name":name,
                                      @"goodName":goodsName
                                      }
                            atIndex:0];
    if (self.historyArray.count == 1) {
        [self.tableView reloadData];
    }else{
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    }
    //[self.tableView reloadData];
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.historyArray.count?self.historyArray.count:20;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView *backView = [UIView new];
    backView.backgroundColor = [UIColor ovLightGrayColor];
    [cell.contentView addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.offset(8);
        make.right.offset(-8);
        make.bottom.offset(0);
    }];
    
    //如果没有cell，直接返回空cell
    if(self.historyArray.count==0){
        return cell;
    }
    
    UILabel *timeLabel = [UILabel new];
    timeLabel.font = [UIFont systemFontOfSize:14];
    timeLabel.textColor = [UIColor textGrayColor];
    [backView addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(6);
        make.top.offset(2);
    }];
    
    UILabel *weightLabel = [UILabel new];
    weightLabel.font = [UIFont systemFontOfSize:28];
    [backView addSubview:weightLabel];
    [weightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(6);
        make.top.equalTo(timeLabel.mas_bottom).offset(2);
    }];
    
    UILabel *goodName = [UILabel new];
    goodName.font = [UIFont systemFontOfSize:18];
    [backView addSubview:goodName];
    [goodName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(6);
        make.bottom.offset(-4);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"重做" forState:UIControlStateNormal];
    button.tintColor = [UIColor ovRedColor];
    button.layer.borderColor = [UIColor ovRedColor].CGColor;
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 4;
    button.layer.masksToBounds = YES;
    [backView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.offset(-4);
        make.size.mas_offset(CGSizeMake(64, 30));
    }];
    /*
    NSDate *datenow = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    */
    //插入数据
    NSDictionary<NSString *,NSString *> *data = [self.historyArray objectAtIndex:indexPath.row];
    timeLabel.text = [data objectForKey:@"fNumber"];
    weightLabel.text = [data objectForKey:@"weight"];
    if (showGoodName) {
        goodName.text = [data objectForKey:@"goodName"];
    }else{
        goodName.text = [data objectForKey:@"name"];
    }
    
    
    button.tag = [data objectForKey:@"fNumber"].integerValue;
    cell.tag = button.tag;
    [button addTarget:self action:@selector(pressButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(void)pressButton:(UIButton *)button{
    NSLog(@"点击了按钮 %ld",(long)button.tag);
    [_delegate historyViewDidSelectButtonWithFlowNumber:button.tag];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [_delegate historyViewDidSelectCellWithFlowNumber:cell.tag];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - lazyLoad
-(NSMutableArray<NSDictionary *> *)historyArray{
    if (!_historyArray) {
        _historyArray = [NSMutableArray new];
    }
    return _historyArray;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
