//
//  HCNetwork.m
//  缓存机制
//
//  Created by Mac on 16/11/10.
//  Copyright © 2016年 Zhu. All rights reserved.
//

#import "HCNetwork.h"
#import "HCNetworkCache.h"
#import "AFNetworkActivityIndicatorManager.h"

static AFHTTPSessionManager *_manager;
static AFNetworkReachabilityStatus _status = -1;
static AFHTTPSessionManager *_webManager;

@implementation HCNetwork
+ (void)initialize{
    [HCNetwork checkNetworkStatus];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml", @"text/plain", nil];
    manager.requestSerializer.timeoutInterval = HCRequestTimeout;
    _manager = manager;
    [HCNetwork WebGetReady];
}

+ (void)WebGetReady{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml", @"text/plain", nil];
    manager.requestSerializer.timeoutInterval = HCRequestTimeout;
    _webManager = manager;
}

#pragma mark --------------------- 网络请求 ---------------------
+(NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure showHUD:(BOOL)showHUD{
    __block NSURLSessionDataTask *session = nil;
    
    if ([HCNetwork doSomethingIfTheNetworkUnable:URLString parameters:parameters success:success failure:failure] && _status == AFNetworkReachabilityStatusNotReachable) return session;
    
    if(showHUD)  NSLog(@"显示 hud 改功能暂无，后续版本添加 加载中...");
    
    session = [_manager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success ? success(task,responseObject) : 0;
        
        [HCNetworkCache cacheResponseObject:responseObject requestUrl:URLString params:parameters];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure ? failure(task,error) : 0;
    }];
    
    [session resume];
    return session;
}

+ (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure showHUD:(BOOL)showHUD useCache:(BOOL)useCache{
    __block NSURLSessionDataTask *session = nil;
    
    if(showHUD) NSLog(@"显示 hud 改功能暂无，后续版本添加 加载中...");
    
    if (useCache) {
        id responseObject = [HCNetworkCache getCacheResponseObjectWithRequestUrl:URLString params:parameters];
        
        if (responseObject) {
            success ? success(session,responseObject) : 0;
        }
    }
    
    if ([HCNetwork doSomethingIfTheNetworkUnable:URLString parameters:parameters success:success failure:failure] && _status == AFNetworkReachabilityStatusNotReachable) return session;
    
    session = [_manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success ? success(session,responseObject) : 0;
        [HCNetworkCache cacheResponseObject:responseObject requestUrl:URLString params:parameters];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure ? failure(session,error) : 0;
    }];
    
    [session resume];
    return session;
}


+ (NSURLSessionDataTask *)WEBGET:(NSString *)URLString
                      parameters:(id)parameters
                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
                         showHUD:(BOOL)showHUD{
    __block NSURLSessionDataTask *session = nil;
    if ([HCNetwork doSomethingIfTheNetworkUnable:URLString parameters:parameters success:success failure:failure] && _status == AFNetworkReachabilityStatusNotReachable) return session;
    if(showHUD)  NSLog(@"显示 hud 改功能暂无，后续版本添加 加载中...");
    
    session = [_webManager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success ? success(task,responseObject) : 0;
        [HCNetworkCache cacheResponseObject:responseObject requestUrl:URLString params:parameters];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure ? failure(task,error) : 0;
    }];
    
    [session resume];
    return session;
}

#pragma mark - 检查网络
+(void)checkNetworkStatus{
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        _status = status;
    }];
    [mgr startMonitoring];
    
}

+(AFNetworkReachabilityStatus) currentNetworkStatus {
    return _status;
}

+(BOOL)doSomethingIfTheNetworkUnable:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure{
    if (_status == -1 || _status == 0) {
        NSError *er;
        if (_status == -1) {
            er = [NSError errorWithDomain:@"com.HCNetwork.unkonwStatus" code:600 userInfo:@{NSLocalizedDescriptionKey:@"无法判断当前网络"}];
        }else{
            er = [NSError errorWithDomain:@"com.HCNetwork.unreacheStatus" code:601 userInfo:@{NSLocalizedDescriptionKey:@"当前无网络连接"}];
        }
        failure ? failure(nil,er) : 0;
        id responseObject = [HCNetworkCache getCacheResponseObjectWithRequestUrl:URLString params:parameters];
        if (responseObject) {
            success ? success(nil,responseObject) : 0;
        }
        return YES;
    }
    return NO;
}



#pragma mark -------------------------------- 清除磁盘网络缓存数据 --------------------------------
+ (void)removeAllObjectsWithBlock:(void(^)(void))block{
    [HCNetworkCache removeAllObjectsWithBlock:block];
}

+ (NSInteger)totalDiskCacheSize{
    return [HCNetworkCache totalDiskCacheSize];
}
@end
