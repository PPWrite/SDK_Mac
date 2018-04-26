//
//  DrawBoradView.m
//  Mac-OS-USB
//
//  Created by JMS on 2017/7/20.
//  Copyright © 2017年 CNDotaIsBestDota. All rights reserved.
//

#import "DrawBoradView.h"

@interface DrawBoradView ()
{
    CGFloat _lineWidth;//笔迹宽度
    CGPoint startPoint;//起始点
    CGPoint endPoint;//终点

}
@property (strong , nonatomic) NSMutableArray *bezierPathsArr;  //BezierPath数组

@property (nonatomic, strong) NSImageView *penImageView;//悬浮光标
@end

@implementation DrawBoradView


- (NSMutableArray *)bezierPathsArr
{
    if (!_bezierPathsArr) {
        
        _bezierPathsArr = [[NSMutableArray alloc] init];
    }
    return _bezierPathsArr;
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.wantsLayer = YES;
        self.layer.backgroundColor = [NSColor whiteColor].CGColor;
        //小笔头
        self.penImageView = [[NSImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.penImageView.hidden = YES;
        self.penImageView.image = [NSImage imageNamed:@"pen"];
        [self addSubview:self.penImageView];
    }
    return self;
}


/**
 清空数据
 */
- (void)clearAll
{
    [self.bezierPathsArr removeAllObjects];
    [self setNeedsDisplay:YES];
}

/**
 绘制笔迹
 
 @param point <#point description#>
 */
- (void)getOptimizesPointInfo:(RobotPenUtilPoint *)point
{
    self.penImageView.frame = NSMakeRect(point.optimizeX  - 2 , point.optimizeY - 5 , 20, 20);
    
    if (point.touchState == 0) {
        
        if (self.penImageView.hidden) {
            self.penImageView.hidden = NO;
        }
        return;
        
    }
    
    if (point.touchState == 1) {
        //按下
        if (self.penImageView.hidden) {
            self.penImageView.hidden = NO;
        }
        endPoint.x = point.optimizeX;
        endPoint.y = point.optimizeY;
        
    }else if (point.touchState == 2 || point.touchState == 3) {
        //移动
        startPoint = endPoint;
        endPoint.x = point.optimizeX;
        endPoint.y = point.optimizeY;
        [self drawLineWithPoint:startPoint topoint:endPoint linewidth:point.width];
        if (point.touchState == 3) {
            //离开
            if (!self.penImageView.hidden) {
                self.penImageView.hidden = YES;
            }
            startPoint = CGPointMake(0, 0);
            endPoint = CGPointMake(0, 0);
        }
    }else
    {
        if (!self.penImageView.hidden) {
            self.penImageView.hidden = YES;
        }
    }
}

- (void)drawLineWithPoint:(CGPoint )startPoint topoint:(CGPoint)endPoint linewidth:(CGFloat)lineWidth
{
    
    NSBezierPath * path = [NSBezierPath bezierPath];
    
    path.lineWidth = lineWidth;
    
    [path moveToPoint:startPoint];
    
    [path lineToPoint:endPoint];
    
    [self.bezierPathsArr addObject:path];
    
    [self setNeedsDisplay:YES];
    
}

- (void)drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];
    
    for (NSBezierPath *path in self.bezierPathsArr) {
        
        NSColor *color = [NSColor blackColor];
        
        [color set];
        
        [path stroke];
    }
}

/**
 展示笔记列表里的笔迹
 @param data data
 */
- (void)showNoteListTrail:(NSArray *)data
{
    for (NSInteger j = 0; j < data.count; j ++) {
        
        RobotTrails *model = (RobotTrails *)data[j];
        for (int i = 0; i < model.Data.count; i ++) {
            NSDictionary *dict = model.Data[i];
            RobotPenPoint *utilpoint = [[RobotPenPoint alloc] init];
            
            utilpoint.originalX = [dict[@"x"] floatValue];
            utilpoint.originalY = [dict[@"y"] floatValue];
            utilpoint.deviceType = [[RobotPenManager sharePenManager] getConnectDevice].deviceType;
            
            CGPoint scenePoint = [utilpoint getScenePointWithSceneWidth:self.frame.size.width SceneHeight:self.frame.size.height IsHorizontal:NO];
            
            
            RobotPenUtilPoint * originalPoint = [[RobotPenUtilPoint alloc] init];
            originalPoint.optimizeX = scenePoint.x;
            originalPoint.optimizeY = self.frame.size.height - scenePoint.y;
            if (i==0 || i == model.Data.count -1) {
                originalPoint.touchState = i;
            }
            originalPoint.width =  [[RobotPenManager sharePenManager] getWidth:[dict[@"w"] floatValue] andSceneWidth:self.frame.size.width andisHorizontal:NO andDevicetype:[[RobotPenManager sharePenManager] getConnectDevice].deviceType isOriginal:NO];
            originalPoint.deviceType = utilpoint.deviceType;
            if ( i == 0) {
                originalPoint.touchState = 1;
            }
            else if (i == model.Data.count -1)
            {
                originalPoint.touchState = 3;
               
            }
            else
            {
                originalPoint.touchState = 2;
            }
    
            [self getOptimizesPointInfo:originalPoint];
            
            if (originalPoint.touchState == 1 || originalPoint.touchState == 3) {
            }
            utilpoint = nil;
            scenePoint = CGPointZero;
            originalPoint = nil;
        }
    }
}

@end
