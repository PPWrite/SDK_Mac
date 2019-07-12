//
//  DrawBoradView.h
//  Mac-OS-USB
//
//  Created by JMS on 2017/7/20.
//  Copyright © 2017年 CNDotaIsBestDota. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <RobotMacPenSDK/RobotPenManager.h>
//#import "RobotPenManager.h"
@interface DrawBoradView : NSView

/**
 绘制原始笔迹
 
 @param point <#point description#>
 */
- (void)drawOriginalPoint:(RobotPenPoint *)point;
/**
 绘制优化笔迹
 
 @param point <#point description#>
 */
- (void)drawOptimizesPoint:(RobotPenUtilPoint *)point;
/**
 清空画布
 */
- (void)clearAll;
@end
