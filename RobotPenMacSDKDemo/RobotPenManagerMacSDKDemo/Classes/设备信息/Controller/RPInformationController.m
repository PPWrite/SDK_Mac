//
//  RPInformationController.m
//  RobotPenManagerMacSDKDemo
//
//  Created by JMS on 2017/8/30.
//  Copyright © 2017年 JMS. All rights reserved.
//

#import "RPInformationController.h"
#import "RPTableCell.h"
#import "WhiteBoardController.h"
#import <RobotMacPenSDK/RobotPenManager.h>
//#import "RobotPenManager.h"
@interface RPInformationController ()<RobotPenDelegate,NSTableViewDelegate,NSTableViewDataSource,NSAlertDelegate>
@property (strong , nonatomic) NSMutableArray *dataSource;      //设备数据源
@property (strong , nonatomic) NSMutableArray *noteListArr;     //笔记列表
@property (strong , nonatomic) RobotPenDevice *connectDevice;   //已连接的设备

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *deviceName;              //设备名称
@property (weak) IBOutlet NSTextField *versionLabel;            //设备版本号


@property (weak) IBOutlet NSButton *scanButton;//搜索设备
@property (weak) IBOutlet NSButton *sdkModalButton;//USB/BLE模式

@property (weak) IBOutlet NSButton *connectButton;//连接/断开设备
@property (weak) IBOutlet NSButton *openOptimizesButton;//开启/关闭优化按钮

@property (weak) IBOutlet NSButton *openWhiteBoardButton;//打开白板

@property (weak) IBOutlet NSButton *openPermissionsButton;//开启切换按钮
@property (weak) IBOutlet NSButton *changeModalButton;//切换模式按钮

@property (strong , nonatomic) WhiteBoardController *wbController;

@end

@implementation RPInformationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.changeModalButton.usesSingleLineMode = NO;
    //SDK模式
    [[RobotPenManager sharePenManager] setMACSDKModel:USBModel];
    //遵守协议
    [[RobotPenManager sharePenManager] setPenDelegate:self];
}

#pragma Mark ------RobotPenDelegate--------
/**
 获取设备状态
 @param State 设备状态
 */
- (void)getDeviceState:(DeviceState)State {
    NSLog(@"getDeviceState = %d",State);
    switch (State) {
        case DEVICE_CONNECT_FAIL:
        {
            [[RobotPenManager sharePenManager] scanDeviceWithALL:NO];
        }
            break;
        case DEVICE_DISCONNECTED:
        {
            self.connectDevice = nil;
            [self reloadUI];
        }
            break;
        case DEVICE_INFO_END:
        {
            self.connectDevice = [[RobotPenManager sharePenManager] getConnectDevice];
            [self reloadUI];
        }
            break;
            case DEVICE_UPDATE:
        {
            [[RobotPenManager sharePenManager] getIsNeedUpdate];
        }
    }
}
/**
 发现设备
 @param device 设备
 */
- (void)getBufferDevice:(RobotPenDevice *)device {
    if (device.MacSign == 0) {// 拔出
        [self.dataSource removeAllObjects];
        self.connectDevice = nil;
        [self reloadUI];
    }else
    {
        [self.dataSource addObject:device];
    }
    [self.tableView reloadData];
}
/**
 获取原始点
 @param point 点
 */
- (void)getPointInfo:(RobotPenPoint *)point{
    [self.wbController whiteBoardDrawWithPoint:point];
}
/**
 获取优化点
 @param point 点
 */
- (void)getOptimizesPointInfo:(RobotPenUtilPoint *)point {
    [self.wbController whiteBoardDrawWithOptimize:point];
}

/**
 设备当前模式
 */
-(void)getMouseDeviceModel:(RobotPenMouseDeviceModel)model
{
    NSLog(@"当前模式 = %@",model == HandModel?@"书写模式":@"鼠标模式" );
}
#pragma mark ------PrivateMethod--------
- (void)reloadUI
{
    self.deviceName.stringValue = [NSString stringWithFormat:@"%@",self.connectDevice ? self.connectDevice.deviceName : @""];
    self.versionLabel.stringValue =[NSString stringWithFormat:@"%@",self.connectDevice ?self.connectDevice.SWStr : @"" ];
    
    [self.connectButton setTitle:self.connectDevice?@"断开设备":@"连接设备"];
    
    self.openOptimizesButton.hidden = self.connectDevice?NO:YES;
    self.openWhiteBoardButton.hidden = self.connectDevice?NO:YES;
    
    self.openPermissionsButton.hidden = !self.connectDevice.macFunction.keysMode;
    self.changeModalButton.hidden = self.connectDevice.macFunction.mouseMode != 2;
}
// 搜索设备
- (IBAction)scanButtonAction:(id)sender {
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    if (self.connectDevice) {
        [[RobotPenManager sharePenManager] disconnectDevice];
    }
    [[RobotPenManager sharePenManager] scanDeviceWithALL:NO];
}
// USB/BLE模式
- (IBAction)sdkModalButtonAction:(id)sender {
    if ([self.sdkModalButton.title isEqualToString:@"USB模式"]) {
        [self.sdkModalButton setTitle:@"BLE模式"];
        [[RobotPenManager sharePenManager] setMACSDKModel:BLEModel];
    }else
    {
        [self.sdkModalButton setTitle:@"USB模式"];
        [[RobotPenManager sharePenManager] setMACSDKModel:USBModel];
    }
}
// 连接/断开设备
- (IBAction)connectButtonAction:(NSButton *)sender {
    if ([self.connectButton.title isEqualToString:@"连接设备"]) {
        if (self.dataSource.count) {
            RobotPenDevice *device = [self selectedModel];
            if (device) {
                [[RobotPenManager sharePenManager] connectDevice:device];
            }
        }
    }else
    {
        if (self.connectDevice) {
            [[RobotPenManager sharePenManager] disconnectDevice];
        }
    }
}
// 开启/关闭优化按钮
- (IBAction)openOptimizesButtonAction:(id)sender {
    if ([self.openOptimizesButton.title isEqualToString:@"开启优化"]) {
        [self.openOptimizesButton setTitle:@"关闭优化"];
        //SDK方法 设置报点类型，此处设置为优化点报点，需要上报优化点和转换点则必须设置
        [[RobotPenManager sharePenManager] setOrigina:NO optimize:YES transform:NO];
        CGSize size = [[RobotPenManager sharePenManager] getDeviceSizeWithDeviceType:self.connectDevice.deviceType];
        //SDK方法 设置场景尺寸，isOriginal = NO时必须设置
        [[RobotPenManager sharePenManager] setSceneSizeWithWidth:size.width andHeight:size.height andIsHorizontal:NO];
        //SDK方法 设置笔迹宽度，isOptimize = YES时必须设置，即显示宽度
        [[RobotPenManager sharePenManager] setStrokeWidth:1.0];
        
    }else
    {
        [self.openOptimizesButton setTitle:@"开启优化"];
        [[RobotPenManager sharePenManager] setOrigina:YES optimize:NO transform:NO];
    }
}
// 打开白板
- (IBAction)openWhiteBoardButtonAction:(id)sender {
    if (self.connectDevice) {
        WhiteBoardController *ww = [[WhiteBoardController alloc] initWithWindowNibName:@"WhiteBoardController"];
        self.wbController = ww;
        [ww showWindow:self];
    }
}
//开启切换按钮
-(IBAction)openPermissionsButtonAction:(id)sender
{
    if ([self.openPermissionsButton.title isEqualToString:@"开启切换"]) {
        [[RobotPenManager sharePenManager] setDeviceModeSwipe:YES];
        [self.openPermissionsButton setTitle:@"关闭切换"];
        self.changeModalButton.usesSingleLineMode = YES;
    }else
    {
        [[RobotPenManager sharePenManager] setDeviceModeSwipe:NO];
        [self.openPermissionsButton setTitle:@"开启切换"];
        self.changeModalButton.usesSingleLineMode = NO;
    }
}
//切换模式按钮
-(IBAction)changeModalButtonAction:(id)sender
{
    if ([[RobotPenManager sharePenManager] getMouseDeviceMode] == MouseModel) {
        [[RobotPenManager sharePenManager] changeMouseDeviceMode:HandModel];
    }else
    {
        [[RobotPenManager sharePenManager] changeMouseDeviceMode:MouseModel];
    }
}
#pragma mark ------ConfigUI-------
- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:10];
    }
    return _dataSource;
}
- (RobotPenDevice *)selectedModel
{
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
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    RPTableCell *cell = [tableView makeViewWithIdentifier:@"tablerow" owner:self];
    cell.model = self.dataSource[row];
    return cell;
}
    
@end
