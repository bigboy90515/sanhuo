//
//  GWJSObjectInfo.m
//  GitManageTest
//
//  Created by liangscofield on 2016/11/29.
//  Copyright © 2016年 liangscofield. All rights reserved.
//

#import "GWJSObjectInfo.h"

#define kFeiDanUserName @"FeiDanUserName"
#define kFeiDanPassWord @"FeiDanPassWord"

@implementation GWWeChatShareInfo


@end

@implementation GWJSObjectInfo

- (NSString *)getVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"CFBundleShortVersionString"]; // app版本
}

- (NSString *)getAppType
{
    return @"sanhuo";
}

- (NSString *)getOsType
{
    return @"ios";
}

- (NSString *)getLoginAccount
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:kFeiDanUserName];
    NSString *pass = [[NSUserDefaults standardUserDefaults] stringForKey:kFeiDanPassWord];
    
    return [NSString stringWithFormat:@"%@@%@",userName,pass];
}

- (void)setLogin:(NSString *)userName Account:(NSString *)pass
{
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:kFeiDanUserName];
    [[NSUserDefaults standardUserDefaults] setObject:pass forKey:kFeiDanPassWord];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)skipSendSMS:(NSString *)messageInfo
{
    if (self.popMessageViewController) {
        self.popMessageViewController(messageInfo);
    }
}

- (void)skipPhone:(NSString *)callBackFun PicFor:(NSString *)url Result:(NSString *)key
{
    if (self.uploadPicture) {
        self.uploadPicture(callBackFun,url,key);
    }
}

- (void)send:(NSString *)key
           M:(NSString *)callBackFun
           S:(NSString *)url
           G:(NSString *)title
          To:(NSString *)description
           W:(NSString *)imgUrl
           X:(BOOL)isTimelineCb
{
    self.weChatShareInfo.key = key;
    self.weChatShareInfo.callBackFun = callBackFun;
    self.weChatShareInfo.url = url;
    self.weChatShareInfo.title = title;
    self.weChatShareInfo.desc = description;
    self.weChatShareInfo.imgUrl = imgUrl;
    self.weChatShareInfo.isTimelineCb = isTimelineCb;
    
    if (self.weChatShareAction) {
        self.weChatShareAction(self.weChatShareInfo);
    }
    
}

- (GWWeChatShareInfo *)weChatShareInfo
{
    if (!_weChatShareInfo) {
        _weChatShareInfo = [[GWWeChatShareInfo alloc] init];
    }
    
    return _weChatShareInfo;
}

@end
