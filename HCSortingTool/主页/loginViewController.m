//
//  loginViewController.m
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/4/26.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import "loginViewController.h"
#import "NetworkManager.h"
#import "Masonry.h"
#import "SVProgressHUD.h"
#import "UILabel+OVLabel.h"
#import "UIColor+OVColor.h"


@interface loginViewController ()<UITextFieldDelegate>

@property(nonatomic)UISegmentedControl *sortLine;
@property(nonatomic)UITextField *input;
@property(nonatomic)UILabel *workerIndex;
@property(nonatomic)UIButton *loginButton;

@end

@implementation loginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *loginText = [UILabel grayLabelWithText:@"登陆工号"];
    [self.view addSubview:loginText];
    
    
    UIView *inputBackPad = [UIView new];
    [self.view addSubview:inputBackPad];
    
    
    _input = [[UITextField alloc]init];
    _input.textAlignment = NSTextAlignmentCenter;
    _input.clearsOnBeginEditing = YES;
    _input.font = [UIFont systemFontOfSize:120];
    if ([NetworkManager shareManager].worker) {
        _input.text = [NetworkManager shareManager].worker;
    }else{
        _input.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"workerIndex"];
    }
    
    _input.borderStyle = UITextBorderStyleRoundedRect;
    _input.keyboardType = UIKeyboardTypeNumberPad;
    _input.returnKeyType = UIReturnKeyDone;
    _input.backgroundColor = [UIColor ovLightGrayColor];
    _input.delegate = self;
    [self.view addSubview:_input];

    
    UILabel *sortText = [UILabel grayLabelWithText:@"分拣线路"];
    [self.view addSubview:sortText];
    
    _sortLine = [[UISegmentedControl alloc]initWithItems:@[@"1号线",@"2号线",@"3号线",@"4号线",@"5号线",@"6号线"]];
    NSString *n = [[NSUserDefaults standardUserDefaults]objectForKey:@"sortPath"];
    //NSLog(@"=====%@",n);
    NSInteger index = n.integerValue - 1;
    if (index<0) {
        index = 0;
    }
    _sortLine.selectedSegmentIndex = index;
    //[_sortLine setEnabled:YES forSegmentAtIndex:n.integerValue];
    _sortLine.tintColor = [UIColor ovBlueColor];
    [self.view addSubview:_sortLine];
    
    [self.view bringSubviewToFront:_input];
    
    [loginText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(12);
        make.left.offset(24);
    }];
    
    [inputBackPad mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.left.offset(24);
        make.top.equalTo(loginText.mas_bottom).offset(8);
        make.left.right.equalTo(_sortLine);
        make.bottom.equalTo(sortText.mas_top).offset(-8);
    }];
    
    [_input mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.left.right.equalTo(inputBackPad);
    }];
    
    [_sortLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(24);
        make.right.offset(-24);
        make.height.offset(36);
        make.bottom.offset(-12);
    }];
    
    [sortText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_sortLine);
        make.bottom.equalTo(_sortLine.mas_top).offset(-8);
    }];
    
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([_input.text isEqualToString: @""]) {
        [_input becomeFirstResponder];
    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"点击了完成按钮");
    if (_input.text.length == 0) {
        _input.text = @"";
    }
    [[NSUserDefaults standardUserDefaults]setObject:_input.text forKey:@"workerIndex"];
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%ld",(long)_sortLine.selectedSegmentIndex+1] forKey:@"sortPath"];
    
    [_input resignFirstResponder];
    
    [NetworkManager shareManager].worker = _input.text;
    [NetworkManager shareManager].sortPath = [NSString stringWithFormat:@"%ld",(long)_sortLine.selectedSegmentIndex+1];
    [self.superVC logInWithWorkerIndex];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    return YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    //NSLog(@"界面消失: %ld, %ld",_input.text.integerValue,_sortLine.selectedSegmentIndex+1);
    [self textFieldShouldReturn:_input];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - popver

//重写preferredContentSize，让popover返回你期望的大小
- (CGSize)preferredContentSize {
    return CGSizeMake(520, 400);
}


- (void)setPreferredContentSize:(CGSize)preferredContentSize{
    super.preferredContentSize = preferredContentSize;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
