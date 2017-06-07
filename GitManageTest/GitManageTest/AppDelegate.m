//
//  AppDelegate.m
//  GitManageTest
//
//  Created by liangscofield on 16/11/4.
//  Copyright © 2016年 liangscofield. All rights reserved.
//

#import "AppDelegate.h"
#import "GWHomeViewController.h"
#import "GWLauchingViewController.h"

#import "WXApi.h"
#import "WXApiObject.h"

#import "GWBaseViewController.h"

#define WXAPPKEY     @"wx5489c5f8940d5e7f" 
#define WXAPPSECRET  @"3c99964e95f92d206b209965601f5427"


@interface AppDelegate () <GWLauchingViewControllerDelegate,WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [WXApi registerApp:WXAPPKEY];
    
    [NSThread sleepForTimeInterval:1]; // 延长开机启动画面时间
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor clearColor];
    
//    取消开屏页面
//    GWLauchingViewController *pLauchingViewController = [GWLauchingViewController new];
//    pLauchingViewController.delegate = self;
    
    GWHomeViewController *pHomeViewController = [GWHomeViewController new];
    UINavigationController *pNavigationController = [[UINavigationController alloc] initWithRootViewController:pHomeViewController];
    self.window.rootViewController = pNavigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    UINavigationController *pNavController = (UINavigationController *)self.window.rootViewController;
    GWBaseViewController *pBaseViewController = (GWBaseViewController *)pNavController.topViewController;
    
    if ([pBaseViewController isKindOfClass:[GWHomeViewController class]])
    {
        [(GWHomeViewController *)pBaseViewController refreshWebview];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// feidan://
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (!url) {  return NO; }
    NSString *URLString = [url absoluteString];
    NSLog(@"%@",URLString);
    //[[NSUserDefaults standardUserDefaults] setObject:URLString forKey:@"url"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

#pragma mark handle url
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    
    BOOL b = [self processApp:app openURL:url];
    
    return b;
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation{
    
    BOOL b = [self processApp:application openURL:url];
    
    return b;
}

- (BOOL)processApp:(UIApplication *)application openURL:(NSURL *)url
{
    NSString *schemaStr = [url scheme];

    if ([schemaStr  isEqualToString:WXAPPKEY]) {
        
        return [WXApi handleOpenURL:url delegate:self];
        
    }
    return YES;
}

#pragma mark - GWLauchingViewControllerDelegate
- (void)finishShowingLaunchingPic:(GWLauchingViewController *)pLauchingViewController
{
    GWHomeViewController *pHomeViewController = [GWHomeViewController new];
    UINavigationController *pNavigationController = [[UINavigationController alloc] initWithRootViewController:pHomeViewController];
    self.window.rootViewController = pNavigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
}

#pragma mark - WXApiDelegate
/*! @brief 收到一个来自微信的请求，处理完后调用sendResp
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
-(void) onReq:(BaseReq*)req
{
    if ([req isKindOfClass:[ShowMessageFromWXReq class]]) {
        ShowMessageFromWXReq *tmp = (id)req;
        id obj = tmp.message.mediaObject;
        if([obj isKindOfClass:[WXAppExtendObject class]]) {
//            NSString *url =  ext.extInfo;
      
            }else{

            
            }
        }
    
}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */

- (void)onResp:(BaseResp *)resp
{
    //    WXErrCodeCommon     = -1,
    //    WXErrCodeUserCancel = -2,
    //    WXErrCodeSentFail   = -3,
    //    WXErrCodeAuthDeny   = -4,
    //    WXErrCodeUnsupport  = -5,
    
    
    if ([resp isKindOfClass:[PayResp class]])
    {
        if (resp.errCode == WXErrCodeUserCancel){
            //nothing
            
        }else if (resp.errCode == WXSuccess) {
        }else {
            
            
        }
        
    }else if ([resp isKindOfClass:[SendMessageToWXResp class]]){
        SendMessageToWXResp *sendResp = (id)resp;
        
        NSInteger rspCode = sendResp.errCode;
        NSString *desc = @"分享失败";
        if (rspCode == WXSuccess) {
            desc = @"分享成功";
        }else if(rspCode == WXErrCodeUserCancel) {
            desc = @"分享取消";
        }else if (rspCode == WXErrCodeSentFail) {
            desc = @"分享失败";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:desc
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        
        [self shareCallBackFun:rspCode withMsg:desc];
        
    }else if ([resp isKindOfClass:[SendAuthResp class]]){
        
        if (resp.errCode == WXSuccess) {
            
        }
        
    }else if([resp isKindOfClass:[AddCardToWXCardPackageResp class]]){
        AddCardToWXCardPackageResp *tmpResp = (id)resp;
        if (tmpResp.errCode == WXSuccess) {
            
        }
        
    }
    else {
        
    }
    
    
}


- (void)shareCallBackFun:(NSInteger)rspCode withMsg:(NSString *)msg
{
    UINavigationController *pNavController = (UINavigationController *)self.window.rootViewController;
    GWBaseViewController *pBaseViewController = (GWBaseViewController *)pNavController.topViewController;
    
    if ([pBaseViewController isKindOfClass:[GWHomeViewController class]])
    {
        [(GWHomeViewController *)pBaseViewController shareCallBackFun:rspCode withMsg:msg];
    }
}

@end
