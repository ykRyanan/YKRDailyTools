//
//  YKRSizeHeader.h
//  YKRDailyTools
//
//  Created by MAC on 2019/5/29.
//  Copyright © 2019 ykRyan. All rights reserved.
//

#ifndef YKRSizeHeader_h
#define YKRSizeHeader_h

/*************** 尺寸 *******************/
#define ScreemW [UIScreen mainScreen].bounds.size.width
#define ScreemH [UIScreen mainScreen].bounds.size.height
#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double )480) < DBL_EPSILON )
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double )568) < DBL_EPSILON )
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double )667) < DBL_EPSILON )
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double )960) < DBL_EPSILON )
#define StatusHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define NavHeight    self.navigationController.navigationBar.frame.size.height
#define NavStaH      (StatusHeight+NavHeight)
#define SafeAreaBottomHeight (ScreemH >= 812.0 ? 34 : 0)
#define TabbarH (ScreemH >= 812.0 ? 83 : 49)
#define kIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

//以iphone7为例  定义 view相关的宽高宏
#define ptHeight7(b) (kIsiPhoneX ? [UIScreen mainScreen].bounds.size.height*((b)/812.0) : [UIScreen mainScreen].bounds.size.height*((b)/667.0))
#define ptWidth7(a) [UIScreen mainScreen].bounds.size.width*((a)/375.0)

#endif /* YKRSizeHeader_h */
