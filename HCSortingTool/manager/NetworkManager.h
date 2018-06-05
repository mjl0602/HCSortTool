//
//  NetworkManager.h
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/4/3.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BLEManager.h"
#import "Masonry.h"

#import "UIColor+OVColor.h"
#import "UILabel+OVLabel.h"

@interface NetworkManager : NSObject

//工号
@property(nonatomic)NSString *worker;
@property(nonatomic)NSString *workerName;
//分拣台号
@property(nonatomic)NSString *sortPath;
@property(nonatomic)NSString *sessionId;

+(instancetype)shareManager;

///登陆
+(void)logInWithWorkerIndex:(NSInteger)wIndex SortPathIndex:(NSInteger)sIndex complete:(void (^)(NSDictionary *res))success;
///查询
+(void)queryMission:(void (^)(NSDictionary *res))success;
///查询
+(void)queryOneMissionWithFlowNumber:(NSString *)fNumber Complete:(void (^)(NSDictionary *res))success;
+(void)queryStoreName:(void (^)(NSDictionary *))success;
///查询标品
+(void)queryStandardGoodsMission:(void (^)(NSDictionary *res))success;
///重量，流水线号，工号。回调
+(void)completeWithNumber:(CGFloat)weight flowNumber:(NSInteger)flowNumber complete:(void (^)(NSDictionary *res))success;
///跳过
+(void)passMissionWithFlowNumber:(NSInteger)flowNumber complete:(void (^)(NSDictionary *res))success;
///跳过任务大类
+(void)passAllMissionWithFlowNumber:(NSInteger)flowNumber complete:(void (^)(NSDictionary *))success;

///基础请求封装
+(void)hcHttpGetUseBlockWithUrl:(NSString *)url paramDictionary:(NSDictionary *)param success:(void (^)(NSDictionary *res))success;
+(void)hcHttpPostUseBlockWithUrl:(NSString *)url paramDictionary:(NSDictionary *)param success:(void (^)(NSDictionary *res))success;

//记录打印
+(void)uploadPrintEventwithStoreName:(NSString *)storeName GoodName:(NSString *)goodName GoodWeight:(NSString *)weight GoodsUnit:(NSString *)unit TranseferIndex:(NSInteger)tIndex StoreIndex:(NSInteger)sIndex Seiral:(NSString *)seiral worker:(NSString *)workerName;
@end
