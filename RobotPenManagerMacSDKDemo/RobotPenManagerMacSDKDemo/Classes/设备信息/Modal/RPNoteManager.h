//
//  RPNoteManager.h
//  RobotPenManagerMacSDKDemo
//
//  Created by JMS on 2017/9/1.
//  Copyright © 2017年 JMS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RobotMacPenSDK/RobotPenManager.h>
#import <RobotMacPenSDK/RobotSqlManager.h>
@interface RPNoteManager : NSObject
/**
 根据不同设备获取画布尺寸
 @param DeviceType 设备类型
 @return size
 */
+ (CGSize)obtainWindowSize:(int)DeviceType;

/**
 创建笔记名称
 @param DeviceType 设备类型
 @return string
 */
+ (NSString *)obtainNoteTitle:(int)DeviceType;

/**
 获取笔记列表
 */
+ (void)obtainNotelistData:(void(^)(NSArray *data))block;


/**
 获取笔迹
 */
+ (void)obtainNoteTrailData:(RobotNote *)note block:(void(^)(NSArray *data))block;

/**
 创建Notekey
 @return string
 */
+ (NSString *)createFileIdent;
@end
