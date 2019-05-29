//
//  QQL_NetSpeedView.m
//  DailyTools
//
//  Created by 乾龙 on 2018/10/23.
//  Copyright © 2018 秦乾龙. All rights reserved.
//

#import "QQL_NetSpeedView.h"
// 位置适配
#define ZMScacle (w/([UIScreen mainScreen].bounds.size.width-40))
#define ZM_SPACE(x) ((x) * ZMScacle)

@implementation QQL_NetSpeedView

- (id)init
{
    self = [super init];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
    }
    return self;
}

- (void)show{
    
    //背景图片
    UIImageView *imageV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cesuzhi"]];
    imageV.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    [self addSubview:imageV];
    
    // 指针
    CALayer *needleLayer = [CALayer layer];
    // 设置锚点位置
    needleLayer.anchorPoint = CGPointMake(0.5, 1.0);
    CGFloat w = CGRectGetWidth(self.frame);
    // 锚点在父视图上面的位置
    needleLayer.position = imageV.center;
    // bounds
    needleLayer.bounds = CGRectMake(0, 0, ZM_SPACE(5), ZM_SPACE(85));
    // 添加图片53*57
    needleLayer.contents = (id)[UIImage imageNamed:@"cwszhizhen"].CGImage;
    [self.layer addSublayer:needleLayer];
    needleLayer.transform = CATransform3DMakeRotation(-0.75*M_PI, 0, 0, 1);
    _needleLayer = needleLayer;
}

@end
