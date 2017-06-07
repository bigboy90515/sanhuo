//
//  GWHomeViewController.m
//  GitManageTest
//
//  Created by liangscofield on 16/11/4.
//  Copyright © 2016年 liangscofield. All rights reserved.
//

#import "GWHomeViewController.h"
#import "AFHTTPSessionManager.h"
#import "GWJSObjectInfo.h"

#import <JavaScriptCore/JavaScriptCore.h>
#import <MessageUI/MessageUI.h>

#import "WXApi.h"
#import "WechatAuthSDK.h"
#import "WXApiObject.h"

//#define kMainHostUrl @"http://feidan.chinalogisticscenter.com:8080/feidanstaff"

#define kMainHostUrl @"http://feidan.chinalogisticscenter.com/feidanstaff"
#define kHomeUrl @"/sanhuo/visit/index.do"
#define kMainURL [NSString stringWithFormat:@"%@%@",kMainHostUrl,kHomeUrl]

#define kNewDownloadUrl @"https://itunes.apple.com/cn/app/ji-zhuang-xiang-dai-huo/id1179226832?mt=8"

#define WeakObjectDef(obj) __weak typeof(obj) weak##obj = obj

@interface GWHomeViewController ()
<UIWebViewDelegate,
UIAlertViewDelegate,
MFMessageComposeViewControllerDelegate,
UIActionSheetDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate>
{
    UIImagePickerController *_imagePickerController;
    BOOL _firstLoadUrlFinshed;
}

@property (nonatomic,copy) NSString *downloadUrl;
@property (nonatomic,strong) UIWebView *currentWebView;

@property (nonatomic,strong) JSContext *context;

@property (nonatomic,copy) NSString *currentCallBackFun;
@property (nonatomic,copy) NSString *currentUrl;
@property (nonatomic,copy) NSString *currentKey;

@property (nonatomic,strong) GWWeChatShareInfo *weChatShareInfo;

@end

@implementation GWHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"飞单";
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    webView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    webView.scrollView.bounces = NO;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kMainURL]];
    [webView loadRequest:request];
    self.currentWebView = webView;
    [self.view addSubview:webView];
    
    UIView *topHeaderView = [UIView new];
    topHeaderView.backgroundColor = [UIColor whiteColor];
    topHeaderView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 20);
    [self.view addSubview:topHeaderView];
    
    WeakObjectDef(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself getAppVersionInfo];
    });
    
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    _imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    _imagePickerController.allowsEditing = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self startLoading];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self stopLoading];
    [self jsInteractionAction];
    
    
    NSString *currentUrlStr = webView.request.URL.absoluteString;
    NSLog(@"webView location = '%@'", currentUrlStr);
    
    if ([currentUrlStr containsString:kHomeUrl] && !_firstLoadUrlFinshed)
    {
        _firstLoadUrlFinshed = YES;
        [self refreshWebview];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self stopLoading];
    
    if (error.code == -999) {
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)jsInteractionAction
{
    WeakObjectDef(self);
    self.context = [self.currentWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    GWJSObjectInfo *model  = [[GWJSObjectInfo alloc] init];
    self.context[@"androidObj"] = model;

    model.jsContext = self.context;
    model.webView = self.currentWebView;
    [model setPopMessageViewController:^(NSString *message){
        [weakself showMessageView:nil title:nil body:message];
    }];
    [model setUploadPicture:^(NSString *callBackFun,NSString *url, NSString *key){
        [weakself skipPhonePicForResult:callBackFun url:url key:key];
    }];
    [model setWeChatShareAction:^(GWWeChatShareInfo *weChatShareInfo){
        [weakself handleShareAction:weChatShareInfo];
    }];
    
    self.context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
}

- (void)getAppVersionInfo
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"]; // app名称
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"]; // app版本
    NSString *appBuild = [infoDictionary objectForKey:@"CFBundleVersion"];  // app build版本
    
    NSLog(@"appName %@  appVersion %@  appBuild %@",appName,appVersion,appBuild);
    
    NSString *getAppVersionStr = [NSString stringWithFormat:@"%@/sanhuo/api/appUpgrade.do?appType=ios&appVersion=%@",kMainHostUrl,appVersion];
    
    
    WeakObjectDef(self);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:getAppVersionStr
      parameters:nil
        progress:^(NSProgress * _Nonnull downloadProgress) {}
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             [weakself handleCurrentSuccessfulInfo:task responseObject:responseObject];
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){}];
}

- (void)handleCurrentSuccessfulInfo:(NSURLSessionDataTask *)task responseObject:(id)responseObject
{
    NSHTTPURLResponse * taskresponse =(NSHTTPURLResponse *) task.response;
    NSLog(@"(long)taskresponse.statusCodegetimgarr  %ld",(long)taskresponse.statusCode );
    
    if ((long)taskresponse.statusCode == 200) {
        NSDictionary * dic = (NSDictionary * )responseObject;
        if ([dic [@"code"] intValue] == 0) {
            NSString *upgradeStr = dic[@"data"][@"upgrade"]; //是否需要升级
            NSString *forceUpgradeStr = dic[@"data"][@"forceUpgrade"]; //是否强制升级
            self.downloadUrl = dic[@"data"][@"downUrl"]; //下载地址
            NSString *remark = dic[@"data"][@"remark"]; //下载描述
            remark = [remark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
//            upgradeStr = @"y";
//            forceUpgradeStr = @"n";
//            
//            self.downloadUrl = kNewDownloadUrl;
            
            remark = remark.length == 0 ? @"发现新版本,现在就去升级~" : remark;
            
            if ([upgradeStr isEqualToString:@"y"]) { // 需要升级
                
                if ([forceUpgradeStr isEqualToString:@"y"]) {// 强制升级
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:remark
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                    alert.tag = 0x888;
                    [alert show];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:remark
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:@"取消"
                                                          otherButtonTitles:@"确定",nil];
                    alert.tag = 0x999;
                    [alert show];
                }
                
            }
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0x999 && buttonIndex == 0)
        return;
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.downloadUrl]];
}


// 参数phones：发短信的手机号码的数组，数组中是一个即单发,多个即群发。
-(void)showMessageView:(NSArray *)phones
                 title:(NSString *)title
                  body:(NSString *)body
{
    if([MFMessageComposeViewController canSendText]) {
  
        dispatch_async(dispatch_get_main_queue(), ^{
            
            MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
            controller.recipients = phones;
            controller.navigationBar.tintColor = [UIColor redColor];
            controller.body = body;
            controller.messageComposeDelegate = self;
            [[[[controller viewControllers] lastObject] navigationItem] setTitle:title];//修改短信界面标题
            [self presentViewController:controller animated:YES completion:nil];
        });

    } else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"该设备不支持短信功能"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        });
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];

    NSString *showText = nil;
    switch(result) {
        case
        MessageComposeResultSent:
        showText = @"信息发送成功";
            break;
        case
        MessageComposeResultFailed:
            showText = @"信息发送失败";
            break;
        case
        MessageComposeResultCancelled:
            showText = @"信息发送取消";
            break;
        default:
            break;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                    message:showText
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)skipPhonePicForResult:(NSString *)callBackFun url:(NSString *)url key:(NSString *)key
{
    self.currentCallBackFun = callBackFun;
    self.currentUrl = url;
    self.currentKey = key;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIActionSheet *pActionSheet = [[UIActionSheet alloc] initWithTitle:@"您要选择?"
                                                                  delegate:self
                                                         cancelButtonTitle:@"取消"
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:@"拍照上传",@"相册上传", nil];
        [pActionSheet showInView:self.view];
    });
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:_imagePickerController animated:YES completion:nil];
        });


    }
    else if (buttonIndex == 1)
    {
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:_imagePickerController animated:YES completion:nil];
        });
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo
{
    NSLog(@"选择完毕----image:%@-----info:%@",image,editingInfo);
    
    [self uploadImageFunWithImage:image];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    
}

- (void)uploadImageFunWithImage:(UIImage *)image
{
    [self startLoadingWithMessage:@"上传图片中" withAnimated:YES];
    WeakObjectDef(self);

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //接收类型不一致请替换一致text/html或别的
    
    NSDictionary *parameters =@{@"key":self.currentKey};

    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"image/jpeg",@"image/png",@"application/octet-stream",@"text/json",nil];
    
    NSString *uploadPicUrl = [NSString stringWithFormat:@"%@%@",kMainHostUrl,self.currentUrl];
    
    [manager POST:uploadPicUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
        
        NSData *imageData = UIImageJPEGRepresentation(image,0.8);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat =@"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
        
        
        //上传的参数(上传图片，以文件流的格式)
        [formData appendPartWithFileData:imageData
                                    name:self.currentKey
                                fileName:fileName
                                mimeType:@"image/jpeg"];
        
    } progress:^(NSProgress *_Nonnull uploadProgress) {
        
        NSLog(@"上传进度  %2f", uploadProgress.completedUnitCount/(CGFloat)uploadProgress.totalUnitCount);
        
    } success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"上传成功");
        [weakself stopLoading];
        [self progressHUD].labelText = @"加载中...";

        
        NSHTTPURLResponse * taskresponse =(NSHTTPURLResponse *) task.response;
        NSLog(@"(long)taskresponse.statusCodegetimgarr  %ld",(long)taskresponse.statusCode );
        
        if ((long)taskresponse.statusCode == 200)
        {
            NSDictionary * dic = (NSDictionary * )responseObject;
            NSString *curMsg = dic[@"message"];
            NSString *curCode = dic[@"code"];

            NSString *keyValue = [NSString stringWithFormat:@"{\"code\":\"%@\",\"message\":\"%@\",\"data\":\"\"}",curCode,curMsg];
            
            JSValue *squareFunc = self.context[self.currentCallBackFun];
            [squareFunc callWithArguments:@[self.currentKey,keyValue]];
        }
        
    } failure:^(NSURLSessionDataTask *_Nullable task, NSError * _Nonnull error) {

        NSLog(@"上传失败");
        [weakself stopLoading];
        [self progressHUD].labelText = @"加载中...";
        
    }];
    
}

- (void)handleShareAction:(GWWeChatShareInfo *)weChatShareInfo
{
    if ([WXApi isWXAppInstalled] == NO) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"你还没有安装微信,请先安装!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        });
        
    } else {
        
        self.weChatShareInfo = weChatShareInfo;
        
        WXMediaMessage *message = [WXMediaMessage message];
        message.description = weChatShareInfo.desc;
        message.title = weChatShareInfo.title;
        NSUInteger maxLenTitle = 256;
        if (message.title.length > maxLenTitle) {
            message.title = [message.title substringToIndex:maxLenTitle-1];
        }
        
        NSUInteger maxLen = 500;
        if (message.description.length > maxLen) {
            message.description = [message.description substringToIndex:maxLen-1];
        }
        UIImage *defaultImage = [UIImage imageNamed:@"logo"];
        NSData *thumbData = UIImageJPEGRepresentation(defaultImage, 0.9);
        
        [message setThumbData:thumbData];
        
        WXWebpageObject* webPageObject = [WXWebpageObject object];
        webPageObject.webpageUrl = weChatShareInfo.url;
        message.mediaObject = webPageObject;

        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = weChatShareInfo.isTimelineCb ? WXSceneTimeline : WXSceneSession;
        [WXApi sendReq:req];
        
    }
}

- (void)refreshWebview
{
    NSString *currentUrlStr = self.currentWebView.request.URL.absoluteString;
    NSLog(@"webView location = '%@'", currentUrlStr);
    
    // 只有是首页的时候 刷新
    if([currentUrlStr containsString:kHomeUrl])
    {
        [self.currentWebView reload];
    }
}

- (void)shareCallBackFun:(NSInteger)rspCode withMsg:(NSString *)msg
{
    if (!self.weChatShareInfo) {
        return;
    }
    
    NSString *keyValue = [NSString stringWithFormat:@"{\"code\":\"%ld\",\"message\":\"%@\",\"data\":\"\"}",(long)rspCode,msg];
    JSValue *squareFunc = self.context[self.weChatShareInfo.callBackFun];
    [squareFunc callWithArguments:@[self.weChatShareInfo.key,keyValue]];
}

- (NSUInteger)getNumber
{
    return 100;
}

@end
