//
//  UIViewController+Loading.m
//  YXPharmacyMarket
//
//  Created by Ricky on 2019/3/20.
//

#import "UIViewController+Loading.h"
#import <objc/runtime.h>

#define SCREEN_WIDTH        [UIScreen mainScreen].bounds.size.width
#define RGBA(r,g,b,a)       [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define reallySize(size)    SCREEN_WIDTH / 750.0f * size
///当前控制器视图宽度
#define view_width           self.view.frame.size.width
///当前控制器视图高度
#define view_height          self.view.frame.size.height

///gif布局宽度
#define gif_width            reallySize(200)
///gif布局高度
#define gif_height           reallySize(200)

///错误图片宽度
#define error_image_width    reallySize(200)
///错误图片高度
#define error_image_height   reallySize(200)

#define error_text           @"加载出错了，请再试一次~"
///提示文字高度
#define error_label_height   reallySize(80)

///重新加载按钮宽度
#define error_button_width   reallySize(340)
///重新加载按钮高度
#define error_button_height  reallySize(80)
///按钮背景颜色
#define error_button_color   RGBA(241,2,21,1)

@implementation UIViewController (Loading)

#pragma mark - 生命周期
+ (void)load {
    Method method1 = class_getInstanceMethod([self class], @selector(custom_viewDidLoad));
    Method method2 = class_getInstanceMethod([self class], @selector(viewDidLoad));
    if (!class_addMethod([UILabel class], @selector(awakeFromNib), method_getImplementation(method1), method_getTypeEncoding(method2))) {
        method_exchangeImplementations(method1, method2);
    } else {
        class_replaceMethod(self, @selector(custom_viewDidLoad), method_getImplementation(method2), method_getTypeEncoding(method2));
    }
}
- (void)custom_viewDidLoad
{
    [self custom_viewDidLoad];
    self.requestCount = 0;
    self.requestError = NO;
}

#pragma mark - 事件
///计数+1
- (void)increaseCount
{
    self.requestCount ++;
    ///如果当前页面没有loading，先添加
    if (self.loadingGif == nil) {
        [self loading_addLoadingGif];
    }
    ///开始动画
    [self loading_renderLoading];
}
///计数-1
- (void)reduceCount{
    ///计数已经为0 return
    if (self.requestCount == 0) {
        return;
    }
    self.requestCount --;
    ///结束动画
    [self loading_renderLoading];
    
}
///重置网络计数
- (void)resetCount{
    self.requestCount = 0;
}
///加载错误
- (void)loadingError{
    self.requestError = YES;
    if (self.errorView == nil) {
        [self loading_addErrorView];
    }
    [self loading_stopAnimation];
    self.errorView.hidden = NO;
}
///重新加载
- (void)loading_buttonClick
{
    ///这个地方需要获取到你的网络请求类的实例对象，取消网络请求管理器的所有网络请求
    self.requestError = NO;
    [self resetCount];
    [self loading_reloadData];
}

///重新发起请求 在各个控制器重写这个方法 接收重新加载事件
- (void)loading_reloadData
{
    
}
#pragma mark - UI相关
///渲染UI 添加前缀 防止覆盖
- (void)loading_renderLoading
{
    NSLog(@"当前网络请求计数:%d",self.requestCount);
    ///已经错误
    if (self.requestError) {
        return;
    }
    ///如果计数为0 关闭动画
    if (self.requestCount == 0) {
        [self loading_stopAnimation];
    }
    ///否则  开启动画
    else
    {
        [self loading_startAnimation];
    }
}
///添加loading
- (void)loading_addLoadingGif
{
    UIImageView * loadingGif = [[UIImageView alloc]initWithFrame:CGRectMake((view_width - gif_width) / 2, (view_height - gif_height) / 2, gif_width, gif_height)];
    NSArray * imagesArray = [self loading_getGifImageArray];
    loadingGif.image = imagesArray.firstObject;
    loadingGif.animationImages = imagesArray;
    //时间
    loadingGif.animationDuration = 1;
    loadingGif.animationRepeatCount = 0;//动画进行几次结束
    self.loadingGif = loadingGif;
    [self.view addSubview:self.loadingGif];
}
///添加errorView
- (void)loading_addErrorView
{
    //全屏铺满白色背景
    UIView * errorView = [[UIView alloc]initWithFrame:CGRectMake( 0, 0, view_width, view_height)];
    errorView.backgroundColor = [UIColor whiteColor];
    
    CGFloat totalHeight = error_image_height + error_label_height + error_button_height;//图片+文字+按钮高度
    CGFloat image_x = (view_width - error_image_width) / 2;
    CGFloat image_y = (view_height - totalHeight) / 2;
    CGFloat button_x = (view_width - error_button_width) / 2;
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(image_x, image_y, error_image_width, error_image_height)];
    imageView.image = [UIImage imageNamed:@"icon_loading_error"];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, image_y + error_image_height, view_width, error_label_height)];
    label.text = error_text;
    label.adjustsFontSizeToFitWidth = YES;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(button_x, image_y + error_image_height + error_label_height, error_button_width, error_button_height)];
    [button setTitle:@"重新加载" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:error_button_color];
    button.layer.cornerRadius = 4;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:@selector(loading_buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [errorView addSubview:imageView];
    [errorView addSubview:label];
    [errorView addSubview:button];
    
    self.errorView = errorView;
    [self.view addSubview:self.errorView];
}

///开始动画
- (void)loading_startAnimation
{
    if (self.loadingGif != nil) {
        self.loadingGif.hidden = NO;
        [self.loadingGif startAnimating];
    }
    //如果errorView已经被渲染  则隐藏
    if (self.errorView != nil) {
        self.errorView.hidden = YES;
    }
}

///隐藏动画
- (void)loading_stopAnimation
{
    if (self.loadingGif != nil) {
        self.loadingGif.hidden = YES;
        [self.loadingGif stopAnimating];
    }
}
#pragma mark - 获取gif的图片组
///获取图片数组
- (NSArray *)loading_getGifImageArray
{
    //获取图片根据图片大小进行切割
    NSURL * gifUrl = [[NSBundle mainBundle] URLForResource:@"icon_loading_gif" withExtension:@"GIF"];
    
    //获取Gif图的原数据
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)gifUrl, NULL);
    
    //获取Gif图有多少帧
    size_t gifcount = CGImageSourceGetCount(gifSource);
    
    //得到图片数组
    NSMutableArray * imageArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i < gifcount; i++) {
        //由数据源gifSource生成一张CGImageRef类型的图片
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        [imageArray addObject:image];
        CGImageRelease(imageRef);
    }
    return imageArray;
}

#pragma mark - Set Get
- (void)setLoadingGif:(UIImageView *)loadingGif
{
    objc_setAssociatedObject(self, "GifKey", loadingGif, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIImageView *)loadingGif
{
    return objc_getAssociatedObject(self, "GifKey");
}

- (void)setErrorView:(UIImageView *)errorView
{
    objc_setAssociatedObject(self, "ErrorViewKey", errorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIView *)errorView
{
    return objc_getAssociatedObject(self, "ErrorViewKey");
}

- (void)setRequestCount:(int)requestCount
{
    objc_setAssociatedObject(self, "CountKey", @(requestCount), OBJC_ASSOCIATION_ASSIGN);
}
- (int)requestCount
{
    return [objc_getAssociatedObject(self, "CountKey") intValue];
}

- (void)setRequestError:(BOOL)requestError
{
    objc_setAssociatedObject(self, "ErrorKey", @(requestError), OBJC_ASSOCIATION_ASSIGN);
}
- (BOOL)requestError
{
    return [objc_getAssociatedObject(self, "ErrorKey") boolValue];
}
@end
