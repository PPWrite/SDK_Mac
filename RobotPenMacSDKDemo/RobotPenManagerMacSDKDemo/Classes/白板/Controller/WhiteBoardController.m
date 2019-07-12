//
//  WhiteBoardController.m
//  RobotPenManagerMacSDKDemo
//
//  Created by JMS on 2017/8/31.
//  Copyright © 2017年 JMS. All rights reserved.
//

#import "WhiteBoardController.h"
#import "DrawBoradView.h"
#define kWidth 760
#define kHeight 680
@interface WhiteBoardController ()<NSTableViewDataSource>
{
    CGFloat ratio;
    BOOL isHorizontal;//默认横屏的设备
}
@property (weak) IBOutlet NSTextField *pointX;
@property (weak) IBOutlet NSTextField *pointY;
@property (weak) IBOutlet NSView *bgView;
@property (strong , nonatomic) DrawBoradView *drawView; // 画布
@end

@implementation WhiteBoardController

- (void)windowDidLoad {
    [super windowDidLoad];
    [self ConfigUI];
}

#pragma mark ------ConfigUI------
- (void)ConfigUI
{
    RobotPenDevice *device = [[RobotPenManager sharePenManager] getConnectDevice];
    CGSize aSize = [[RobotPenManager sharePenManager] getDeviceSizeWithDeviceType:device.deviceType];
    self.drawView = [[DrawBoradView alloc] init];
    NSRect rect;
    if (device.deviceType == K8 || device.deviceType == K8_ZM) {
        isHorizontal = YES;
        ratio = kWidth/aSize.height;
        float H = aSize.width * ratio;
        rect = NSMakeRect(0, kHeight - H, kWidth , H);
    }else
    {
        ratio = kHeight/aSize.height;
        rect = NSMakeRect(0, 0, aSize.width * ratio , kHeight);
    }
    self.drawView.frame = rect;
    [self.bgView addSubview:self.drawView];
    
}

#pragma mark ------PublickMethod-------
- (void)whiteBoardDrawWithPoint:(RobotPenPoint *)point
{
    if (!isHorizontal) {
        CGPoint newpoint = [point getTransformsPointWithType:RobotPenCoordinateUpperLeft];
        point.originalX = newpoint.x;
        point.originalY = newpoint.y ;
    }
    point.originalX = [point changeMacPointWithIsHorizontal:isHorizontal].x * ratio;
    point.originalY = [point changeMacPointWithIsHorizontal:isHorizontal].y * ratio;
    self.pointX.stringValue = [NSString stringWithFormat:@"%hd",point.originalX];
    self.pointY.stringValue = [NSString stringWithFormat:@"%hd",point.originalY];
    [self.drawView drawOriginalPoint:point];
}
- (void)whiteBoardDrawWithOptimize:(RobotPenUtilPoint *)point
{
    if (isHorizontal) {
        CGPoint newpoint = [point getTransformsPointWithType:RobotPenCoordinateLowerLeft];
        point.optimizeX = newpoint.x;
        point.optimizeY = newpoint.y ;  
    }
    point.optimizeX = [point changeMacPointWithIsHorizontal:isHorizontal].x* ratio;
    point.optimizeY = [point changeMacPointWithIsHorizontal:isHorizontal].y * ratio ;
    self.pointX.stringValue = [NSString stringWithFormat:@"%f",point.optimizeX];
    self.pointY.stringValue = [NSString stringWithFormat:@"%f",point.optimizeY];
    [self.drawView drawOptimizesPoint:point];
}
- (IBAction)clearAll:(id)sender {
    [self.drawView clearAll];
    self.pointX.stringValue = @"";
    self.pointY.stringValue = @"";
}
@end
