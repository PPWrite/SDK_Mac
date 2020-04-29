//
//  RPTableCell.h
//  RobotPenManagerMacSDKDemo
//
//  Created by JMS on 2017/8/30.
//  Copyright © 2017年 JMS. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <RobotPenMac/RobotPenMac.h>
//#import "RobotPenDevice.h"

@interface RPTableCell : NSTableCellView
@property (strong ,nonatomic) RobotPenDevice *model;
@end
