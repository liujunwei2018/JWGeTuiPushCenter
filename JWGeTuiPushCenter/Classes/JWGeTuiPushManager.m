//
//  JWGeTuiPushCenter.m
//  JWGeTuiPushCenter_Example
//
//  Created by 刘君威 on 2019/12/18.
//  Copyright © 2019 liujunwei2018. All rights reserved.
//

#import "JWGeTuiPushManager.h"
#import <objc/runtime.h>
#import "JWGeTuiPushTool.h"

@implementation JWGeTuiPushManager

#pragma mark - public

+ (instancetype)sharedInstance {
    static JWGeTuiPushManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JWGeTuiPushManager alloc] init];
    });
    return manager;
}

- (void)jw_configNotificationiAppDelegateClass:(Class)appDelegateClass
                                         appId:(NSString *)appId
                                        appKey:(NSString *)appKey
                                     appSecret:(NSString *)appSecret
                                        result:(void (^)(NSMutableDictionary * _Nonnull))resultBlock {
    
    Class cls = [appDelegateClass class];
    if (!cls) {
        cls = NSClassFromString(@"AppDelegate");
    }
    
    [[JWGeTuiPushTool sharedInstance] jw_setupPushWithAppId:appId appKey:appKey appSecret:appSecret result:resultBlock];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self jw_swizzMethod:cls originSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:) swizzSelector:@selector(jw_application:didRegisterForRemoteNotificationsWithDeviceToken:)];
    });
}

#pragma mark - private

- (void)jw_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"\n>>>[DeviceToken Success]:%@\n\n", token);
    // 向个推服务器注册 deviceToken
    [GeTuiSdk registerDeviceToken:token];
    [self jw_application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)jw_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [GeTuiSdk handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    
    if (application.applicationState == UIApplicationStateActive) {
        return;
    }
    if (application.applicationState == (UIApplicationStateBackground | UIApplicationStateInactive)) {
        [[JWGeTuiPushTool sharedInstance] jw_networkDidReceiveMessage:userInfo Application:application];
        return;
    }
    
    [self jw_application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}

#pragma mark - help

- (void)jw_swizzMethod:(Class)aClass originSelector:(SEL)originSelector swizzSelector:(SEL)swizzSelector {
    Method systemMethod = class_getInstanceMethod(aClass, originSelector);
    Method swizzMethod = class_getInstanceMethod([self class], swizzSelector);
    
    Method tempMethod = class_getInstanceMethod([self class], originSelector);
    
    class_addMethod(aClass, originSelector, method_getImplementation(tempMethod), method_getTypeEncoding(tempMethod));
    systemMethod = class_getInstanceMethod(aClass, originSelector);
    method_exchangeImplementations(systemMethod, swizzMethod);
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
}

@end
