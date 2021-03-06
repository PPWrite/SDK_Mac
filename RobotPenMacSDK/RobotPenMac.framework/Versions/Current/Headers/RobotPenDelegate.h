//
//  RobotPenBLEDeviceDelegate.h
//  RobotPenManagerMacSDKDemo
//
//  Created by JMS on 2017/8/17.
//  Copyright © 2017年 JMS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RobotPenHeader.h"
#import "RobotNote.h"
#import "RobotTrails.h"
#import "RobotPenDevice.h"
#import "RobotPenPoint.h"
#import "RobotPenUtilPoint.h"

/*!
 @protocol
 @abstract 代理
 @discussion RobotPenManager 代理
 */
@protocol RobotPenDelegate<NSObject>

@optional

#pragma mark 设备监听

/*!
 @method
 @abstract 发现电磁板设备
 @param device 设备
 */
- (void)getBufferDevice:(RobotPenDevice *)device;

/*!
 @method
 @abstract 监听电磁板设备状态
 @param State 状态
 */
- (void)getDeviceState:(DeviceState)State DEPRECATED_MSG_ATTRIBUTE("Please use -(void)getDeviceState:(DeviceState)State DeviceUUID:(NSString *)uuid");

/*!
 @method
 @abstract 监听电磁板设备状态
 @param State 状态
 @param uuid uuid
 */
- (void)getDeviceState:(DeviceState)State DeviceUUID:(NSString *)uuid;

/*!
 @method
 @abstract 设备电磁板点击事件
 @param Type 事件类型
 */
- (void)getDeviceEvent:(DeviceEventType)Type;

/*!
 @method
 @abstract 监听系统状态
 @param State 状态
 */
- (void)getOSDeviceState:(OSDeviceStateType)State;

/*!
 @method 监听已连接设备RSSI
 @abstract 监听已连接设备RSSI,需打开RSSI开关。
 @param RSSI RSSI
 */
- (void)getDeviceRSSI:(NSNumber *)RSSI;

/*!
 @method
 @abstract 获取设备休眠时间
 @discussion T9B/T8C系列专用
 @param time 设备休眠时间 0-65535min
 */
- (void)getDeviceDormantTime:(int)time;

/*!
 @method
 @abstract 获取设备尺寸
 @discussion T8C系列专用
 @param size 设备尺寸
 */
- (void)getDeviceSize:(CGSize)size;

/*!
 @method
 @abstract 获取设备存储扇区
 @discussion T9A_EN系列专用
 @param total 总扇区 单位：byte
 @param free 剩余扇区 单位：byte
 */
- (void)getDeviceSectionTotal:(int)total Free:(int)free;

#pragma mark 数据监听

/*!
 @method
 @abstract 获取原始点数据
 @param point 原始点
 */
- (void)getPointInfo:(RobotPenPoint *)point;

/*!
 @method
 @abstract 获取优化点数据
 @param point 优化点
 */
- (void)getOptimizesPointInfo:(RobotPenUtilPoint *)point;

/*!
 @method
 @abstract 获取优化点路径数据
 @param line 优化点
 */
- (void)getOptimizesPathInfo:(float *)line lenth:(int)lenth;

/*!
 @method
 @abstract 获取点读码数据
 @discussion 点读码专用
 @param bookID 点读数据
 */
- (void)getBookID:(int)bookID;

/*!
 @method
 @abstract 获取设备笔记和页码编号
 @discussion 页码识别设备专用。在x10-b设备上，如果 page == -1，代表纸被拿出。
 @param page 页码编号
 @param NoteId 笔记编号
 */
- (void)getDevicePage:(int)page andNoteId:(int)NoteId;

/*!
 @method
 @abstract 回调纸张偏移，仅仅部分设备支持
 @discussion x10-b设备使用
 @param ofsset 纸张偏移
 @param angle 纸张旋转角度，大于0为顺时针旋转
 */
- (void)robotPenPaperOffset:(CGPoint)ofsset angle:(CGFloat)angle;

/*!
 @method
 @abstract 获取设备笔记页码合并编号
 @discussion T9系列专用
 @param NotePage 笔记页码编号
 */
- (void)getDevicePageNoteIdNumber:(int)NotePage;

/*!
@method
@abstract 收到硬件的最原始的点数据
@discussion 当使用openReportPrimitivePointData开启时，才会执行此回调
@param point 坐标点
*/
- (void)robotPenReceivedDevicePrimitivePoint:(RobotDeviceOriginPoint)point;

#pragma mark 离线笔记监听

/*!
 @method
 @abstract 同步离线笔记状态
 @param state 状态
 */
- (void)SyncState:(SYNCState)state;

/*!
 @method
 @abstract 获取同步笔记的笔记信息
 @param note 笔记
 */
- (void)getSyncNote:(RobotNote *)note;

/*!
 @method
 @abstract  获取离线笔记的笔迹数据
 @param trails 笔迹模型
 */
- (void)getSyncData:(RobotTrails *)trails;

/*!
 @method
 @abstract 离线笔记数据同步进度
 @param length 总大小
 @param curlength 已同步大小
 @param progess 进度
 */
- (void)getSyncDataLength:(int)length andCurDataLength:(int)curlength andProgress:(float)progess;

/*!
 @method 监听笔记数量和电量信息
 @abstract 监听笔记数量和电量信息
 @param num 笔迹数量
 @param battery 电量
 @param percent 存储条数百分比
 */
- (void)getStorageNum:(int)num andBattery:(int)battery andNotePercent:(int)percent;

/*!
 @method
 @abstract 设备主动上报状态、电量
 @param status 设备状态
 @param battery 电量
 */
- (void)robotPenDeviceReportStatus:(RobotPenDeviceStatus)status battery:(int)battery;

/*!
 @method
 @abstract  获取离线笔记的原始笔迹数据（需要验证）
 @param data 笔迹数据
 */
- (void)getSyncOriginalData:(NSData *)data;

/*!
 @method
 @abstract 获取同步离线笔记信息和页码信息
 @discussion T9系列专用
 @param note 笔记信息
 @param page 页码信息
 */
- (void)getTASyncNote:(RobotNote *)note andPage:(int)page;

#pragma mark OTA监听

/*!
 @method
 @abstract OTA升级state
 @param state 状态
 */
- (void)OTAUpdateState:(OTAState)state;

/*!
 @method
 @abstract OTA升级进度
 @param progess 进度
 */
- (void)OTAUpdateProgress:(float)progess;

#pragma mark 模组监听

/*!
 @method
 @abstract SENSOR升级State
 @param state 状态
 */
- (void)SensorUpdateState:(SensorState)state;

/*!
 @method
 @abstract SENSOR升级进度
 @param progess 状态
 */
- (void)SensorUpdateProgress:(float)progess;

#pragma mark MAC专属

/*!
 @method MAC方法
 @abstract 监听设备模式变化
 @param model 设备模型
 */
- (void)getDeviceModel:(RobotPenDeviceModel)model;

/*!
 @method MAC方法
 @abstract 监听鼠标设备模式变化
 @param model 设备模型
 */
- (void)getMouseDeviceModel:(RobotPenMouseDeviceModel)model;

@end


