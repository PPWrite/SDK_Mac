//
//  WhiteBoardController.h
//  RobotPenManagerMacSDKDemo
//
//  Created by JMS on 2017/8/31.
//  Copyright © 2017年 JMS. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <RobotPenMac/RobotPenMac.h>
//#import "RobotPenManager.h"
@interface WhiteBoardController : NSWindowController
- (void)whiteBoardDrawWithPoint:(RobotPenPoint *)point;
- (void)whiteBoardDrawWithOptimize:(RobotPenUtilPoint *)point;
@end

