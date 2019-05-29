//
//  QQL_CompassView.h
//  DailyTools
//
//  Created by 乾龙 on 2018/10/23.
//  Copyright © 2018 秦乾龙. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QQL_CompassView : UIView
/**
 *  初始化
 *
 *  @param radius 半径（最小不小于50，最大不大于控件短边的一半）
 *
 *  @return 返回罗盘对象
 */
+ (instancetype)sharedWithRect:(CGRect)rect radius:(CGFloat)radius;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *calibrationColor;
@property (nonatomic, strong) UIColor *northColor;
@property (nonatomic, strong) UIColor *horizontalColor;
@end

NS_ASSUME_NONNULL_END
