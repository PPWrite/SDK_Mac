//
//  ViewController.m
//  RobotPenManagerMacSDKDemo
//
//  Created by JMS on 2017/7/24.
//  Copyright © 2017年 JMS. All rights reserved.
//

#import "ViewController.h"
#import <RobotMacPenSDK/RobotPenManager.h>
#import "WhiteBoardController.h"
@interface ViewController ()<RobotPenDelegate>
{
    RobotPenDevice *theLastDevice;//存储最后发现的设备，用于连接
    RobotPenDevice *CurDevice;//当前连接的设备
}
@property (weak) IBOutlet NSTextField *deviceName;  // 设备名称
@property (weak) IBOutlet NSTextField *battery;     // 电量
@property (weak) IBOutlet NSTextField *SWstr;       // 硬件号
@property (weak) IBOutlet NSTextField *deviceType;  //设备类型

@property (strong , nonatomic) WhiteBoardController *wbController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置SDK类型
    [[RobotPenManager sharePenManager] setMACSDKModel:BLEModel];
    
    //遵守协议
    [[RobotPenManager sharePenManager] setPenDelegate:self];
    //SDK方法 设置报点类型，此处设置为优化点报点，需要上报优化点和转换点则必须设置
    [[RobotPenManager sharePenManager] setOrigina:NO optimize:YES transform:NO];
    
    //SDK方法 设置场景尺寸，isOriginal = NO时必须设置
    [[RobotPenManager sharePenManager] setSceneSizeWithWidth:VALUE_A5_HEIGHT andHeight:VALUE_A5_WIDTH andIsHorizontal:NO];
    
    //SDK方法 设置笔迹宽度，isOptimize = YES时必须设置，即显示宽度
    [[RobotPenManager sharePenManager] setStrokeWidth:1.2];
    
    //开启优化点模式后，开启原始点上报
    [[RobotPenManager sharePenManager] setSendOriginalPointWhenIsOptimize:YES];

   
}

#pragma mark RobotPenManagerDelegate

/**
 获取原始点

 @param point 点
 */
- (void)getPointInfo:(RobotPenPoint *)point
{

//    NSLog(@"original point = %@",point);
    
}

/**
 获取优化点

 @param point 点
 */
- (void)getOptimizesPointInfo:(RobotPenUtilPoint *)point
{
    //转换为mac坐标
    point.optimizeX = [point changeMacPointWithIsHorizontal:NO].x;
    point.optimizeY = [point changeMacPointWithIsHorizontal:NO].y;
    //画线
    [self.wbController whiteBoardDrawView:point];
}

/**
 获取设备状态

 @param State 设备状态
 */
- (void)getDeviceState:(DeviceState)State
{
    switch (State) {
        case DEVICE_CONNECT_FAIL:{
            NSLog(@"设备连接失败");
            break;
        }
        case DEVICE_CONNECTE_SUCCESS:{
            NSLog(@"设备连接成功");
            break;
        }
        case DEVICE_DISCONNECTED:{
            NSLog(@"设备断开");
            CurDevice = nil;
            self.deviceName.stringValue = [NSString stringWithFormat:@"%@",CurDevice.deviceName];
            self.SWstr.stringValue = [NSString stringWithFormat:@"%@",CurDevice.SWStr];
            self.deviceType.stringValue = [NSString stringWithFormat:@"%d",CurDevice.deviceType];
            self.battery.stringValue = [NSString stringWithFormat:@"%d",CurDevice.Battery];
            break;
        }
        case DEVICE_INFO_END:{
            NSLog(@"获取信息成功");
            CurDevice = [[RobotPenManager sharePenManager] getConnectDevice];
            self.deviceName.stringValue = [NSString stringWithFormat:@"%@",CurDevice.deviceName];
            self.SWstr.stringValue = [NSString stringWithFormat:@"%@",CurDevice.SWStr];
            self.deviceType.stringValue = [NSString stringWithFormat:@"%d",CurDevice.deviceType];
            self.battery.stringValue = [NSString stringWithFormat:@"%d",CurDevice.Battery];
            break;
        }
        
        default:
            break;
    }

}

/**
 发现电磁板设备

 @param device 设备
 */
- (void)getBufferDevice:(RobotPenDevice *)device
{
     NSLog(@"device = %@",device);
    if (device.model == 1) {//usb模型
        
        if (device.MacSign == 1) {// MacSign = 1表示插入 0 表示拔出
            theLastDevice = device;
        }
        else
        {
            theLastDevice = nil;
        }
        
    }else//ble模式
    {
        //可做设备列表，此处只做演示用
        theLastDevice = device;
    }

}


#pragma Private Method
/**
 连接设备

 @param sender button
 */
- (IBAction)connectUSB:(id)sender {
    [[RobotPenManager sharePenManager] connectDevice:theLastDevice];
}


/**
 断开连接

 @param sender button
 */
- (IBAction)disConnectUSB:(id)sender {
    [[RobotPenManager sharePenManager] disconnectDevice];
}


/**
 打开画板

 @param sender button
 */
- (IBAction)openDrawBorad:(id)sender {
    
    WhiteBoardController *wb = [[WhiteBoardController alloc] initWithWindowNibName:@"WhiteBoardController"];
    self.wbController = wb;
    [wb showWindow:self];
    
}

/**
 搜索设备（BLE专用）
 
 @param sender button
 */
- (IBAction)scanUSB:(id)sender {
    [[RobotPenManager sharePenManager] scanDeviceWithALL:NO];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
