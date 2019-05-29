//
//  QQL_CorrectViewController.m
//  DailyTools
//
//  Created by 乾龙 on 2018/10/23.
//  Copyright © 2018 秦乾龙. All rights reserved.
//

#import "QQL_CorrectViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface ZJ_HangerView : UIView

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

// 初始化
- (ZJ_HangerView *)initWithFrame:(CGRect)frame frontCamera:(BOOL)isFront;

// 切换前后摄像头
- (void)changeCamera;

// 开始捕获图像
- (void)startCapture;

@end

@implementation ZJ_HangerView

- (instancetype)initWithFrame:(CGRect)frame frontCamera:(BOOL)isFront
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor blackColor];
        self.isFrontCamera = isFront;
        [self preConfigCamera];
    }
    return self;
}

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
    self.previewLayer.frame = self.bounds;
    
    //AVLayerVideoGravityResizeAspect  等比例填充，直到一个维度到达区域边界。保持视频的宽高比并使播放内容自动适应播放窗口的大小。
    //AVLayerVideoGravityResizeAspectFill 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪 (测试发现内容居中，即裁剪掉的为单维度两极的部分)
    //AVLayerVideoGravityResize 非均匀模式。拉伸 两个维度完全填充至整个视图区域
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:self.previewLayer];     // 摄像机捕获内容展示层
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

@end

#import <CoreMotion/CoreMotion.h>

@interface QQL_CorrectViewController ()

@property (nonatomic, strong) ZJ_HangerView *LyView;
@property (nonatomic,retain)UIImageView *arrowImageView;
@property (nonatomic,retain) CMMotionManager *motionManager;

@end

@implementation QQL_CorrectViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.motionManager stopAccelerometerUpdates];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _LyView = [[ZJ_HangerView alloc] initWithFrame:self.view.bounds frontCamera:NO];
    [self.view addSubview:_LyView];
    [_LyView startCapture];
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeSystem)];
    button.tintColor = [UIColor whiteColor];
    button.frame = CGRectMake(15, 35, 37, 37);
    [button setImage:[UIImage imageNamed:@"tool_fanhui_left"] forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
    
    self.arrowImageView =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"guhua"]];
    self.arrowImageView.frame = CGRectMake(SCREEN_WIDTH-200, 40, 165, 165);
    
    [self.view addSubview:self.arrowImageView];
    self.motionManager = [[CMMotionManager alloc]init];
    if (!self.motionManager.accelerometerAvailable) {
        // fail code // 检查传感器到底在设备上是否可用
    }
    self.motionManager.accelerometerUpdateInterval = 0.01; // 告诉manager，更新频率是100Hz
    
    /* 加速度传感器开始采样，每次采样结果在block中处理 */
    // 开始更新，后台线程开始运行。
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
     {
         // 获取系统在X、Y、Z轴上的加速度数据
         CMAccelerometerData *newestAccel = self.motionManager.accelerometerData;
         double accelerationX = newestAccel.acceleration.x;
         double accelerationY = newestAccel.acceleration.y;
         double ra = atan2(-accelerationY, accelerationX);
         self.arrowImageView.transform = CGAffineTransformMakeRotation(ra - M_PI_2);
         
     }];
    
}

- (void)buttonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
