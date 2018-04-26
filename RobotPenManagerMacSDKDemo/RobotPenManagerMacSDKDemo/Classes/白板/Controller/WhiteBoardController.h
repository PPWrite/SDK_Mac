//
//  WhiteBoardController.h
//  RobotPenManagerMacSDKDemo
//
//  Created by JMS on 2017/8/31.
//  Copyright © 2017年 JMS. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <RobotMacPenSDK/RobotPenManager.h>

@interface WhiteBoardController : NSWindowController
@property (strong , nonatomic) RobotNote *robotNote;
- (void)whiteBoardDrawView:(RobotPenUtilPoint *)point;
@end

