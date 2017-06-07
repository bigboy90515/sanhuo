//
//  GWLauchingViewController.h
//  GitManageTest
//
//  Created by liangscofield on 2016/12/2.
//  Copyright © 2016年 liangscofield. All rights reserved.
//

#import "GWBaseViewController.h"

@class GWLauchingViewController;
@protocol GWLauchingViewControllerDelegate <NSObject>
- (void)finishShowingLaunchingPic:(GWLauchingViewController *)pLauchingViewController;
@end

@interface GWLauchingViewController : GWBaseViewController
@property (nonatomic,weak) id<GWLauchingViewControllerDelegate> delegate;

@end
