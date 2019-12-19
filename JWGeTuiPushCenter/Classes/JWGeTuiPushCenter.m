//
//  JWGeTuiPushCenter.m
//  JWGeTuiPushCenter_Example
//
//  Created by 刘君威 on 2019/12/18.
//  Copyright © 2019 liujunwei2018. All rights reserved.
//

#import "JWGeTuiPushCenter.h"
#import "NSObject+JWPushGeTuiManager.h"

@implementation JWGeTuiPushCenter

#pragma mark - public

+ (instancetype)sharedInstance {
    static JWGeTuiPushCenter *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JWGeTuiPushCenter alloc] init];
    });
    return manager;
}

- (void)xnb_configNotificationiAppDelegateClass:(Class)appDelegateClass appId:(NSString *)appId appKey:(NSString *)appKey appSecret:(NSString *)appSecret notificationResult:(void (^)(NSMutableDictionary *resultDict))result {
    [self jw_configNotificationiAppDelegateClass:appDelegateClass appId:appId appKey:appKey appSecret:appSecret result:result];
}

@end
