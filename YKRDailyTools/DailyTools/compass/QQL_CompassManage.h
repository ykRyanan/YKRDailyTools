//
//  QQL_CompassManage.h
//  DailyTools
//
//  Created by 乾龙 on 2018/10/23.
//  Copyright © 2018 秦乾龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <CoreLocation/CLHeading.h>
#import <CoreMotion/CoreMotion.h>
NS_ASSUME_NONNULL_BEGIN

@interface QQL_CompassManage : NSObject

+ (instancetype)shared;
- (void)startSensor;
- (void)stopSensor;
- (void)startGyroscope;

@property (nonatomic, copy) void (^didUpdateHeadingBlock)(CLLocationDirection theHeading);
@property (nonatomic, copy) void (^updateDeviceMotionBlock)(CMDeviceMotion *data);

@end

NS_ASSUME_NONNULL_END
