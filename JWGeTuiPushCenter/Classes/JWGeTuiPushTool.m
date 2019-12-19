//
//  JWGeTuiPushCenter.m
//  JWGeTuiPushCenter_Example
//
//  Created by 刘君威 on 2019/12/18.
//  Copyright © 2019 liujunwei2018. All rights reserved.
//

#import "JWGeTuiPushTool.h"

@interface JWGeTuiPushTool()

@property (nonatomic, copy) void(^pushCenterCompletionBlock)(NSMutableDictionary *resultDict);

@end

@implementation JWGeTuiPushTool

#pragma mark - public

+ (instancetype)sharedInstance {
    static JWGeTuiPushTool *pushTool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pushTool = [[JWGeTuiPushTool alloc] init];
    });
    return pushTool;
}

- (void)jw_setupPushWithAppId:(NSString *)appId
                       appKey:(NSString *)appKey
                    appSecret:(NSString *)appSecret
                       result:(void(^)(NSMutableDictionary *resultDict))resultBlock {
    
    [GeTuiSdk startSdkWithAppId:appId appKey:appKey appSecret:appSecret delegate:self];
    [GeTuiSdk setChannelId:@"AppStore"];
    [GeTuiSdk runBackgroundEnable:YES];
    [self registerRemoteNotification];
    if (resultBlock) {
        self.pushCenterCompletionBlock = resultBlock;
    }
}

- (void)jw_networkDidReceiveMessage:(NSDictionary *)userInfo Application:(UIApplication *)application {
    // 取得 APNs 标准信息内容
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    NSString *content = [aps valueForKey:@"alert"];  // 推送显示内容
    NSInteger badge = [[aps valueForKey:@"badge"] integerValue]; // badge 数量
    NSString *sound = [aps valueForKey:@"sound"];   // 播放的声音
    
    NSString *payload = userInfo[@"payload"];
    NSDictionary *payloadDict = [self dictionWithJsonString:payload];
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:payloadDict];
    [resultDict setObject:userInfo forKey:@"userInfo"];
    
    if (self.pushCenterCompletionBlock) {
        self.pushCenterCompletionBlock(resultDict);
    }
}

+ (void)jw_setAlias:(NSString *)alias {
    if (alias && alias.length > 0) {
         [GeTuiSdk bindAlias:alias andSequenceNum:alias];
     }
}

+ (void)jw_unSetAlias:(NSString *)alias {
    if (alias && alias.length > 0) {
        [GeTuiSdk unbindAlias:alias andSequenceNum:alias andIsSelf:YES];
    }
}

#pragma mark- UNUserNotificationCenterDelegate

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [GeTuiSdk handleRemoteNotification:notification.request.content.userInfo];
    }
    completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [GeTuiSdk handleRemoteNotification:response.notification.request.content.userInfo];
        [self jw_networkDidReceiveMessage:userInfo Application:[UIApplication sharedApplication]];
    }
    completionHandler();  // 系统要求执行这个方法
}

#endif

#pragma mark - GTDelegate

- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    //个推SDK已注册，返回clientId
    NSLog(@"\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
}

/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    NSLog(@"\n>>[GTSdk error]:%@\n\n", [error localizedDescription]);
}

/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
    //收到个推消息
    NSString *payloadMsg = nil;
    if (payloadData) {
        payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes length:payloadData.length encoding:NSUTF8StringEncoding];
        
        NSDictionary *payloadDict = [self dictionWithJsonString:payloadMsg];
        if (self.pushCenterCompletionBlock && (offLine != YES)) {
            self.pushCenterCompletionBlock([payloadDict mutableCopy]);
        }
    }
    NSString *msg = [NSString stringWithFormat:@"taskId=%@,messageId:%@,payloadMsg:%@%@",taskId,msgId, payloadMsg,offLine ? @"<离线消息>" : @""];
    NSLog(@"\n>>>[GexinSdk ReceivePayload]:%@\n\n", msg);
}

- (void)GeTuiSdkDidAliasAction:(NSString *)action result:(BOOL)isSuccess sequenceNum:(NSString *)aSn error:(NSError *)aError {
    if ([kGtResponseBindType isEqualToString:action]) {
        NSLog(@"绑定结果 ：%@ !, sn : %@", isSuccess ? @"成功" : @"失败", aSn);
        if (!isSuccess) {
            NSLog(@"失败原因: %@", aError);
        }
    } else if ([kGtResponseUnBindType isEqualToString:action]) {
        NSLog(@"绑定结果 ：%@ !, sn : %@", isSuccess ? @"成功" : @"失败", aSn);
        if (!isSuccess) {
            NSLog(@"失败原因: %@", aError);
        }
    }
}

/** SDK收到sendMessage消息回调 */
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result {
    // 发送上行消息结果反馈
    NSString *msg = [NSString stringWithFormat:@"sendmessage=%@,result=%d", messageId, result];
    NSLog(@"\n>>[GTSdk DidSendMessage]:%@\n\n", msg);
}

/** SDK运行状态通知 */
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {
    // 通知SDK运行状态
    NSLog(@"\n>>[GTSdk SdkState]:%u\n\n", aStatus);
}

/** SDK设置推送模式回调 */
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
    if (error) {
        NSLog(@"\n>>[GTSdk SetModeOff Error]:%@\n\n", [error localizedDescription]);
        return;
    }
    NSLog(@"\n>>[GTSdk SetModeOff]:%@\n\n", isModeOff ? @"开启" : @"关闭");
}

#pragma mark - private

// 注册APNs
- (void)registerRemoteNotification {
    /*
     警告：Xcode8 需要手动开启"TARGETS -> Capabilities -> Push Notifications"
    */
        
    /*
     警告：该方法需要开发者自定义，以下代码根据 APP 支持的 iOS 系统不同，代码可以对应修改。
     以下为演示代码，注意根据实际需要修改，注意测试支持的 iOS 系统都能获取到 DeviceToken
    */
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0 // Xcode 8编译会调用
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
                }
            }];
            
            [[UIApplication sharedApplication] registerForRemoteNotifications];
#else // Xcode 7编译会调用
            UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#endif
        } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        } else {
            UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert |
                                                                           UIRemoteNotificationTypeSound |
                                                                           UIRemoteNotificationTypeBadge);
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
        }
}

- (NSDictionary *)dictionWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&err];
    if (err) {
        return nil;
    }
    return dict;
}

@end
