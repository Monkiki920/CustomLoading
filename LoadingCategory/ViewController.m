//
//  ViewController.m
//  LoadingCategory
//
//  Created by Ricky on 2019/3/20.
//  Copyright © 2019 Ricky. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+Loading.h"

#define WeakSelf            __weak typeof(self) weakSelf = self;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
#pragma mark - 事件
///模拟正常请求 发起网络请求3s后加载完成 结束动画
- (IBAction)normalButtonClick:(id)sender {
    [self increaseCount];
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf reduceCount];
    });
}
///模拟加载错误 3s后加载错误 结束动画
- (IBAction)errorButtonClick:(id)sender {
    [self increaseCount];
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf loadingError];
    });
}
///重写重新加载方法 3s后加载完成 结束动画
- (void)loading_reloadData
{
    [self increaseCount];
    WeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf reduceCount];
    });
}

@end
