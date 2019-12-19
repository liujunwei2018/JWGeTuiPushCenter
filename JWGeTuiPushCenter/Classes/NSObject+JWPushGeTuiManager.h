//
//  NSObject+JWPushGeTuiManager.h
//  JWGeTuiPushCenter
//
//  Created by 刘君威 on 2019/12/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (JWPushGeTuiManager)

/**
 配置推送相关的信息, 推荐在AppDelegate的+load()方法中调用
 
 @param appDelegateClass 当前app的AppDelegate,  可以使用 NSClassFromString(@"AppDelegate") 获取
 @param appId 个推appId
 @param appKey 个推appKey
 @param appSecret 个推appSecret
 @param resultBlock 接收到推送的回调
 */
- (void)jw_configNotificationiAppDelegateClass:(Class)appDelegateClass
                                         appId:(NSString *)appId
                                        appKey:(NSString *)appKey
                                     appSecret:(NSString *)appSecret
                                        result:(void(^)(NSMutableDictionary *resultDict))resultBlock;

@end

NS_ASSUME_NONNULL_END
