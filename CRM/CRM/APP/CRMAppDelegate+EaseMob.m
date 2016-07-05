//
//  CRMAppDelegate+EaseMob.m
//  CRM
//
//  Created by Argo Zhang on 16/3/4.
//  Copyright © 2016年 TimTiger. All rights reserved.
//

#import "CRMAppDelegate+EaseMob.h"

@implementation CRMAppDelegate (EaseMob)

- (void)registerEaseMobConfigWithapplication:(UIApplication *)application options:(NSDictionary *)launchOptions{
    /******************************环信集成Start*************************************/
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = @"toothManagerYYJ_dev";
#else
    apnsCertName = @"toothManagerYYJ_dis";
#endif
    //如果是测试环境
    NSString *appKeyStr;
    if ([DomainName isEqualToString:@"http://www.ibeituan.com/"]) {
        appKeyStr = @"zijingyiyuan#yyjtest";
    }else{
        appKeyStr = @"zijingyiyuan#yyj";
    }
    [[EaseMob sharedInstance] registerSDKWithAppKey:appKeyStr apnsCertName:apnsCertName otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
    
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    //ios9
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound |
        UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    //ios8以下
    else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
    //注册通知，可以接收环信消息
    [self registerEaseMobNotification];
    /******************************环信集成End*************************************/
}

@end
