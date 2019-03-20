//
//  UIViewController+Loading.h
//  YXPharmacyMarket
//
//  Created by Ricky on 2019/3/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Loading)

@property (nonatomic ,strong)UIImageView * loadingGif;//!<loading动画
@property (nonatomic ,strong)UIView * errorView;//!<加载错误,重新加载

@property (nonatomic ,assign)int requestCount;//!<请求计数
@property (nonatomic ,assign)BOOL requestError;//!<请求出错

///网络请求计数+1
- (void)increaseCount;

///网络请求计数-1
- (void)reduceCount;

///加载错误视图
- (void)loadingError;

///刷新回调
- (void)loading_reloadData;


@end

NS_ASSUME_NONNULL_END
