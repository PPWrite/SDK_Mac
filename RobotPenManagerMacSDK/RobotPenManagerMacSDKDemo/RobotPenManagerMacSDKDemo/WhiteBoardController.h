//
//  WhiteBoardController.h
//  RobotPenManagerMacSDKDemo
//
//  Created by nb616 on 2017/8/31.
//  Copyright © 2017年 JMS. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <RobotPenManagerMacSDK/RobotPenManager.h>
@interface WhiteBoardController : NSWindowController
- (void)whiteBoardDrawView:(RobotPenUtilPoint *)point;
@end
