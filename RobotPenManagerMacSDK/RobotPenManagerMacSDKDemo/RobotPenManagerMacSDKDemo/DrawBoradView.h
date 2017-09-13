//
//  DrawBoradView.h
//  Mac-OS-USB
//
//  Created by nb616 on 2017/7/20.
//  Copyright © 2017年 CNDotaIsBestDota. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <RobotPenManagerMacSDK/RobotPenManager.h>

@interface DrawBoradView : NSView

/**
 绘制笔迹

 @param point <#point description#>
 */
- (void)getOptimizesPointInfo:(RobotPenUtilPoint *)point;

/**
 清空画布
 */
- (void)clearAll;

@end
