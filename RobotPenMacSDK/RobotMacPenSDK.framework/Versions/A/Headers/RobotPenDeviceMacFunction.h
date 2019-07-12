//
//  RobotPenDeviceMacFunction.h
//  RobotMacPenSDK
//
//  Created by JMS on 2019/4/4.
//  Copyright © 2019 JMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RobotPenDeviceMacFunction : NSObject
/*!
 @property
 @brief 支持USB设备
 */
@property (nonatomic, assign) BOOL USBDevice;
/*!
 @property
 @brief 进入USB模式的方式
 */
@property (nonatomic, assign) int enterUSBType;
/*!
 @property
 @brief 获取信息
 */
@property (nonatomic, assign) BOOL getDeviceInfo;
/*!
 @property
 @brief 支持鼠标模式 
 */
@property (nonatomic, assign) int mouseMode;
/*!
 @property
 @brief 支持按键切换模式
 */
@property (nonatomic, assign) BOOL keysMode;
/*!
 @property
 @brief 旧版本信息结构
 */
@property (nonatomic, assign) BOOL oldInformationStructure;
/*!
 @property
 @brief 旧版本消息结构
 */
@property (nonatomic, assign) BOOL oldMessageStructure;
/*!
 @property
 @brief 同步数据结构
 */
@property (nonatomic, assign) int OTAStructure;
/*!
 @property
 @brief 获取模组信息
 */
@property (nonatomic, assign) BOOL getModuleVersion;
/*!
 @property
 @brief 其他
 */
@property (nonatomic, assign) int other;

@end
