//
//  UIControl+Category.h
//  TestProject
//
//  Created by LY on 2017/1/19.
//  Copyright © 2017年 LY. All rights reserved.
//

#import <UIKit/UIKit.h>

// 回调代码块
typedef void(^UIControlActionBlock)(UIControlEvents events);


@interface UIControl (Block_Handle)

/** block处理事件 - 相对于第三方的BlocksKit,能集中处理不同事件响应并区分各事件 */
- (void)handleControlEvents:(UIControlEvents)events withBlock:(UIControlActionBlock)block;

/** 移除不需要的 handle block */
- (void)removeHandleForControlEvents:(UIControlEvents)events;

/** 检测events与原有事件集是否有冲突, 有则返回对应冲突事件, 否则返回0 */
- (UIControlEvents)checkEventsClash:(UIControlEvents)events;

@end



