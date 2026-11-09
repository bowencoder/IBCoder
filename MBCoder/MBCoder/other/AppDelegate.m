//
//  AppDelegate.m
//  MBCoder
//
//  Created by Bowen on 2019/9/30.
//  Copyright © 2019 inke. All rights reserved.
//

#import "AppDelegate.h"
#import "SonicSetup.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SonicSetup setup];
    [self initShortcutItems];
    NSLog(@"%@", NSHomeDirectory());
    return YES;
}

- (void)initShortcutItems {
    
    if ([UIApplication sharedApplication].shortcutItems.count >= 4)
        return;
    
    NSMutableArray *arrShortcutItem = [[UIApplication sharedApplication].shortcutItems mutableCopy] ?: [NSMutableArray array];
    
    
    UIApplicationShortcutItem *shoreItem1 = [[UIApplicationShortcutItem alloc] initWithType:@"cn.damon.DM3DTouchDemo.openSearch" localizedTitle:@"搜索" localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeSearch] userInfo:nil];
    [arrShortcutItem addObject:shoreItem1];
    
    UIApplicationShortcutItem *shoreItem2 = [[UIApplicationShortcutItem alloc] initWithType:@"cn.damon.DM3DTouchDemo.openCompose" localizedTitle:@"新消息" localizedSubtitle:@"" icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeCompose] userInfo:nil];
    [arrShortcutItem addObject:shoreItem2];
    
    [UIApplication sharedApplication].shortcutItems = arrShortcutItem;
    
    NSLog(@"%lu", [UIApplication sharedApplication].shortcutItems.count);
}



@end

