//
//  GWJSObjectInfo.h
//  GitManageTest
//
//  Created by liangscofield on 2016/11/29.
//  Copyright © 2016年 liangscofield. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JavaScriptObjectiveCDelegate <JSExport>

- (NSString *)getVersion; // 获取版本号
- (NSString *)getAppType; // 获取app名称
- (NSString *)getOsType;  // 获取渠道类型

- (void)skipSendSMS:(NSString *)messageInfo; // 发短信

/*
window.androidObj.skipPhonePicForResult('choosePicCallBack', '/sanhuo/visit/doUpload.do', key);

调用 navtive 拍照和选择相册的图片，选择好后上传
window.androidObj.skipPhonePicForResult(String callBackFun, String url, String key)
url图片上传地址 返回json


callBackFun回调函数 回调函数要传递参数过来 如下
callBackFun(key, json)
json:{‘code’:0 ;‘message’:'';‘data’:‘’}

code : navtive<0 代表native失败 大于0代表服务器失败  0表示服务器成功   url图片上传地址返回json.code=0 表示服务端成功
message: 一种url图片上传地址返回json.message 一种native失败信息
data: 等于'' 就可以
key：传给navtive的key 再次返回就可以
*/

- (void)skipPhone:(NSString *)callBackFun PicFor:(NSString *)url Result:(NSString *)key; // 上传图片


//sendMsgToWX 换成 sendMSGToWX

/*
window.androidObj.sendMsgToWX(String key, String callBackFun, String url, String title, String description, String imgUrl, boolean isTimelineCb)
callBackFun回调函数 回调函数要传递参数过来 如下
callBackFun(key, json) 返回传入的key和结果json，
json:{‘code’:0 ;‘message’:'';‘data’:‘’}
code==0是分享成功 <0 失败
messge 失败的消息
‘data’:‘’

url长度大于0且不超过10KB
title限制长度不超过512Bytes
description限制长度不超过1KB
imgUrl加载后的图片不得超过32K
isTimelineCb  true分享至朋友圈  false分享至好友
 */

// 分享微信
- (void)send:(NSString *)key
           M:(NSString *)callBackFun
           S:(NSString *)url
           G:(NSString *)title
          To:(NSString *)description
           W:(NSString *)imgUrl
           X:(BOOL)isTimelineCb;


- (NSString *)getLoginAccount; // h5获取登录信息
- (void)setLogin:(NSString *)userName Account:(NSString *)pass; // 用户名,密码保存到本地

@end

@interface GWWeChatShareInfo : NSObject

@property (nonatomic,copy) NSString *key;
@property (nonatomic,copy) NSString *callBackFun;

@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *title;

@property (nonatomic,copy) NSString *desc;
@property (nonatomic,copy) NSString *imgUrl;

@property (nonatomic,assign) BOOL isTimelineCb;

@end

@interface GWJSObjectInfo : NSObject <JavaScriptObjectiveCDelegate>

@property (nonatomic, weak) JSContext *jsContext;
@property (nonatomic, weak) UIWebView *webView;

@property (nonatomic, copy) void(^popMessageViewController)(NSString *message);
@property (nonatomic, copy) void(^uploadPicture)(NSString *callBackFun,NSString *url, NSString *key);

@property (nonatomic, copy) void(^weChatShareAction)(GWWeChatShareInfo *weChatShareInfo);


@property (nonatomic,strong) GWWeChatShareInfo *weChatShareInfo;

@end
