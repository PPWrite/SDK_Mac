//
//  RobotPenDevice.h
//  RobotPenManagerMacSDKDemo
//
//  Created by JMS on 2017/8/17.
//  Copyright © 2017年 JMS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RobotPenDeviceFunction.h"
#import "RobotPenDeviceMacFunction.h"
#import <CoreBluetooth/CoreBluetooth.h>

#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC

#include <IOKit/hid/IOHIDLib.h>

#endif


@interface RobotPenDevice : NSObject<NSCoding>
/*!
 @property
 @brief 设备类型
 */
@property(nonatomic, assign) DeviceType deviceType;
/*!
 @property
 @brief 设备类型名称
 */
@property(nonatomic, copy) NSString *deviceTypeName;
/*!
 @property
 @brief UUID
 */
@property(copy, nonatomic) NSString *uuID;
/*!
 @property
 @brief MAC地址
 */
@property(copy, nonatomic) NSString *Mac;
/*!
 @property
 @brief 硬件版本
 */
@property(nonatomic, copy) NSString *HWStr;
/*!
 @property
 @brief 固件版本
 */
@property(nonatomic, copy) NSString *SWStr;
/*!
 @property
 @brief 模组版本
 */
@property(nonatomic, copy) NSString *MWStr;
/*!
 @property
 @brief 电池电量 (1-7个等级)
 1 == 0格 电量<5%
 2 == 1格 5%<=电量<20%
 3 == 1格 20%<=电量<40%
 4 == 2格 40%<=电量<60%
 5 == 3格 60%<=电量<80%
 6 == 4格 80%<=电量<100%
 7 == 4格 电量 = 100%
 254:充电中
 255:已充满
 */
@property(nonatomic, assign) int Battery;
/*!
 @property
 @brief 设备名称
 */
@property(nonatomic, copy) NSString *deviceName;
/*!
 @property
 @brief 设备离线笔记数量
 */
@property(nonatomic, assign) int NoteNumber;
/*!
 @property
 @brief 设备存储百分比（暂时只支持C7设备）
 */
@property(nonatomic, assign) int NoteSroredPercent;
/*!
 @property
 @brief BLE:固件mac标识 USB:0:拔出1:插入
 */
@property(nonatomic, assign) int MacSign;

/*!
 @property
 @brief 附加信息，暂时用于更新搜索设备列表：0：未搜索到 1：已搜索到
 */
@property(nonatomic, assign) int Tags;
/*!
 @property
 @brief 蓝牙
 */
@property(retain, nonatomic) CBPeripheral *peripheral;
/*!
 @property
 @brief 信号强度
 */
@property(nonatomic, assign) int RSSI;
/*!
 @property
 @brief D7点阵类型
 */
@property(nonatomic, assign) RobotLatticeSizeType latticeSizeType;
/*!
@property
@brief 设备状态
*/
@property (nonatomic, assign) RobotPenDeviceStatus status;
/*!
 @property 
 @brief 模型类型 0：ble 1：usb
 @discussion MAC方法
 */
@property(nonatomic, assign) RobotPenMACSDKModel model;
/*!
 @property
 @brief USB
 @discussion MAC方法
 */
@property(nonatomic) IOHIDDeviceRef usbDeviceRef;

/*!
 @property
 @brief 设备功能列表
 */
@property(nonatomic, strong) RobotPenDeviceFunction *function;
/*!
 @property
 @brief 设备Mac功能列表
 */
@property(nonatomic, strong) RobotPenDeviceMacFunction *macFunction;


#pragma mark ---------------------------Tool --------------------------

/*!
 @method
 @abstract 获取设备名
 @result 返回结果
 */
- (NSString *)getName;

/*!
 @method
 @abstract 获取电量百分比显示
 @result 返回结果
 */
- (int)getDevicePercentageBattery;

/*!
 @method
 @abstract 获取笔记前缀字符串
 @result 返回结果
 */
- (NSString *)getPrefixString DEPRECATED_MSG_ATTRIBUTE("Please use RobotPenDevice.deviceTypeName");

/*!
 @method
 @abstract 获取硬件前缀字符串
 @result 返回结果
 */
- (NSString *)getHardPrefixString;


/*!
 @method
 @abstract 根据方向获取屏幕方向获取设备原始宽高
 @param isHorizontal 设备方向
 @result 返回结果
 */
- (CGSize)getDeviceSizeWithIsHorizontal:(BOOL)isHorizontal DEPRECATED_MSG_ATTRIBUTE("Please use RobotPenDevice.function.deviceSize");

/*!
 @method
 @abstract 强制将设备改为A4大小
 */
- (void)foreChangeDeviceToA4Size;

@end
