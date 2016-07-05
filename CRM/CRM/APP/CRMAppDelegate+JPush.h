//
//  CRMAppDelegate+JPush.h
//  CRM
//
//  Created by Argo Zhang on 16/4/18.
//  Copyright © 2016年 TimTiger. All rights reserved.
//

#import "CRMAppDelegate.h"

static NSString *appKey = @"817149156ddbc40f380b2f69";
static NSString *channel = @"App Store";
static BOOL isProduction = FALSE;

@interface CRMAppDelegate (JPush)

/**
 *  注册友盟相关信息
 */
- (void)registerJPushConfigWithOptions:(NSDictionary *)launchOptions;

/**
 *  打印推送日志
 */
- (NSString *)logDic:(NSDictionary *)dic;
@end
