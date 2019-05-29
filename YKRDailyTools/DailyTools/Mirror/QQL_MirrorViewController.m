//
//  QQL_MirrorViewController.m
//  DailyTools
//
//  Created by 乾龙 on 2018/10/23.
//  Copyright © 2018 秦乾龙. All rights reserved.
//

#import "QQL_MirrorViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
@interface QQL_MirrorViewController () <UIGestureRecognizerDelegate>

// 拍照图像展示层
@property (nonatomic, strong) CALayer *showImageLayer;              // 拍照图像展示层

// 相机层
@property (nonatomic, assign) BOOL captureFlashModeOn;              // 开关闪光灯
@property (nonatomic, assign) BOOL isFrontCamera;                   //当前是否是前摄像头
@property (nonatomic, readonly) BOOL canTakePicture;                //当前是否可以拍照


// 相机
@property (nonatomic, strong) AVCaptureDevice *device;//捕获设备，前、后置摄像头
@property (nonatomic, strong) AVCaptureDeviceInput *input;//输入设备,用device初始化
@property (nonatomic, strong) AVCaptureMetadataOutput *output;//当启动摄像头开始捕获输入
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutPut;
@property (nonatomic, strong) AVCaptureSession *session;//结合输入输出，并开始启动捕获设备
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;//图像预览层

@property (nonatomic, assign) BOOL isCapturing;                     // 是否捕获中

/**
 *  记录开始的缩放比例
 */
@property(nonatomic,assign)CGFloat beginGestureScale;
/**
 * 最后的缩放比例
 */
@property(nonatomic,assign)CGFloat effectiveScale;

@property (nonatomic, strong) UISlider *slider;

// 切换前后摄像头
- (void)changeCamera;

// 开始捕获图像
- (void)startCapture;

@end

@implementation QQL_MirrorViewController

- (void)preConfigCamera
{
    AVCaptureDevicePosition position = self.isFrontCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    self.device = [self cameraWithPosition:position];
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    self.output = [[AVCaptureMetadataOutput alloc] init];
    self.imageOutPut = [[AVCaptureStillImageOutput alloc] init];
    self.session = [[AVCaptureSession alloc] init];
    if ([self.session canAddInput:self.input]) [self.session addInput:self.input];
    if ([self.session canAddOutput:self.imageOutPut]) [self.session addOutput:self.imageOutPut];
    
    [self setSessionPreset];//设置分辨率 自动识别
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = self.view.bounds;
    
    //AVLayerVideoGravityResizeAspect  等比例填充，直到一个维度到达区域边界。保持视频的宽高比并使播放内容自动适应播放窗口的大小。
    //AVLayerVideoGravityResizeAspectFill 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪 (测试发现内容居中，即裁剪掉的为单维度两极的部分)
    //AVLayerVideoGravityResize 非均匀模式。拉伸 两个维度完全填充至整个视图区域
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];     // 摄像机捕获内容展示层
    if ([self.device lockForConfiguration:nil])
    {
        if ([self.device isFlashModeSupported:AVCaptureFlashModeOff])
        {
            [self.device setFlashMode:AVCaptureFlashModeOff];
        }
        self.captureFlashModeOn = NO;
        //自动白平衡
        if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance])
        {
            [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [self.device unlockForConfiguration];
    }
    
}

- (void)startCapture
{
    [self.session startRunning];
    self.isCapturing = YES;
}

// 切换前后摄像头
- (void)changeCamera
{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1)
    {
        CATransition *animation = [CATransition animation];
        animation.duration = 0.5f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"oglFlip";
        
        BOOL isback = NO;
        AVCaptureDevice *newCamera = nil;
        AVCaptureDevicePosition position = [[self.input device] position];
        if (position == AVCaptureDevicePositionFront)
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
            isback = YES;
        }
        else
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
        }
        
        NSError *error;
        AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:&error];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil)
        {
            [self.session beginConfiguration];
            [self.session removeInput:self.input];
            if ([self.session canAddInput:newInput])
            {
                [self.session addInput:newInput];
                self.input = newInput;
            }
            else
            {
                [self.session addInput:self.input];
            }
            [self setSessionPreset];
            [self.session commitConfiguration];
            self.isFrontCamera = !isback;
        }
        else if (error)
        {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}
// 设置分辨率
- (void)setSessionPreset
{
    NSMutableArray *array = [NSMutableArray array];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
    {
#ifdef __IPHONE_9_0
        [array addObject:AVCaptureSessionPreset3840x2160];
#endif
    }
    
    // AVCaptureSessionPresetPhoto 不支持视频
    NSArray *arr = @[AVCaptureSessionPresetPhoto,
                     AVCaptureSessionPreset1920x1080,
                     AVCaptureSessionPreset1280x720,
                     AVCaptureSessionPreset640x480,
                     AVCaptureSessionPreset352x288];
    [array addObjectsFromArray:arr];
    
    for (NSString *preset in array)
    {
        if ([self.session canSetSessionPreset:preset])
        {
            self.session.sessionPreset = preset;
            NSLog(@"重设摄像头分辨率%@", preset);
            break;
        }
    }
}

//解决图片方向不对问题
- (UIImage *)fixImageOrientation:(UIImage *)aImage
{
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
        {
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        }
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        {
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        }
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        {
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        }
        default:
            break;
    }
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
        {
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        }
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
        {
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        }
        default:
            break;
    }
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height, CGImageGetBitsPerComponent(aImage.CGImage), 0, CGImageGetColorSpace(aImage.CGImage), CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        {
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
        }
        default:
        {
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
        }
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (BOOL)canTakePicture
{
    return self.isCapturing;
}

// 摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ( device.position == position )
            return device;
    }
    return nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    if (_isFangdajing) {
        self.isFrontCamera = NO;
    }else{
        self.isFrontCamera = YES;
    }
    
    [self preConfigCamera];
    [self startCapture];
    
    [self.view addSubview:[self backSliderView]];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
    _beginGestureScale = 1;
    _effectiveScale = 1;
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeSystem)];
    button.tintColor = [UIColor whiteColor];
    button.frame = CGRectMake(15, 35, 37, 37);
    [button setImage:[UIImage imageNamed:@"tool_fanhui_left"] forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
}

- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures
{
    return UIRectEdgeAll;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    self.beginGestureScale = self.effectiveScale;
    return YES;
}

- (void)pinch:(UIPinchGestureRecognizer *)recognizer
{
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.view];
        CGPoint convertedLocation = [self.previewLayer convertPoint:location fromLayer:self.previewLayer.superlayer];
        if ( ! [self.previewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if ( allTouchesAreOnThePreviewLayer ) {
        
        self.effectiveScale = self.beginGestureScale * recognizer.scale;
        if (self.effectiveScale < 1.0){
            self.effectiveScale = 1.0;
        }
        if (self.effectiveScale > 3.5) {
            return;
        }
        
        _slider.value = _effectiveScale;
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
        [CATransaction commit];
    }
}

- (void)buttonClick:(UIButton *)button
{
    [button removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView *)backSliderView
{
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-30, SCREEN_WIDTH, 20)];
    // 滑动条slider
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(30, 0, SCREEN_WIDTH-60, 20)];
    _slider.minimumValue = 1;// 设置最小值
    _slider.maximumValue = 3;// 设置最大值
    _slider.value = 1;// 设置初始值
    _slider.continuous = YES;// 设置可连续变化
    _slider.minimumTrackTintColor = [UIColor whiteColor]; //滑轮左边颜色，如果设置了左边的图片就不会显示
    _slider.maximumTrackTintColor = [UIColor whiteColor]; //滑轮右边颜色，如果设置了右边的图片就不会显示
    _slider.thumbTintColor = [UIColor yellowColor];//设置了滑轮的颜色，如果设置了滑轮的样式图片就不会显示
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
    [backView addSubview:_slider];
    
    return backView;
}

- (void)sliderValueChanged:(UISlider *)slider
{
    self.effectiveScale = slider.value;
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale)];
    [CATransaction commit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
