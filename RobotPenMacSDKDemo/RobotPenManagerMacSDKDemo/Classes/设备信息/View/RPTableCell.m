//
//  RPTableCell.m
//  RobotPenManagerMacSDKDemo
//
//  Created by JMS on 2017/8/30.
//  Copyright © 2017年 JMS. All rights reserved.
//

#import "RPTableCell.h"
@interface RPTableCell ()
@property (strong , nonatomic) NSTextField *titlelable;
@end
@implementation RPTableCell

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self addSubview:self.titlelable];
}

- (NSTextField *)titlelable {
    if (!_titlelable) {
        _titlelable = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _titlelable.backgroundColor = [NSColor controlColor];
        _titlelable.editable = NO;
        _titlelable.selectable = NO;
        _titlelable.bordered = NO;
        _titlelable.maximumNumberOfLines = 1000;
        _titlelable.font = [NSFont systemFontOfSize:15];
    }
    return _titlelable;
}

- (void)setModel:(RobotPenDevice *)model
{
    _model = model;
    self.titlelable.stringValue = [NSString stringWithFormat:@"%@",model.deviceName];
}

@end
