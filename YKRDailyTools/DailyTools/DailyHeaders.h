//
//  DailyHeaders.h
//  TFQ_Loan
//
//  Created by MAC on 2019/5/27.
//  Copyright © 2019 com.lj.tfq. All rights reserved.
//

#ifndef DailyHeaders_h
#define DailyHeaders_h

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define kStatesNavHeight ([[UIApplication sharedApplication] statusBarFrame].size.height + 44)
#define UICOLORFROMRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#endif /* DailyHeaders_h */
