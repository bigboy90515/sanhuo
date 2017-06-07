//
//  GWLauchingViewController.m
//  GitManageTest
//
//  Created by liangscofield on 2016/12/2.
//  Copyright © 2016年 liangscofield. All rights reserved.
//

#import "GWLauchingViewController.h"

#define WeakObjectDef(obj) __weak typeof(obj) weak##obj = obj

@interface GWLauchingViewController ()

@property (nonatomic,strong) UIImageView *cuurentImageView;

@end

@implementation GWLauchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *pImageView = [[UIImageView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    pImageView.image = [UIImage imageNamed:@"settingUp.jpg"];
    self.cuurentImageView = pImageView;
    
    [[UIApplication sharedApplication].keyWindow addSubview:pImageView];
    
    WeakObjectDef(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself handleCurrentImageState];
    });
}

- (void)handleCurrentImageState
{
    [self.cuurentImageView removeFromSuperview];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(finishShowingLaunchingPic:)]) {
        [self.delegate finishShowingLaunchingPic:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
