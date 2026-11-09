#import <UIKit/UIKit.h>
#import <CoreSpotlight/CoreSpotlight.h>
#import "ViewController1.h"
#import "ViewController2.h"
#import "ViewController3.h"

extern CFAbsoluteTime StartTime;

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    ViewController1 *vc1 = ViewController1.new;
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:vc1];
    vc1.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemRecents tag:0];

    ViewController2 *vc2 = ViewController2.new;
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:vc2];
    vc2.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks tag:0];

    ViewController3 *vc3 = ViewController3.new;
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:vc3];
    vc3.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:0];

    tabBarController.viewControllers = @[nav1, nav2, nav3];
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    NSLog(@"main函数之后启动时间：%lf", CFAbsoluteTimeGetCurrent() - StartTime);

    for (NSUserActivity *activity in connectionOptions.userActivities) {
        [self scene:scene continueUserActivity:activity];
    }
    if (connectionOptions.shortcutItem) {
        [self handleShortcutItem:connectionOptions.shortcutItem];
    }
}

- (void)scene:(UIScene *)scene continueUserActivity:(NSUserActivity *)userActivity {
    if (![userActivity.activityType isEqualToString:CSSearchableItemActionType]) {
        return;
    }

    NSString *identifier = userActivity.userInfo[CSSearchableItemActivityIdentifier];
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UINavigationController *navigationController = (UINavigationController *)tabBarController.selectedViewController;
    UIViewController *viewController = [UIViewController new];
    viewController.title = identifier;
    viewController.view.backgroundColor = [UIColor whiteColor];
    [navigationController pushViewController:viewController animated:YES];
}

- (void)windowScene:(UIWindowScene *)windowScene performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    [self handleShortcutItem:shortcutItem];
    completionHandler(YES);
}

- (void)handleShortcutItem:(UIApplicationShortcutItem *)shortcutItem {
    NSLog(@"name:%@\ntype:%@", shortcutItem.localizedTitle, shortcutItem.type);
}

@end
