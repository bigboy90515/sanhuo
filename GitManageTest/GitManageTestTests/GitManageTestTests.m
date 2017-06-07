//
//  GitManageTestTests.m
//  GitManageTestTests
//
//  Created by liangscofield on 16/11/4.
//  Copyright © 2016年 liangscofield. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GWHomeViewController.h"

@interface GitManageTestTests : XCTestCase

@property (nonatomic,strong) GWHomeViewController *vc;

@end

@implementation GitManageTestTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // 实例化需要测试的类
    self.vc = [[GWHomeViewController alloc] init];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    // 清空
    self.vc = nil;
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    // 调用需要测试的方法，
    NSInteger result = [self.vc getNumber];
    // 如果不相等则会提示@“测试不通过”
    XCTAssertEqual(result, 110,@"测试不通过");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        
        for (int i = 0; i < 1000; i++) {
            NSLog(@"2222");
        }
        
    }];
}

@end
