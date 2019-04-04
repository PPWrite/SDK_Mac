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
#import "RPNoteManager.h"
#import <RobotMacPenSDK/RobotPenManager.h>

@interface RPInformationController ()<RobotPenDelegate,NSTableViewDelegate,NSTableViewDataSource,NSAlertDelegate>
@property (strong , nonatomic) NSMutableArray *dataSource;      //设备数据源
@property (strong , nonatomic) NSMutableArray *noteListArr;     //笔记列表
@property (strong , nonatomic) RobotPenDevice *connectDevice;   //已连接的设备

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *deviceName;              //设备名称
@property (weak) IBOutlet NSTextField *deviceUUID;              //设备UUID
@property (weak) IBOutlet NSTextField *syncNumberLable;         //同步笔记数量
@property (weak) IBOutlet NSTextField *versionLabel;            //设备版本号
@property (weak) IBOutlet NSTextField *batteryLabel;            //设备电量
@property (weak) IBOutlet NSTextField *rssiLabel;               //设备信号量
@property (weak) IBOutlet NSButton *sycBtn;                     //同步按钮
@property (weak) IBOutlet NSButton *updatabtn;                  // 升级按钮

@property (strong , nonatomic) WhiteBoardController *wbController;

@end

@implementation RPInformationController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置SDK类型
    //USB模式
    [[RobotPenManager sharePenManager] setMACSDKModel:USBModel];
    //蓝牙模式
//    [[RobotPenManager sharePenManager] setMACSDKModel:BLEModel];
    //检查数据库
    [RobotSqlManager checkRobotSqlManager];
    
    //遵守协议
    [[RobotPenManager sharePenManager] setPenDelegate:self];
    //SDK方法 设置报点类型，此处设置为优化点报点，需要上报优化点和转换点则必须设置
    [[RobotPenManager sharePenManager] setOrigina:NO optimize:YES transform:NO];
    CGSize size = [[RobotPenManager sharePenManager] getDeviceSizeWithDeviceType:T7];
    //SDK方法 设置场景尺寸，isOriginal = NO时必须设置,以VALUE_A4_HEIGHT和VALUE_A4_WIDTH为例，具体需要根据具体设备尺寸设置
    [[RobotPenManager sharePenManager] setSceneSizeWithWidth:size.width andHeight:size.height andIsHorizontal:NO];
    
    //SDK方法 设置笔迹宽度，isOptimize = YES时必须设置，即显示宽度
    [[RobotPenManager sharePenManager] setStrokeWidth:1.2];
    
    //开启优化点模式后，开启原始点上报
    [[RobotPenManager sharePenManager] setSendOriginalPointWhenIsOptimize:YES];
}

#pragma mark ------ConfigUI-------

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:10];
    }
    return _dataSource;
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
#pragma mark ------PrivateMethod--------
- (void)reloadUI
{
    self.deviceName.stringValue = [NSString stringWithFormat:@"%@",self.connectDevice.deviceName.length ? self.connectDevice.deviceName : @""];
    self.deviceUUID.stringValue = [NSString stringWithFormat:@"%@",self.connectDevice.uuID.length ? self.connectDevice.uuID : @""];
    self.versionLabel.stringValue =[NSString stringWithFormat:@"%@",self.connectDevice.SWStr.length ?self.connectDevice.SWStr : @"" ];
    self.batteryLabel.stringValue =[NSString stringWithFormat:@"%d",self.connectDevice.Battery];
    self.rssiLabel.stringValue =[NSString stringWithFormat:@"%d",self.connectDevice.RSSI];
    if (!self.connectDevice) {
        self.syncNumberLable.stringValue = @"";
        self.sycBtn.hidden = YES;
    }
}
// 连接设备
- (IBAction)connectDeviceAction:(NSButton *)sender {
    [self disconnectDeviceAction:nil];
    if (self.dataSource.count) {
        RobotPenDevice *device = [self selectedModel];
        if (device) {
           [[RobotPenManager sharePenManager] connectDevice:device];
        }
    }
}
- (RobotPenDevice *)selectedModel
{
    NSInteger select = [self.tableView selectedRow];
    if (select >= 0 && self.dataSource.count >select) {
        RobotPenDevice *note = [self.dataSource objectAtIndex:select];
        return note;
    }
    return nil;
}

// 断开连接设备
- (IBAction)disconnectDeviceAction:(id)sender {
    if (self.connectDevice) {
        [[RobotPenManager sharePenManager] disconnectDevice];
    }
}

// 搜索设备
- (IBAction)blueToothScanDeviceAction:(id)sender {
    
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    if (self.connectDevice) {
        [[RobotPenManager sharePenManager] disconnectDevice];
    }
    [[RobotPenManager sharePenManager] scanDeviceWithALL:NO];
}
- (IBAction)syncBtnAction:(id)sender {
     [[RobotPenManager sharePenManager] startSyncNote];
}

// 打开白板
- (IBAction)openWhiteBoardAction:(id)sender {
    if (self.connectDevice) {
        NSString *uuid = [RPNoteManager createFileIdent];
        RobotNote *note = [[RobotNote alloc] init];
        note.NoteKey = uuid;
        note.NoteID = 0;
        note.DeviceType = self.connectDevice.deviceType;
        note.CreateTime = (long )(NSTimeInterval)([RobotSqlManager GetTimeInterval] * 1000 );
        note.UpdateTime = (long )(NSTimeInterval)([RobotSqlManager GetTimeInterval] * 1000 );
        note.IsHorizontal = 0;
        note.Title = [RPNoteManager obtainNoteTitle:self.connectDevice.deviceType];
        [RobotSqlManager BuildNote:note Success:^(id responseObject) {
            WhiteBoardController *ww = [[WhiteBoardController alloc] initWithWindowNibName:@"WhiteBoardController"];
            self.wbController = ww;
            self.wbController.robotNote = note;
            [ww showWindow:self];
        } Failure:^(NSError *error) {
            NSLog(@"creatError%@",error);
        }];
    }
}
// 升级
- (IBAction)upData:(id)sender {
    
    [[RobotPenManager sharePenManager] startOTA];
}


#pragma Mark ------RobotPenDelegate--------
- (void)getDeviceEvent:(DeviceEventType)Type
{
    NSLog(@"tuype = %d",Type);
}
/**
 获取设备状态
 
 @param State 设备状态
 */
- (void)getDeviceState:(DeviceState)State {
    switch (State) {
        case DEVICE_CONNECT_FAIL:
            NSLog(@"设备连接失败");
             [[RobotPenManager sharePenManager] scanDeviceWithALL:NO];
            break;
        case DEVICE_CONNECTE_SUCCESS:
            NSLog(@"设备连接成功");
            [[RobotPenManager sharePenManager] stopScanDevice];
            break;
        case DEVICE_DISCONNECTED:
            NSLog(@"设备断开");
            self.connectDevice = nil;
            [self reloadUI];
            break;
        case DEVICE_INFO_END:
            NSLog(@"获取信息成功");
            self.connectDevice = [[RobotPenManager sharePenManager] getConnectDevice];
            NSLog(@"%@",self.connectDevice);
            [self reloadUI];
            break;
            case DEVICE_UPDATE:
        {
            [[RobotPenManager sharePenManager] getIsNeedUpdate];
        }
    }
    
}

/**
 获取设备信息
 @param device 设备
 */
- (void)getBufferDevice:(RobotPenDevice *)device {
    if (![self.dataSource containsObject:device]) {
         [self.dataSource addObject:device];
    }
    [self.tableView reloadData];
}
/**
 同步笔记数目

 @param num 数量
 @param battery ...
 */
- (void)getStorageNum:(int)num andBattery:(int)battery {
    self.syncNumberLable.stringValue = [NSString stringWithFormat:@"%d",num];
    self.sycBtn.hidden = !num;
}

#pragma mark 同步笔记
- (void)getSyncData:(RobotTrails *)trails
{
    [RobotSqlManager SaveTrails:trails Success:^(id responseObject) {
        
    } Failure:^(NSError *error) {
        
    }];
    
    
}
- (void)getSyncNote:(RobotNote *)note
{
    [RobotSqlManager BuildNote:note Success:^(id responseObject) {
        [[RobotPenManager sharePenManager] SetBlockWithBlock:(NSString *)responseObject];
    } Failure:^(NSError *error) {
    }];
    
}
- (void)getDevicePage:(int)page andNoteKey:(NSString *)NoteKey
{
    if (![RobotSqlManager checkNoteWithNoteKey:NoteKey]) {
        RobotNote *notemodel =  [[RobotNote alloc]init];
        notemodel.NoteKey = NoteKey;
        notemodel.Title = [NSString stringWithFormat:@"%@",NoteKey];
        notemodel.DeviceType = [[RobotPenManager sharePenManager] getConnectDevice].deviceType;
        notemodel.UserID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"] intValue];
        notemodel.IsHorizontal =[[[NSUserDefaults standardUserDefaults] objectForKey:@"isHorizontal"] intValue];
        
        [RobotSqlManager BuildNote:notemodel Success:^(id responseObject) {
        } Failure:^(NSError *error) {
            return ;
        }];
    }
}
- (void)getSyncDataLength:(int)length andCurDataLength:(int)curlength andProgress:(float)progess
{
    //    MSLog(@"Length = %d,curLength = %d,progess = %f",length,curlength,progess);
}

//MARK:T9系列

- (void)getTASyncNote:(RobotNote *)note andPage:(int)page
{
    [RobotSqlManager SaveTANote:note andPage:page Success:^(id responseObject) {
        
        [[RobotPenManager sharePenManager] SetBlockWithBlock:(NSString *)responseObject];
        
    } Failure:^(NSError *error) {

    }];
    
    
}
- (void)SyncState:(SYNCState)state { // 同步状态
    switch (state) {
        case SYNC_ERROR:
            NSLog(@"同步笔记错误");
            break;
        case SYNC_NOTE:
            NSLog(@"有未同步笔记");
            break;
        case SYNC_NO_NOTE:
            NSLog(@"没有未同步笔记");
            break;
        case SYNC_SUCCESS:
            NSLog(@"同步成功");
            break;
        case SYNC_START:
            NSLog(@"开始同步");
            break;
        case SYNC_STOP:
            NSLog(@"停止同步");
            break;
        case SYNC_COMPLETE:
            NSLog(@"同步完成");
            _sycBtn.hidden = YES;
            break;
        default:
            break;
    }
}
/**
 获取原始点
 @param point 点
 */
- (void)getPointInfo:(RobotPenPoint *)point{}
/**
 获取优化点
 @param point 点
 */
- (void)getOptimizesPointInfo:(RobotPenUtilPoint *)point {

    point.optimizeX = [point changeMacPointWithIsHorizontal:NO].x;
    point.optimizeY = [point changeMacPointWithIsHorizontal:NO].y;
    [self.wbController whiteBoardDrawView:point];
}

- (void)OTAUpdateProgress:(float)progress{
   
    RobotBLELog(@"progress == %f",progress);
}

@end
