//
//  GWHomeViewController.h
//  GitManageTest
//
//  Created by liangscofield on 16/11/4.
//  Copyright © 2016年 liangscofield. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GWBaseViewController.h"

//13761455626
//111111

//15000271714  123456

@interface GWHomeViewController : GWBaseViewController


- (NSUInteger)getNumber;


/**
 刷新网页
 */
- (void)refreshWebview;


/**
 分享的回调

 @param rspCode 错误码
 @param msg 错误描述
 */
- (void)shareCallBackFun:(NSInteger)rspCode withMsg:(NSString *)msg;


@end
