//
//  standardPrinterCollectionViewController.m
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/4/26.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import "standardPrinterCollectionViewController.h"
#import "NetworkManager.h"
#import "UIImageView+WebCache.h"

#import "StandardPrintCollectionViewCell.h"



@interface standardPrinterCollectionViewController (){
    NSInteger printIndex;
    NSArray<NSArray *> *printMissionArray;
    HCCellType printType;
}


@property(nonatomic)NSArray<NSDictionary *> *goodsArray;
@property(nonatomic)NSArray<NSDictionary *> *storeArray;


@end

@implementation standardPrinterCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UISegmentedControl *seg = [[UISegmentedControl alloc]initWithItems:@[@"标品打印",@"商家打印"]];
//    self.navigationItem.titleView = seg;
    //self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor ovLightGrayColor];
    self.navigationController.navigationBar.barTintColor = [UIColor ovBlueColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.title = @"标品打印";
    [self.collectionView setCollectionViewLayout:[self collectionViewLayout] animated:YES];
    
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismiss:)];
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(printer:)];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [SVProgressHUD showWithStatus:@"查询中"];
    [NetworkManager queryStandardGoodsMission:^(NSDictionary *res) {
        self.goodsArray = [res objectForKey:@"data"];
        //NSLog(@"goodsArray %@",res);
        [self.collectionView reloadData];
        [NetworkManager queryStoreName:^(NSDictionary *res) {
            self.storeArray = [NSArray arrayWithArray:[res objectForKey:@"data"]];
            NSLog(@"storeArray %@",[res objectForKey:@"data"]);
            [self.collectionView reloadData];
            [SVProgressHUD dismiss];
        }];
    }];
}

-(void)printer:(id)sender{
    [BLEManager shareManager].noBalance = true;
    [[BLEManager shareManager]tryConnectPrinter];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismiss:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.goodsArray.count;
            break;
        case 1:
            return self.storeArray.count;
            break;
        default:
            break;
    }
    return 0;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[NSString stringWithFormat:@"HeaderView%ld",indexPath.section]];
    if (kind == UICollectionElementKindSectionHeader){
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[NSString stringWithFormat:@"HeaderView%ld",indexPath.section] forIndexPath:indexPath];
        if (headerView.subviews.count>0) {
            return headerView;
        }
        headerView.backgroundColor = [UIColor whiteColor];
        UILabel *titleLabel = [UILabel grayLabelWithText:@"标品"];
        titleLabel.font = [UIFont systemFontOfSize:24];
        
        UIButton *printAll = [UIButton buttonWithType:UIButtonTypeSystem];
        [printAll setTitle:@"打印全部" forState:UIControlStateNormal];
        printAll.titleLabel.font = [UIFont systemFontOfSize:24];
        [printAll addTarget:self action:@selector(pressPrintAllButton:) forControlEvents:UIControlEventTouchUpInside];
        
        switch (indexPath.section) {
            case 0:
                titleLabel.text = @"标品";
                printAll.tag = HCCellTypeStandardGood;
                break;
            case 1  :
                titleLabel.text = @"商家";
                printAll.tag = HCCellTypeStoreName;
                break;
            default:
                break;
        }
        [headerView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(24);
            make.centerY.offset(0);
        }];
        [headerView addSubview:printAll];
        [printAll mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleLabel.mas_right).offset(48);
            make.centerY.offset(0);
        }];
        reusableview = headerView;
        
    }

    
    return reusableview;
}

-(void)pressPrintAllButton:(UIButton *)button{
    if (button.tag == HCCellTypeStandardGood) {
        [self printAllGoods];
    }
    else if (button.tag == HCCellTypeStoreName) {
        [self printAllStoreName];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        NSDictionary *data = self.goodsArray[indexPath.row];
        NSArray *missionArray = [data objectForKey:@"data"];
        NSString *goodName = [data objectForKey:@"goodsType"];
        NSString *imageUrl = [data objectForKey:@"goodsImg"];
        if (!imageUrl) {
            imageUrl = @"";
        }
        [self.collectionView registerClass:[StandardPrintCollectionViewCell class] forCellWithReuseIdentifier:goodName];
        StandardPrintCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:goodName forIndexPath:indexPath];
        //NSLog(@"cell:%@",[cell.contentView subviews]);
        if ([cell.contentView subviews].count<2) {
            [cell loadData:goodName url:imageUrl count:missionArray.count Type:HCCellTypeStandardGood];
        }
         return cell;
    }
    //商家
    else if (indexPath.section==1){
        NSDictionary *data = self.storeArray[indexPath.row];
        NSString *price = [data objectForKey:@"goodsMoney"];
        NSString *goodName = [data objectForKey:@"shopname"];

        [self.collectionView registerClass:[StandardPrintCollectionViewCell class] forCellWithReuseIdentifier:goodName];
        StandardPrintCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:goodName forIndexPath:indexPath];
        //NSLog(@"cell:%@",[cell.contentView subviews]);
        if ([cell.contentView subviews].count<2) {
            //用url传这个价格，乱写的
            [cell loadData:goodName url:price count:0 Type:HCCellTypeStoreName];
        }
         return cell;
    }
    
    return [UICollectionViewCell new];
}

-(UICollectionViewLayout *)collectionViewLayout{
    CGSize itemSize = CGSizeMake(180, 180);
    // NSLog(@"insert===%f",insert);
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize =  itemSize;//设置每个cell的大小
    layout.sectionInset = UIEdgeInsetsMake(24, 24, 24, 24);//设置内容的内边距
    layout.minimumLineSpacing = 18;//设置每个cell之间的最小间距
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;//设置滚动方向
    layout.headerReferenceSize = CGSizeMake(400, 36);
    return layout;
}


#pragma mark <UICollectionViewDelegate>

//按下手指
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"shouldHighlightItemAtIndexPath");
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.1 animations:^{
        cell.transform = CGAffineTransformScale(cell.transform, 0.95, 0.95);
        //cell.backgroundColor = self.highLightColor;
    }];
    
	return YES;
}


//移走手指
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"shouldSelectItemAtIndexPath");
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
  
    
    [UIView animateWithDuration:0.1 animations:^{
        cell.transform = CGAffineTransformIdentity;
        //cell.backgroundColor = self.highLightColor;
    }];
    
    
    switch (indexPath.section) {
        case 0:
            [self willPrintGoodsAtIndexPath:indexPath];
            break;
        case 1:
            [self printStoreNameAtIndexpath:indexPath];
            break;
        default:
            [SVProgressHUD showErrorWithStatus:@"要么是你点错了，要么是我写错了"];
            break;
    }
    
    
    return YES;
}

#pragma mark - 打印标品

//打印所有标品
-(void)printAllGoods{
    NSMutableArray<NSArray *> *printMissions = [NSMutableArray new];
    
    for (NSInteger i = 0; i<self.goodsArray.count; i++) {
        NSDictionary *data = self.goodsArray[i];
        NSArray *missionArray = [data objectForKey:@"data"];
        printMissions = [self addMissions:missionArray ToArray:printMissions];
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"打印全部标品" message:[NSString stringWithFormat:@"将要打印%ld份",printMissions.count] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *printPage = [UIAlertAction actionWithTitle:@"打印"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [SVProgressHUD showWithStatus:@"打印中..."];
                                                          //初始化打印前置条件
                                                          [self initPrinterWithArray:printMissions type:HCCellTypeStandardGood];
                                                          
                                                          //递归打印所有标品
                                                          [self print];
                                                          
                                                      }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             // do destructive stuff here
                                                         }];
    [alertController addAction:printPage];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)willPrintGoodsAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *data = self.goodsArray[indexPath.row];
    NSArray *missionArray = [data objectForKey:@"data"];
    
    NSLog(@"%@",missionArray.description);
    NSMutableArray<NSArray *> *printMissions = [NSMutableArray new];
    //添加进打印队列
    printMissions = [self addMissions:missionArray ToArray:printMissions];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"打印标品" message:[NSString stringWithFormat:@"将要打印%ld份",printMissions.count] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *printPage = [UIAlertAction actionWithTitle:@"打印"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [SVProgressHUD showWithStatus:@"打印中..."];
                                                     
                                                          [self initPrinterWithArray:printMissions type:HCCellTypeStandardGood];
                                                          
                                                          //递归打印所有标品
                                                          [self print];
                                                          
                                                      }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             // do destructive stuff here
                                                         }];
    
    [alertController addAction:printPage];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//把若干任务推进一个数组，并返回该数组
-(NSMutableArray *)addMissions:(NSArray<NSDictionary *> *)missionArray ToArray:(NSMutableArray *)a{
    for (int i = 0; i<missionArray.count; i++) {
        NSDictionary *mission = missionArray[i];
        NSArray<NSString *> *printMission = @[
                                              [NSString stringWithFormat:@"%@",[mission objectForKey:@"name"]],
                                              [NSString stringWithFormat:@"%@",[mission objectForKey:@"goodsname"]],
                                              [NSString stringWithFormat:@"%@",[mission objectForKey:@"goodsnum"]],
                                              [NSString stringWithFormat:@"%@", [mission objectForKey:@"goodsunit"]],
                                              [NSString stringWithFormat:@"%@",[mission objectForKey:@"xianluhao"]],
                                              [NSString stringWithFormat:@"%@",[mission objectForKey:@"kuanghao"]],
                                              [NSString stringWithFormat:@"%@",[mission objectForKey:@"serialnumber"]],
                                              [NSString stringWithFormat:@"%@",[mission objectForKey:@"sortername"]]
                                              ];
        [a addObject:printMission];
    }
    return a;
}
//推商家名称
-(NSMutableArray *)addStore:(NSDictionary *)store ToArray:(NSMutableArray *)a{
    
    
    NSNumber *goodsMoney = [store objectForKey:@"goodsMoney"];
    
    for (int i = 0; i<=(goodsMoney.floatValue/150); i++) {
        
        NSArray<NSString *> *printMission = @[
                                              [NSString stringWithFormat:@"%@",[store objectForKey:@"shopname"]],
                                              [NSString stringWithFormat:@"%@",[store objectForKey:@"goodsMoney"]]
                                              ];
        [a addObject:printMission];
    }
    return a;
}

#pragma mark - 打印商家名称
-(void)printAllStoreName{
    NSMutableArray<NSArray *> *printMissions = [NSMutableArray new];
    
    for (NSInteger i = 0; i<self.storeArray.count; i++) {
        NSDictionary *store = self.storeArray[i];
        //添加进打印队列
        printMissions = [self addStore:store ToArray:printMissions];
    }
   
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"打印商家标签" message:[NSString stringWithFormat:@"将要打印%ld份",printMissions.count] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *printPage = [UIAlertAction actionWithTitle:@"打印"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [SVProgressHUD showWithStatus:@"打印中..."];
                                                          [self initPrinterWithArray:printMissions type:HCCellTypeStoreName];
                                                          //递归打印
                                                          [self print];
                                                      }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             // do destructive stuff here
                                                         }];
    
    [alertController addAction:printPage];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)printStoreNameAtIndexpath:(NSIndexPath *)indexPath{
    NSDictionary *store = self.storeArray[indexPath.row];
    
    NSMutableArray<NSArray *> *printMissions = [NSMutableArray new];
    //添加进打印队列
    printMissions = [self addStore:store ToArray:printMissions];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"打印商家标签" message:[NSString stringWithFormat:@"将要打印%ld份",printMissions.count] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *printPage = [UIAlertAction actionWithTitle:@"打印"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [SVProgressHUD showWithStatus:@"打印中..."];
                                                          
                                                          [self initPrinterWithArray:printMissions type:HCCellTypeStoreName];
                                                          
                                                          //递归打印所有标品
                                                          [self print];
                                                          
                                                      }];
    UIAlertAction *printOne = [UIAlertAction actionWithTitle:@"打印一张"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [SVProgressHUD showWithStatus:@"打印中..."];
                                                          [self initPrinterWithArray:@[printMissions[0]] type:HCCellTypeStoreName];
                                                          //递归打印所有标品
                                                          [self print];
                                                      }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             // do destructive stuff here
                                                         }];
    
    [alertController addAction:printPage];
     [alertController addAction:printOne];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}


#pragma mark - 打印

-(void)initPrinterWithArray:(NSArray *)a type:(HCCellType)type{
    printType = type;
    printMissionArray = [NSArray arrayWithArray:a];
    printIndex = 0;
}

//递归打印
-(void)print{
    if (printIndex<printMissionArray.count) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        NSArray<NSString *> *mission = printMissionArray[printIndex];
        
        if (printType == HCCellTypeStandardGood) {
            [[BLEManager shareManager]printLabelWithStoreName:mission[0]
                                                     GoodName:mission[1]
                                                   GoodWeight:mission[2]
                                                    GoodsUnit:mission[3]
                                               TranseferIndex:mission[4].integerValue
                                                   StoreIndex:mission[5].integerValue
                                                       Seiral:mission[6]
                                                       worker:mission[7]];
            [SVProgressHUD showProgress:(printIndex*1.0)/printMissionArray.count status:[NSString stringWithFormat:@"打印第%ld份\n品名:%@\n打印数量:%@",printIndex+1,mission[1],mission[2]]];
        }
        else if (printType == HCCellTypeStoreName) {
            [[BLEManager shareManager]printStoreName:mission[0]];
            [SVProgressHUD showProgress:(printIndex*1.0)/printMissionArray.count status:[NSString stringWithFormat:@"打印第%ld份\n商家名:%@\n总价:%@",printIndex+1,mission[0],mission[1]]];
        }
        printIndex++;
        [self performSelector:@selector(print) withObject:nil afterDelay:0.8];
    }else{
        [SVProgressHUD showSuccessWithStatus:@"打印完成"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    }
}

-(NSArray<NSDictionary *> *)storeArray{
    if (!_storeArray| [_storeArray isEqual:[NSNull null]]) {
        _storeArray = @[];
    }
    return _storeArray;
}
-(NSArray<NSDictionary *> *)goodsArray{
    if (!_goodsArray | [_goodsArray isEqual:[NSNull null]]) {
        _goodsArray = @[];
    }
    return _goodsArray;
}

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
