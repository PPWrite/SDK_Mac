//
//  WhiteBoardController.m
//  RobotPenManagerMacSDKDemo
//
//  Created by nb616 on 2017/8/31.
//  Copyright © 2017年 JMS. All rights reserved.
//

#import "WhiteBoardController.h"
#import "DrawBoradView.h"

#define kratio 0.04
@interface WhiteBoardController ()

@property (weak) IBOutlet NSTextField *pointX;//X坐标显示
@property (weak) IBOutlet NSTextField *pointY;//Y坐标显示
@property (weak) IBOutlet NSTextField *penState;//笔的状态

@property (weak) IBOutlet NSView *bgView;//画布背景
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
    NSRect rect = NSMakeRect(0, 0, VALUE_A4_HEIGHT*kratio , VALUE_A4_WIDTH*kratio);
    self.drawView = [[DrawBoradView alloc] initWithFrame:rect];
 
    [self.bgView addSubview:self.drawView];
}

#pragma mark ------PublickMethod-------
- (void)whiteBoardDrawView:(RobotPenUtilPoint *)point
{
    point.optimizeX = point.optimizeX *kratio;
    point.optimizeY = point.optimizeY *kratio;
    self.pointX.stringValue = [NSString stringWithFormat:@"%f",point.optimizeX];
    self.pointY.stringValue = [NSString stringWithFormat:@"%f",point.optimizeY];
    self.penState.stringValue = [NSString stringWithFormat:@"%d",point.touchState];
    [self.drawView getOptimizesPointInfo:point];
}

- (IBAction)clearAll:(id)sender {
    [self.drawView clearAll];
}

@end
