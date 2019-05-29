//
//  QQL_CompassView.m
//  DailyTools
//
//  Created by 乾龙 on 2018/10/23.
//  Copyright © 2018 秦乾龙. All rights reserved.
//

#import "QQL_CompassView.h"
#import "QQL_CompassManage.h"

#define toRad(X) (X*M_PI/180.0)
#define toDeg(X) (X*180.0/M_PI)
#define defaultRadius 100

#define LineWidth 10

@interface QQL_CompassView ()

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) CGFloat scale;

@property (nonatomic, weak) UIImageView *pointerImageView;
@property (nonatomic, weak) UIView *dialView;

@property (nonatomic, strong) QQL_CompassManage *manager;

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *northLabel;

@end

@implementation QQL_CompassView

+ (instancetype)sharedWithRect:(CGRect)rect radius:(CGFloat)radius
{
    return [[self alloc]initWithFrame:rect radius:radius];
}

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius
{
    if (self = [super initWithFrame:frame]) {
        _point = CGPointMake(frame.size.width/2, frame.size.height/2-50);
        _radius = radius;
        _scale = radius/100;
        _textColor = [UIColor blackColor];
        _calibrationColor = [UIColor blackColor];
        _northColor = [UIColor redColor];
        [self customUI];
        [self startSensor];
    }
    return self;
}

- (void)customUI
{
    [self createDial];
    [self createPointer];
    [self createCalibration];
    [self resetSize];
}


/**
 *  重置尺寸
 */
- (void)resetSize
{
    _dialView.transform = CGAffineTransformScale(_dialView.transform, _scale, _scale);
}


/**
 *  创建表盘
 */
- (void)createDial
{
    UIView *dialView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, defaultRadius*2, defaultRadius*2)];
    dialView.center = _point;
    _dialView = dialView;
    [self addSubview:_dialView];
    
}

/**
 *  创建刻度
 */
- (void)createCalibration
{
    CGFloat perAngle = M_PI/90;
    
    NSArray *array = @[@"北",@"东",@"南",@"西"];
    
    for (int i = 0; i < 180; i++) {
        
        CGFloat startAngle = (-M_PI_2+perAngle*i);
        CGFloat endAngle = startAngle+perAngle/2;
        
        UIBezierPath *bezPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_dialView.frame.size.width/2, _dialView.frame.size.height/2)
                                                               radius:defaultRadius*0.75
                                                           startAngle:startAngle
                                                             endAngle:endAngle
                                                            clockwise:YES];
        
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        
        if (i == 0) {
            shapeLayer.strokeColor = _northColor.CGColor;
            shapeLayer.lineWidth = LineWidth;
        }else if (i%15 == 0) {
            shapeLayer.strokeColor = _calibrationColor.CGColor;
            shapeLayer.lineWidth = LineWidth;
        }else{
            shapeLayer.strokeColor = CGColorCreateCopyWithAlpha(_calibrationColor.CGColor, 0.6);
            shapeLayer.lineWidth = LineWidth;
        }
        
        shapeLayer.path = bezPath.CGPath;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        [_dialView.layer addSublayer:shapeLayer];
        
        if (i%45 == 0){
            NSString *tickText = array[i/45];
            if (i < 180) {
                CGFloat textAngel = startAngle+(endAngle-startAngle)/2;
                CGPoint point = [self calculateTextPositonWithArcCenter:CGPointMake(_dialView.frame.size.width/2, _dialView.frame.size.height/2)
                                                                  Angle:textAngel Xishu:0.55];
                
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(point.x, point.y, 25, 15)];
                label.center = point;
                label.text = tickText;
                label.textColor = _textColor;
                label.font = [UIFont systemFontOfSize:13];
                label.textAlignment = NSTextAlignmentCenter;
                label.transform = CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)toRad(i * 2));
                
                [_dialView addSubview:label];
            }
        }
        
        
        
        
        if (i%15 == 0){
            
            NSString *tickText = [NSString stringWithFormat:@"%d",i * 2];
            
            if (i < 180) {
                CGFloat textAngel = startAngle+(endAngle-startAngle)/2;
                NSLog(@"%.5f",textAngel);
                CGPoint point = [self calculateTextPositonWithArcCenter:CGPointMake(_dialView.frame.size.width/2, _dialView.frame.size.height/2)
                                                                  Angle:textAngel Xishu:0.95];
                
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(point.x, point.y, 25, 15)];
                label.center = point;
                label.text = tickText;
                label.textColor = _textColor;
                label.font = [UIFont systemFontOfSize:9];
                label.textAlignment = NSTextAlignmentCenter;
                label.transform = CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)toRad(i * 2));
                
                [_dialView addSubview:label];
            }
            
        }
    }
}

/**
 *  创建指针
 */
- (void)createPointer
{
    
    UIImageView *pointerImageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    pointerImageView1.center = CGPointMake(_dialView.frame.size.width/2, _dialView.frame.size.height/2);
    [pointerImageView1 setImage:[UIImage imageNamed:@"zhenxiaobg"]];
    [_dialView addSubview:pointerImageView1];
    [_dialView bringSubviewToFront:pointerImageView1];
    
    UIImageView *pointerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 22, 164)];
    pointerImageView.center = _point;
    [pointerImageView setImage:[UIImage imageNamed:@"zhinanzhenzhen"]];
    _pointerImageView = pointerImageView;
    [self addSubview:_pointerImageView];
    
//    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 20)];
//    tipLabel.textAlignment = NSTextAlignmentCenter;
//    tipLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
//    tipLabel.text = [NSString stringWithFormat:@"海拔%@米",[ZJ_CityModel defaultZJ_CityModel].haiba];
//    tipLabel.textColor = [UIColor whiteColor];
//    [self addSubview:tipLabel];
//
//    UILabel *tip1Label = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-80, SCREEN_WIDTH, 20)];
//    tip1Label.textAlignment = NSTextAlignmentCenter;
//    tip1Label.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
//    tip1Label.text = [NSString stringWithFormat:@"北纬：%@°  东经：%@°",[ZJ_CityModel defaultZJ_CityModel].weidu,[ZJ_CityModel defaultZJ_CityModel].jindu];
//    tip1Label.textColor = [UIColor whiteColor];
//    [self addSubview:tip1Label];
//
//    UILabel *tip2Label = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-90, SCREEN_HEIGHT-170, 180, 70)];
//    tip2Label.textAlignment = NSTextAlignmentCenter;
//    tip2Label.font = [UIFont systemFontOfSize:70];
//    tip2Label.textColor = [UIColor whiteColor];
//    [self addSubview:tip2Label];
//    _tipLabel = tip2Label;
//
//    UILabel *tip3Label = [[UILabel alloc] initWithFrame:CGRectMake(tip2Label.frame.size.width + tip2Label.frame.origin.x-20, SCREEN_HEIGHT-170, 50, 20)];
//    tip3Label.textAlignment = NSTextAlignmentCenter;
//    tip3Label.font = [UIFont systemFontOfSize:15];
//    tip3Label.textColor = [UIColor whiteColor];
//    [self addSubview:tip3Label];
//    _northLabel = tip3Label;
}

- (NSString *)getFangxiangWithTheHeading:(CGFloat)heading
{
    if ((heading > 0 && heading < 30) || (heading > 330 && heading < 360)) {
        return @"北";
    }
    
    if (heading > 30 && heading < 60) {
        return @"东北";
    }
    
    if (heading > 60 && heading < 120) {
        return @"东";
    }
    
    if (heading > 120 && heading < 150) {
        return @"东南";
    }
    
    if (heading > 150 && heading < 210) {
        return @"南";
    }
    
    if (heading > 210 && heading < 240) {
        return @"西南";
    }
    
    if (heading > 240 && heading < 300) {
        return @"西";
    }
    
    if (heading > 300 && heading < 330) {
        return @"西北";
    }
    
    return @"";
}

/**
 *  启动传感器
 */
- (void)startSensor
{
    __weak typeof(self)mySelf = self;
    _manager = [QQL_CompassManage shared];
    
    _manager.didUpdateHeadingBlock = ^(CLLocationDirection theHeading){
        [mySelf updateHeading:theHeading];
    };
    
    [_manager startSensor];
}


- (void)updateHeading:(CLLocationDirection)theHeading
{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         CGAffineTransform headingRotation;
                         headingRotation = CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)-toRad(theHeading));
                         
                         headingRotation = CGAffineTransformScale(headingRotation, _scale, _scale);
                         _dialView.transform = headingRotation;
                         _tipLabel.text = [NSString stringWithFormat:@"%.0f°",theHeading];
                         _northLabel.text = [self getFangxiangWithTheHeading:theHeading];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    // Animate Pointer
    [UIView animateWithDuration:0.6
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         CGAffineTransform headingRotation;
                         headingRotation = CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)toRad(0)-toRad(theHeading));
                         
                         headingRotation = CGAffineTransformScale(headingRotation, _scale, _scale);
                         _tipLabel.text = [NSString stringWithFormat:@"%.0f°",theHeading];
                         _northLabel.text = [self getFangxiangWithTheHeading:theHeading];
                         _dialView.transform = headingRotation;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}



//计算中心坐标
- (CGPoint)calculateTextPositonWithArcCenter:(CGPoint)center
                                       Angle:(CGFloat)angel
                                       Xishu:(CGFloat)xishu
{
    
    CGFloat x = defaultRadius * xishu * cosf(angel);
    CGFloat y = defaultRadius * xishu * sinf(angel);
    
    return CGPointMake(center.x + x, center.y + y);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - 设置属性
- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [self removeAll];
    [self customUI];
}

- (void)setCalibrationColor:(UIColor *)calibrationColor
{
    _calibrationColor = calibrationColor;
    [self removeAll];
    [self customUI];
}

- (void)setNorthColor:(UIColor *)northColor
{
    _northColor = northColor;
    [self removeAll];
    [self customUI];
}

- (void)removeAll
{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}


@end
