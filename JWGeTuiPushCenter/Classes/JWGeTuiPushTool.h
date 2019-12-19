//
//  JWGeTuiPushCenter.h
//  JWGeTuiPushCenter_Example
//
//  Created by 刘君威 on 2019/12/18.
//  Copyright © 2019 liujunwei2018. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GTSDK/GeTuiSdk.h>

// iOS10 及以上需导入 UserNotifications.framework
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

NS_ASSUME_NONNULL_BEGIN

typedef void(^JWGeTuiPushCenterCompletionBlock)(NSMutableDictionary *dict);

@interface JWGeTuiPushTool : NSObject <UIApplicationDelegate, GeTuiSdkDelegate, UNUserNotificationCenterDelegate>

+ (instancetype)sharedInstance;

/**
 配置个推
 */
- (void)jw_setupPushWithAppId:(NSString *)appId appKey:(NSString *)appKey appSecret:(NSString *)appSecret result:(void(^)(NSMutableDictionary *resultDict))resultBlock;

/**
 接收到推送的处理
 */
- (void)jw_networkDidReceiveMessage:(NSDictionary *)userInfo Application:(UIApplication *)application;

/**
 设置别名
 */
+ (void)jw_setAlias:(NSString *)alias;

/**
 解绑别名
 */
+ (void)jw_unSetAlias:(NSString *)alias;

@end

NS_ASSUME_NONNULL_END
