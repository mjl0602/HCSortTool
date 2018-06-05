//
//  NetworkManager.m
//  HCSortingTool
//
//  Created by 马嘉伦 on 2018/4/3.
//  Copyright © 2018年 马嘉伦. All rights reserved.
//

#import "NetworkManager.h"
#import "AFNetWorking.h"
#import "SVProgressHUD.h"
#import <BmobSDK/Bmob.h>

//const NSString *url = @"http://192.168.23.1:8080";
const NSString *url = @"https://www.haichenpeisong.com";

@implementation NetworkManager

+(instancetype)shareManager{    
    static NetworkManager *a = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        a = [[self alloc] init];
    });
    return a;
}

//完成任务
+(void)completeWithNumber:(CGFloat)weight flowNumber:(NSInteger)flowNumber complete:(void (^)(NSDictionary *res))success{
    NSLog(@"开始完成任务");
    NSString *actualnum = [NSString stringWithFormat:@"%.2f",weight];
    NSString *serialnumber = [NSString stringWithFormat:@"%ld",(long)flowNumber];
    if (![NetworkManager shareManager].sortPath) {
        [SVProgressHUD showErrorWithStatus:@"分拣人员没有登陆"];
        return;
    }
    [self hcHttpGetUseBlockWithUrl:[url stringByAppendingString: @"/mc/sorter/removeGoodsToList"]
                    paramDictionary:@{
                                      @"actualnum":actualnum,//重量
                                      @"fenJianIndex":[NetworkManager shareManager].sortPath ,//分拣台号
                                      @"serialnumber":serialnumber,//流水号
                                      @"isJump":@"false"
                                      }
                            success:^(NSDictionary *res) {
                                success(res);
                            }];
}
//跳过任务
+(void)passMissionWithFlowNumber:(NSInteger)flowNumber complete:(void (^)(NSDictionary *))success{
    NSString *serialnumber = [NSString stringWithFormat:@"%ld",(long)flowNumber];
    [self hcHttpGetUseBlockWithUrl:[url stringByAppendingString: @"/mc/sorter/removeGoodsToList"]
                   paramDictionary:@{
                                     @"fenJianIndex":[NetworkManager shareManager].sortPath ,//分拣台号
                                     @"serialnumber":serialnumber,//流水号
                                      @"isJump":@"true"
                                     }
                           success:^(NSDictionary *res) {
                               
                               success(res);
                               
                           }];
}

//跳过任务大类
+(void)passAllMissionWithFlowNumber:(NSInteger)flowNumber complete:(void (^)(NSDictionary *))success{
    NSString *serialnumber = [NSString stringWithFormat:@"%ld",(long)flowNumber];
    [self hcHttpGetUseBlockWithUrl:[url stringByAppendingString: @"/mc/sorter/jumpGoodsToList"]
                   paramDictionary:@{
                                     @"fenJianIndex":[NetworkManager shareManager].sortPath ,//分拣台号
                                     @"serialnumber":serialnumber,//流水号
                                     }
                           success:^(NSDictionary *res) {
                               
                               success(res);
                               
                           }];
}

//查询任务
+(void)queryMission:(void (^)(NSDictionary *res))success{
    NSLog(@"查询任务开始");
    [self hcHttpGetUseBlockWithUrl:[url stringByAppendingString: @"/mc/sorter/removeGoodsToList"]
                    paramDictionary:@{
                                      @"fenJianIndex":[NetworkManager shareManager].sortPath ,//分拣号
                                      @"isJump":@"false"
                                      }
                            success:^(NSDictionary *res) {
                                NSLog(@"查询所有任务:%@",res);
                                success(res);
                            }];
}

//查询单个任务信息
+(void)queryOneMissionWithFlowNumber:(NSString *)fNumber Complete:(void (^)(NSDictionary *))success{
    NSLog(@"查询单个任务");
    [self hcHttpGetUseBlockWithUrl:[url stringByAppendingString: @"/mc/sorter/searchGoods"]
                   paramDictionary:@{
                                     @"serialnumber":fNumber
                                     }
                           success:^(NSDictionary *res) {
                               //NSLog(@"查询任务:%@",res);
                               success(res);
                           }];
}

//查询标品
+(void)queryStandardGoodsMission:(void (^)(NSDictionary *))success{
    [self hcHttpGetUseBlockWithUrl:[url stringByAppendingString: @"/mc/sorter/removeGoodsToList"]
                   paramDictionary:@{
                                     @"fenJianIndex":@"99" ,//分拣号
                                     @"isJump":@"false"
                                     }
                           success:^(NSDictionary *res) {
                               //NSLog(@"查询任务:%@",res);
                               success(res);
                           }];
}
//商家
+(void)queryStoreName:(void (^)(NSDictionary *))success{
    [self hcHttpGetUseBlockWithUrl:[url stringByAppendingString: @"/mc/order/ios/selOrderToDate"]
                   paramDictionary:@{
                                     @"createtime":@"2018-05-15"
                                     }
                           success:^(NSDictionary *res) {
                               //NSLog(@"查询任务:%@",res);
                               success(res);
                           }];
}

//登陆
+(void)logInWithWorkerIndex:(NSInteger)wIndex SortPathIndex:(NSInteger)sIndex complete:(void (^)(NSDictionary *res))success{
    NSString *wIndexStr = [NSString stringWithFormat:@"%ld",(long)wIndex];
    NSString *sIndexStr = [NSString stringWithFormat:@"%ld",(long)sIndex];
    
    NSLog(@"登录工号：%@，登录分拣号：%@。",wIndexStr,sIndexStr);
//    wIndexStr = @"100001";
//    sIndexStr = @"1";
    
    [self hcHttpPostUseBlockWithUrl:[url stringByAppendingString: @"/iosLogin"]
                    paramDictionary:@{@"username": wIndexStr,@"fenjianNumber": sIndexStr}
                            success:^(NSDictionary *res) {
                                
                                NSLog(@"login res:%@",res);
                                NSString *sessionId = [res objectForKey:@"sessionid"];
                                [[AFHTTPSessionManager manager].requestSerializer setValue:[NSString stringWithFormat:@"JSESSIONID=%@", sessionId]
                                                                        forHTTPHeaderField:@"Authorization"];
                                
                                
                                [NetworkManager shareManager].sessionId = [NSString stringWithFormat:@"JSESSIONID=%@", sessionId];
                                [NetworkManager shareManager].sortPath = sIndexStr;
                                [NetworkManager shareManager].workerName = [res objectForKey:@"name"];
                                [NetworkManager shareManager].worker = [NSString stringWithFormat:@"%ld",(long)wIndex];
                                NSLog(@"session id:%@",[NetworkManager shareManager].sessionId);
                                success(res);
                            }];
}



#pragma mark - 创建请求者
+(AFHTTPSessionManager *)manager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    [manager.requestSerializer setHTTPShouldHandleCookies:YES];
    // 超时时间
    manager.requestSerializer.timeoutInterval = 30;
    // 声明上传的是json格式的参数，需要你和后台约定好，不然会出现后台无法获取到你上传的参数问题
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];

    // 上传普通格式
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //上传JSON格式
    // 声明获取到的数据格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // AFN不会解析,数据是data，需要自己解析
    //manager.responseSerializer = [AFJSONResponseSerializer serializer];
    // AFN会JSON解析返回的数据
    // 个人建议还是自己解析的比较好，有时接口返回的数据不合格会报3840错误，大致是AFN无法解析返回来的数据
    return manager;
}

#pragma mark - daKaHao Get


+(void)hcHttpGetUseBlockWithUrl:(NSString *)url paramDictionary:(NSDictionary *)param success:(void (^)(NSDictionary *))success{
    // 创建请求类
    AFHTTPSessionManager *manager = [self manager];
    
    [manager GET:url parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
        // 这里可以获取到目前数据请求的进度
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 请求成功
        if(responseObject){
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"get 返回数据:%@",dict);
            
            [self uploadNetworkEvent:@"get" withUrl:url withParam:param withRes:dict];
            
            if ([dict.allKeys containsObject:@"msg"]) {
                NSLog(@"msg:%@",[dict objectForKey:@"msg"]);
            }
            success(dict);
        } else {
            //success(@{@"msg":@"暂无数据"}, NO);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 请求失败
        // fail(error);
        [SVProgressHUD dismiss];
        NSLog(@"get请求失败:%@",error.description);
    }];
}


+(void)hcHttpPostUseBlockWithUrl:(NSString *)url paramDictionary:(NSDictionary *)param success:(void (^)(NSDictionary *))success{
    // 创建请求类
    AFHTTPSessionManager *manager = [self manager];

    [manager POST:url parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        // 这里可以获取到目前数据请求的进度
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 请求成功
        if(responseObject){
           NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            
            NSLog(@"POST返回数据:%@",dict);
            [self uploadNetworkEvent:@"post" withUrl:url withParam:param withRes:dict];
            
            if ([dict.allKeys containsObject:@"msg"]) {
                NSLog(@"msg:%@",[dict objectForKey:@"msg"]);
            }
            success(dict);
        } else {
            NSLog(@"没有请求到数据");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"post请求失败:%@",error.description);
    }];
}


+(void)uploadNetworkEvent:(NSString *)type withUrl:(NSString *)url withParam:(NSDictionary *)param withRes:(NSDictionary *)res{

    if ([[NetworkManager shareManager].worker isEqualToString:@"960602"]) {
        return;
    }
    
    BmobObject *event = [BmobObject objectWithClassName:@"NetWork"];
    [event setObject:type forKey:@"type"];
    [event setObject:url forKey:@"url"];
    [event setObject:param forKey:@"param"];
    [event setObject:res forKey:@"res"];
    [event setObject:[NetworkManager shareManager].workerName forKey:@"workerName"];
    [event setObject:[NetworkManager shareManager].worker forKey:@"workerIndex"];
    [event setObject:[NetworkManager shareManager].sortPath forKey:@"path"];
    [event saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        //进行操作
    }];
}

+(void)uploadPrintEventwithStoreName:(NSString *)storeName GoodName:(NSString *)goodName GoodWeight:(NSString *)weight GoodsUnit:(NSString *)unit TranseferIndex:(NSInteger)tIndex StoreIndex:(NSInteger)sIndex Seiral:(NSString *)seiral worker:(NSString *)workerName{

    if ([[NetworkManager shareManager].worker isEqualToString:@"960602"]) {
        return;
    }
    
    BmobObject *event = [BmobObject objectWithClassName:@"Print"];
    [event setObject:storeName forKey:@"storeName"];
    [event setObject:goodName forKey:@"goodName"];
    [event setObject:weight forKey:@"weight"];
    [event setObject:unit forKey:@"unit"];
    [event setObject:@(tIndex) forKey:@"tIndex"];
    [event setObject:@(sIndex) forKey:@"sIndex"];
    [event setObject:seiral forKey:@"seiral"];
    
    [event setObject:[NetworkManager shareManager].workerName forKey:@"workerName"];
    [event setObject:[NetworkManager shareManager].worker forKey:@"workerIndex"];
    [event setObject:[NetworkManager shareManager].sortPath forKey:@"path"];
    
    [event saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        //进行操作
    }];
}

#pragma mark - lazyLoad
-(NSString *)worker{
    if (!_worker) {
        _worker = [[NSUserDefaults standardUserDefaults]objectForKey:@"workerIndex"];
    }
    return _worker;
}

-(NSString *)sortPath{
    if (!_sortPath) {
        _sortPath = [[NSUserDefaults standardUserDefaults]objectForKey:@"sortPath"];
    }
    NSLog(@"分拣号：%@",_sortPath);
    return _sortPath;
}


@end
