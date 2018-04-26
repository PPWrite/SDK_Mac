//
//  WindowController.m
//  RobotPenManagerMacSDKDemo
//
//  Created by JMS on 2017/8/30.
//  Copyright © 2017年 JMS. All rights reserved.
//

#import "WindowController.h"
#import "AppDelegate.h"
@interface WindowController ()<NSWindowDelegate>

@end

@implementation WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    AppDelegate *appDelegate = [NSApp delegate];
    appDelegate.mainWindowController = self;
    self.window.titlebarAppearsTransparent = YES;
    self.window.styleMask = NSWindowStyleMaskFullSizeContentView|NSWindowStyleMaskTitled|NSWindowStyleMaskResizable|NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskClosable;
    self.window.movableByWindowBackground = YES;
    self.window.delegate = self;
    [self.window setFrame:NSMakeRect(0, 0, 680, 405) display:YES];
    self.window.minSize = CGSizeMake(680, 405);
    [self.window center];
}
-(void)windowDidEnterFullScreen:(NSNotification *)notification{
    //     NSLog(@"windowFrame:%@,%@",NSStringFromRect([NSScreen mainScreen].frame),NSStringFromRect([NSScreen mainScreen].visibleFrame));
}

@end
