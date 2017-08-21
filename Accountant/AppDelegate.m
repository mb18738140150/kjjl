//
//  AppDelegate.m
//  Accountant
//
//  Created by aaa on 2017/2/27.
//  Copyright © 2017年 tianming. All rights reserved.
//

#import "AppDelegate.h"
#import "TabbarViewController.h"
#import "HttpRequestManager.h"
#import "UserManager.h"
#import "CourseraManager.h"
#import "ImageManager.h"
#import "DBManager.h"
#import "CourseraManager.h"
#import "VideoPlayViewController.h"
#import "NotificaitonMacro.h"
#import "DownloaderManager.h"
#import "CommonMacro.h"
#import "AFNetworking.h"
#import "JRSwizzle.h"
#import "NSDictionary+Unicode.h"
#import "DownLoadModel.h"
#import <RongIMKit/RongIMKit.h>

#define kappKey @"996fd8241dbee684918b6578"
#define kchannel @"App Store"
#define kapsForProduction 0
#define kadvertisingIdentifier
#define RONGCLOUD_IM_APPKEY @"x4vkb1qpx76mk"

//#define RONGCLOUD_IM_APPKEY @"x18ywvqfx6dsc"


#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate ()<UserModule_AppInfoProtocol,UIAlertViewDelegate,JPUSHRegisterDelegate,UserModule_BindJPushProtocol,UNUserNotificationCenterDelegate>

@property (nonatomic,strong) TabbarViewController           *tabbarViewController;

@property (nonatomic,strong) NSString                       *versionContent;
@property (nonatomic,strong) NSString                       *updateUrl;

@property (nonatomic,assign) BOOL                            isForce;
@property (nonatomic, strong)NSTimer * noticeTimer;
@end

@implementation AppDelegate

#pragma mark - app delegate funcs
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self mainViewSetup];
    
    [self checkUpdate];
    
    [NSDictionary jr_swizzleMethod:@selector(description) withMethod:@selector(my_description) error:nil];
    
    [[DBManager sharedManager] intialDB];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    
    // JPush注册
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    [JPUSHService setupWithOption:launchOptions appKey:kappKey
                          channel:kchannel
                 apsForProduction:kapsForProduction
            advertisingIdentifier:nil];
    
    NSDictionary * remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (remoteNotification) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[remoteNotification description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }
    
//    [[RCIM sharedRCIM]initWithAppKey:RONGCLOUD_IM_APPKEY];
    
    [[RCDLive sharedRCDLive] initRongCloud:RONGCLOUD_IM_APPKEY];
    __weak typeof(self)weakself = self;
    if ([[UserManager sharedManager] getUserId]) {
        [[RCIM sharedRCIM] connectWithToken:[[UserManager sharedManager] getRongToken] success:^(NSString *userId) {
            NSLog(@"连接融云成功");
            RCUserInfo *user = [RCUserInfo new];
            
            user.userId = [NSString stringWithFormat:@"%d", [UserManager sharedManager].getUserId];
            user.name = [[UserManager sharedManager] getUserName];
            user.portraitUri = [[UserManager sharedManager] getIconUrl];
            
            [[RCIM sharedRCIM]refreshUserInfoCache:user withUserId:user.userId];
            [RCIM sharedRCIM].currentUserInfo.userId = user.userId;
            [RCIM sharedRCIM].currentUserInfo.name = user.name;
            [RCIM sharedRCIM].currentUserInfo.portraitUri = user.portraitUri;
        } error:^(RCConnectErrorCode status) {
            NSLog(@"连接失败");
//            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"连接融云失败，请从新登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
            [weakself pushLoginVC];
        } tokenIncorrect:^{
            NSLog(@"token过期");
//            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Token失效，请从新登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
            [weakself pushLoginVC];
            
        }];
    }
    
    [DownloaderManager sharedManager];
    [[TYDownloadSessionManager manager] setBackgroundSessionDownloadCompleteBlock:^NSString *(NSString *downloadUrl) {
        TYDownloadModel *model = [[TYDownloadModel alloc]initWithURLString:downloadUrl];
        return model.filePath;
    }];
    [[TYDownloadSessionManager manager] configureBackroundSession];
    
    return YES;
}




- (void)pushLoginVC
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOfLoginClick object:nil];
}
#pragma mark - UI setup
- (void)mainViewSetup
{
    self.tabbarViewController = [[TabbarViewController alloc] init];
    self.window.rootViewController = self.tabbarViewController;
}

- (void)checkUpdate
{
    [[UserManager sharedManager] didRequestAppVersionInfoWithNotifiedObject:self];
}

- (void)hasNewVersion
{
    float version = [[[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"] floatValue];
    NSDictionary *dic = [[UserManager sharedManager] getUpdateInfo];
    float newVersion = [[dic objectForKey:kAppUpdateInfoVersion] floatValue];
    if (newVersion > version) {
        self.isForce = 1;
        self.updateUrl = [dic objectForKey:kAppUpdateInfoUrl];
        self.versionContent = [dic objectForKey:kAppUpdateInfoContent];
        if (self.isForce) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"监测到新版本" message:self.versionContent delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"立即更新", nil];
            [alert show];
        }else{
        
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"监测到新版本" message:self.versionContent delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"立即更新", nil];
            [alert show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if (self.isForce) {
            exit(0);
        }else{
            
        }
    }
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updateUrl]];
        exit(0);
    }
}

- (void)didRequestAppInfoSuccessed
{
    [self hasNewVersion];
}

- (void)didRequestAppInfoFailed:(NSString *)failedInfo
{
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
//    NSMutableArray * array = [NSMutableArray array];
//    [array addObjectsFromArray:[[DBManager sharedManager]getDownloadingVideos]];
//    for (DownLoadModel *model in array) {
//        NSLog(@"暂停所有任务");
//        [[DownloaderManager sharedManager] pauseDownloadWithModel:model];
//    }
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    [[DownloaderManager sharedManager] pauseDownload];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [JPUSHService setBadge:0];
    [application setApplicationIconBadgeNumber:0];
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//    [[DownloaderManager sharedManager] unpauseDownload];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
    NSString * registrationID = [JPUSHService registrationID];
    if (registrationID.length == 0) {
        self.noticeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(scrollNotice) userInfo:nil repeats:YES];
    }else
    {
        [[NSUserDefaults standardUserDefaults] setObject:registrationID forKey:@"registrationID"];
        [[UserManager sharedManager] didRequestBindJPushWithCID:registrationID withNotifiedObject:self];
    }
    
}
- (void)scrollNotice
{
    NSString * registrationID = [JPUSHService registrationID];
    if (registrationID.length != 0) {
        [[NSUserDefaults standardUserDefaults] setObject:registrationID forKey:@"registrationID"];
        [[UserManager sharedManager] didRequestBindJPushWithCID:registrationID withNotifiedObject:self];
        
        [self.noticeTimer invalidate];
        self.noticeTimer = nil;
    }
}

- (void)didRequestBindJPushSuccessed
{
    
}

- (void)didRequestBindJPushFailed:(NSString *)failedInfo
{
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}



- (void)UIApplication:(UIApplication *)application setApplicationIconBadgeNumber:(NSInteger)number
{
//    [JPUSHService setBadge:0];
    [application setApplicationIconBadgeNumber:0];
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler
{
    
    [TYDownloadSessionManager manager].backgroundSessionCompletionHandler = completionHandler;
}


- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
    [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
}

// Called when your app has been activated by the user selecting an action from
// a local notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
  completionHandler:(void (^)())completionHandler {
}

// Called when your app has been activated by the user selecting an action from
// a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling
// the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)())completionHandler {
}
#endif

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 前台收到远程通知:");
        
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocalNitificationOfLivingStart object:@{@"key":@"直播开始了"}];
        
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 前台收到远程通知:");
        
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocalNitificationOfLivingStart object:@{@"key":@"直播开始了"}];
    }
    
    completionHandler();  // 系统要求执行这个方法
}
#endif

#pragma mark - RCIMConnectionStatusDelegate
/**
 *  网络状态变化。
 *
 *  @param status 网络状态。
 */
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status {
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"提示"
                              message:@"您"
                              @"的帐号在别的设备上登录，您被迫下线！"
                              delegate:nil
                              cancelButtonTitle:@"知道了"
                              otherButtonTitles:nil, nil];
        [alert show];
        
        [self loginOut];
        
    } else if (status == ConnectionStatus_TOKEN_INCORRECT) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self loginOut];
            UIAlertView *alertView =
            [[UIAlertView alloc] initWithTitle:nil
                                       message:@"Token已过期，请重新登录"
                                      delegate:nil
                             cancelButtonTitle:@"确定"
                             otherButtonTitles:nil, nil];
            [alertView show];
        });
    }
}

- (void)loginOut{
    [[UserManager sharedManager] logout];
    [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:nil object:nil];
    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:nil];
    [[RCIMClient sharedRCIMClient] logout];
    
    self.tabbarViewController.selectedIndex = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOfLoginClick object:nil];
    
}

@end