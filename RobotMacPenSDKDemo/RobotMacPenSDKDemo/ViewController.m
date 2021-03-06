//
//  ViewController.m
//  RobotMacPenSDKDemo
//
//  Created by Caffrey on 2020/4/7.
//  Copyright © 2020 robot. All rights reserved.
//

#import "ViewController.h"
#import <RobotPenMac/RobotPenMac.h>
#import "RPTableCell.h"

/// 信息
@interface ViewController ()<RobotPenDelegate,NSTableViewDelegate,NSTableViewDataSource,NSAlertDelegate>
/// 设备数据源
@property (strong , nonatomic) NSMutableArray *dataSource;
/// 笔记列表
@property (strong , nonatomic) NSMutableArray *noteListArr;
/// 已连接的设备
@property (strong , nonatomic) RobotPenDevice *connectDevice;

@property (weak) IBOutlet NSTableView *tableView;
/// 设备名称
@property (weak) IBOutlet NSTextField *deviceName;
/// 设备版本号
@property (weak) IBOutlet NSTextField *versionLabel;
/// 按键事件
@property (weak) IBOutlet NSTextField *eventLabel;
/// 软件版本号
@property (weak) IBOutlet NSTextField *demoVersionLabel;
/// 笔坐标
@property (weak) IBOutlet NSTextField *penPointLabel;
/// 笔压力值
@property (weak) IBOutlet NSTextField *penPressureLabel;
/// 设备电量
@property (weak) IBOutlet NSTextField *batteryLabel;
/// 设备信号值
@property (weak) IBOutlet NSTextField *deviceRSSILabel;

/// 搜索设备
@property (weak) IBOutlet NSButton *scanButton;
/// USB/BLE模式
@property (weak) IBOutlet NSButton *sdkModalButton;
/// 连接/断开设备
@property (weak) IBOutlet NSButton *connectButton;
/// 开启/关闭优化按钮
@property (weak) IBOutlet NSButton *openOptimizesButton;
/// 打开白板
@property (weak) IBOutlet NSButton *openWhiteBoardButton;
/// 开启切换按钮
@property (weak) IBOutlet NSButton *openPermissionsButton;
/// 切换模式按钮
@property (weak) IBOutlet NSButton *changeModalButton;
@property (weak) IBOutlet NSButton *otaUpdateButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.changeModalButton.usesSingleLineMode = NO;
    //SDK模式
    [[RobotPenManager sharePenManager] setMACSDKModel:USBModel];
    //遵守协议
    [[RobotPenManager sharePenManager] setPenDelegate:self];

    _demoVersionLabel.stringValue = [NSString stringWithFormat:@"V:%@",[[RobotPenManager sharePenManager] getSDKVersion]];
}

#pragma Mark ------RobotPenDelegate--------
/// 获取设备状态
- (void)getDeviceState:(DeviceState)State DeviceUUID:(NSString *)uuid {
    NSLog(@"getDeviceState = %d",State);
    switch (State) {
        case DEVICE_CONNECT_FAIL: {
            [[RobotPenManager sharePenManager] scanDeviceWithALL:NO];
        } break;

        case DEVICE_DISCONNECTED: {
            self.connectDevice = nil;
            [self reloadUI];
        } break;

        case DEVICE_INFO_END: {
            self.connectDevice = [[RobotPenManager sharePenManager] getConnectDevice];
            [self reloadUI];
            if (self.connectDevice.deviceType == C7) {
                [[RobotPenManager sharePenManager] OpenReportedData];
            }
        } break;

        case DEVICE_UPDATE: {
            [[RobotPenManager sharePenManager] getIsNeedUpdate];
        } break;

        case DEVICE_UPDATE_CAN: {
            self.otaUpdateButton.hidden = NO;
        }
            break;
        default: break;
    }
}

/// 发现设备
- (void)getBufferDevice:(RobotPenDevice *)device {
    if ([[RobotPenManager sharePenManager] getMACSDKModel] == USBModel && device.MacSign == 0) {
        // 拔出
        [self.dataSource removeAllObjects];
        self.connectDevice = nil;
        [self reloadUI];
    } else {
        [self.dataSource addObject:device];
    }

    [self.tableView reloadData];
}

/// 获取原始点数据
- (void)getPointInfo:(RobotPenPoint *)point {
    self.penPointLabel.stringValue = [NSString stringWithFormat:@"%d, %d", point.originalX, point.originalY];
    self.penPressureLabel.stringValue = [NSString stringWithFormat:@"%d",  point.pressure];
}

/// 设备当前模式
- (void)getMouseDeviceModel:(RobotPenMouseDeviceModel)model {
    NSLog(@"当前模式 = %@",model == HandModel?@"书写模式":@"鼠标模式" );
}

/// 设备按键事件
- (void)getDeviceEvent:(DeviceEventType)Type {
    self.eventLabel.stringValue = [NSString stringWithFormat:@"%d",Type];
}

- (void)OTAUpdateState:(OTAState)state {
    NSLog(@"升级状态 %d", state);
}

- (void)OTAUpdateProgress:(float)progess {
    NSLog(@"升级进度 %f", progess);
}

- (void)robotPenReceivedDevicePrimitivePoint:(RobotDeviceOriginPoint)point {
    NSLog(@"点 {%d, %d} 压力:%d 状态:%d", point.x, point.y, point.p, point.s);
}

#pragma mark ------PrivateMethod--------
- (void)reloadUI {
    self.deviceName.stringValue = [NSString stringWithFormat:@"%@", self.connectDevice ? self.connectDevice.deviceName : @""];
    self.versionLabel.stringValue = [NSString stringWithFormat:@"%@", self.connectDevice ?self.connectDevice.SWStr : @""];
    self.batteryLabel.stringValue = [NSString stringWithFormat:@"%d", self.connectDevice.Battery];
    self.deviceRSSILabel.stringValue = [NSString stringWithFormat:@"%d",self.connectDevice.RSSI];

    [self.connectButton setTitle:self.connectDevice?@"断开设备":@"连接设备"];

    self.openOptimizesButton.hidden = self.connectDevice?NO:YES;
    self.openWhiteBoardButton.hidden = self.connectDevice?NO:YES;

    self.openPermissionsButton.hidden = !self.connectDevice.macFunction.keysMode;
    self.changeModalButton.hidden = self.connectDevice.macFunction.mouseMode != 2;

    if (!self.connectDevice) {
        [self.openOptimizesButton setTitle:@"开启优化"];
        [[RobotPenManager sharePenManager] setOrigina:YES optimize:NO transform:NO];

        [[RobotPenManager sharePenManager] setDeviceModeSwipe:NO];
        [self.openPermissionsButton setTitle:@"开启切换"];
    }
}

/// 搜索设备
- (IBAction)scanButtonAction:(id)sender {
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    if (self.connectDevice) {
        self.otaUpdateButton.hidden = YES;
        [[RobotPenManager sharePenManager] disconnectDevice];
    }
    [[RobotPenManager sharePenManager] scanDeviceWithALL:NO];
}

/// USB/BLE模式
- (IBAction)sdkModalButtonAction:(id)sender {
    if ([self.sdkModalButton.title isEqualToString:@"USB模式"]) {
        [self.sdkModalButton setTitle:@"BLE模式"];
        [[RobotPenManager sharePenManager] setMACSDKModel:USBModel];
        [[RobotPenManager sharePenManager] setPenDelegate:self];
        //为了打印硬件原始点，所以开启
        [[RobotPenManager sharePenManager] openReportDevicePrimitivePointData:YES];
    } else {
        [self.sdkModalButton setTitle:@"USB模式"];
        [[RobotPenManager sharePenManager] setMACSDKModel:BLEModel];
        [[RobotPenManager sharePenManager] setPenDelegate:self];
        //为了打印硬件原始点，所以开启
        [[RobotPenManager sharePenManager] openReportDevicePrimitivePointData:YES];
    }
}

/// 连接/断开设备
- (IBAction)connectButtonAction:(NSButton *)sender {
    self.otaUpdateButton.hidden = YES;

    if ([self.connectButton.title isEqualToString:@"连接设备"]) {
        if (self.dataSource.count) {
            RobotPenDevice *device = [self selectedModel];
            if (device) {
                [[RobotPenManager sharePenManager] connectDevice:device];
            }
        }
    } else {
        if (self.connectDevice) {
            [[RobotPenManager sharePenManager] disconnectDevice];
        }
    }
}

/// 开启切换按钮
- (IBAction)openPermissionsButtonAction:(id)sender {
    if ([self.openPermissionsButton.title isEqualToString:@"开启切换"]) {
        [[RobotPenManager sharePenManager] setDeviceModeSwipe:YES];
        [self.openPermissionsButton setTitle:@"关闭切换"];
        self.changeModalButton.usesSingleLineMode = YES;
    } else {
        [[RobotPenManager sharePenManager] setDeviceModeSwipe:NO];
        [self.openPermissionsButton setTitle:@"开启切换"];
        self.changeModalButton.usesSingleLineMode = NO;
    }
}

/// 切换模式按钮
- (IBAction)changeModalButtonAction:(id)sender {
    if ([[RobotPenManager sharePenManager] getMouseDeviceMode] == MouseModel) {
        [[RobotPenManager sharePenManager] changeMouseDeviceMode:HandModel];
    } else {
        [[RobotPenManager sharePenManager] changeMouseDeviceMode:MouseModel];
    }
}

- (IBAction)startOTAUpdateButtonAction:(id)sender {
    if ([[RobotPenManager sharePenManager] getConnectDevice]) {
        [[RobotPenManager sharePenManager] startOTA];
    }
}

#pragma mark ------ConfigUI-------
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:10];
    }

    return _dataSource;
}

- (RobotPenDevice *)selectedModel {
    NSInteger select = [self.tableView selectedRow];
    if (select >= 0 && self.dataSource.count >select) {
        RobotPenDevice *device = [self.dataSource objectAtIndex:select];
        return device;
    }

    return nil;
}

#pragma mark ------TabelViewDelegate------
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.dataSource.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    RPTableCell *cell = [tableView makeViewWithIdentifier:@"tablerow" owner:self];
    cell.model = self.dataSource[row];
    return cell;
}

@end
