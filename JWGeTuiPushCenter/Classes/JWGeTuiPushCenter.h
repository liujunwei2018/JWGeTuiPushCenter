//
//  JWGeTuiPushCenter.h
//  JWGeTuiPushCenter_Example
//
//  Created by 刘君威 on 2019/12/18.
//  Copyright © 2019 liujunwei2018. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JWGeTuiPushCenter : NSObject

+ (instancetype)sharedInstance;

/** 配置个推 */
- (void)xnb_configNotificationiAppDelegateClass:(Class)appDelegateClass appId:(NSString *)appId appKey:(NSString *)appKey appSecret:(NSString *)appSecret notificationResult:(void (^)(NSMutableDictionary *resultDict))result;

@end

NS_ASSUME_NONNULL_END
