//
//  WhiteboardViewController.m
//  RobotMacPenSDKDemo
//
//  Created by Caffrey on 2020/5/12.
//  Copyright © 2020 robot. All rights reserved.
//

#import "WhiteboardViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <RobotPenMac/RobotPenMac.h>
#import <RobotSimpleWhiteboard/RobotSimpleWhiteboard.h>
#import <RobotViewRecord/RobotViewRecord.h>

#define WEAK_SELF __weak typeof(self) wself = self;
#define STRONG_SELF __strong typeof(wself) self = wself;

@interface WhiteboardViewController ()<RobotPenDelegate> {
    int _pageNum;
}
@property (weak) IBOutlet RBTSimpleWhiteboardView *whiteboardView;
@property (weak) IBOutlet NSButton *penOptimizeButton;
@property (weak) IBOutlet NSButton *stopRecordButton;
@property (weak) IBOutlet NSButton *startRecordButton;

@property (nonatomic, strong) RobotPenDevice *connectDevice;

@property (nonatomic, assign) CGSize connectDeviceSize;

@property (nonatomic, strong) NSMutableArray<NSValue *> *points;

/// 录制状态 0: 未录制 1:录制中 2:录制暂停
@property (nonatomic, assign) uint recordStatus;
/// 录制视频的路径
@property (nonatomic, strong) NSString *moviePath;

@end

@implementation WhiteboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.points = [NSMutableArray array];

    self.view.wantsLayer = true;
    self.view.layer.backgroundColor = NSColor.whiteColor.CGColor;
}

- (void)viewDidAppear {
    [super viewDidAppear];

    self.whiteboardView.penWidth = 1;
    //self.whiteboardView.isOpenStroke = NO;
    self.connectDevice = [[RobotPenManager sharePenManager] getConnectDevice];
    self.connectDeviceSize = self.connectDevice.function.deviceSize;
    [[RobotPenManager sharePenManager] setPenDelegate:self];
    [[RobotPenManager sharePenManager] setRobotA5PagedPoint:YES];

    self.penOptimizeButton.title = self.whiteboardView.isOpenStroke ? @"关闭笔迹优化" : @"开启笔迹优化";

    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {

    }];
}

- (void)getDevicePage:(int)page andNoteId:(int)NoteId {
    NSLog(@"页码变化 %d ==> %d", _pageNum, page);
    _pageNum = page;
    self.connectDevice = [[RobotPenManager sharePenManager] getConnectDevice];
    self.connectDeviceSize = self.connectDevice.function.deviceSize;
}

- (void)rightMouseDown:(NSEvent *)event {
    if ([event clickCount] > 1) {
        [self.whiteboardView clear];
        [self.points removeAllObjects];
    }
}

- (void)robotPenReceivedDevicePrimitivePoint:(RobotDeviceOriginPoint)point {
    NSLog(@"点:{%d, %d}  压力:%d  状态:0x%02x  时间:%d", point.x, point.y, point.p, point.s, point.time);
    if (point.s == 0x00) {
        NSLog(@"================================");
    }
    if (point.isLattice &&
        point.s != 0x00 &&
        (point.sizeType != RobotLatticeSizeType_A4 &&
         point.sizeType != RobotLatticeSizeType_A5 &&
         point.sizeType != RobotLatticeSizeType_Robot_A5)) {
        NSLog(@"⚠️飞点了⚠️");
        return;
    }

    CGPoint cgpoint;
    if (_connectDevice.deviceType == D7) {
        cgpoint = CGPointMake(point.y, point.x);
    } else {
        cgpoint = CGPointMake(point.x, point.y);
    }
    [self.whiteboardView drawDevicePoint:cgpoint
                                pressure:point.p
                             pointStatus:point.s
                       pointIntervalTime:point.time
                              deviceSize:_connectDeviceSize
                        deviceCoordinate:_connectDevice.function.coordinate];

    [_points addObject:[NSValue valueWithBytes:&point objCType:@encode(RobotDeviceOriginPoint)]];
}

- (IBAction)replayPointClick:(id)sender {
    [self.whiteboardView clear];
    NSArray<NSValue *> *ps = self.points.copy;

    [self.whiteboardView startBatchDrawing];
    for (NSValue *vp in ps) {
        RobotDeviceOriginPoint point;
        [vp getValue:&point];


        CGPoint cgpoint;
        if (_connectDevice.deviceType == D7) {
            cgpoint = CGPointMake(point.y, point.x);
        } else {
            cgpoint = CGPointMake(point.x, point.y);
        }
        [self.whiteboardView drawDevicePoint:cgpoint
                                    pressure:point.p
                                 pointStatus:point.s
                                  deviceSize:_connectDeviceSize
                            deviceCoordinate:_connectDevice.function.coordinate];
    }
    [self.whiteboardView endBatchDrawing:^{

    }];
}

- (IBAction)switchPenOptimizeButtonClick:(NSButton *)sender {
    self.whiteboardView.isOpenStroke = !self.whiteboardView.isOpenStroke;
    sender.title = self.whiteboardView.isOpenStroke ? @"关闭笔迹优化" : @"开启笔迹优化";
}

#pragma mark - record -
- (IBAction)startRecordClick:(id)sender {
        if (self.recordStatus == 0) {
        [self startRecord];
    } else if (self.recordStatus == 1) {
        [self pauseRecord];
    } else if (self.recordStatus == 2) {
        [self resumeRecord];
    }
}

- (IBAction)stropRecordClick:(id)sender {
    if (self.recordStatus != 0) {
        [self stopRecord];
    }
}

- (void)startRecord {
    NSError *err = [RBTViewRecorder.shared startRecordView:self.view
                                                 videoSize:self.view.bounds.size
                                         microphoneEnabled:YES
                                                saveInPath:self.moviePath
                                                 frameRate:RBTViewRecordFrameRate10];

    if (err) {
        NSLog(@"❌ 开始录制失败 %@", err);
        self.moviePath = nil;
        return;
    }

    self.recordStatus = 1;
}

- (void)pauseRecord {
    [RBTViewRecorder.shared pauseRecord];
    self.recordStatus = 2;
}

- (void)resumeRecord {
    [RBTViewRecorder.shared resumeRecord];
    self.recordStatus = 1;
}

- (void)stopRecord {

    WEAK_SELF
    [RBTViewRecorder.shared stopRecord:^(NSString * _Nonnull path) {
        STRONG_SELF
        dispatch_async(dispatch_get_main_queue(), ^{
            self.moviePath = nil;
        });
    }];

    self.recordStatus = 0;
}

- (void)setRecordStatus:(uint)recordStatus {
    _recordStatus = recordStatus;

    [self setupRecordView];
}

- (void)setupRecordView {
    if (self.recordStatus == 0) {
        self.startRecordButton.title = @"开始录制";
        self.stopRecordButton.hidden = YES;
    } else if (self.recordStatus == 1) {
        self.startRecordButton.title = @"暂停录制";
        self.stopRecordButton.hidden = NO;
    } else if (self.recordStatus == 2) {
        self.startRecordButton.title = @"继续录制";
        self.stopRecordButton.hidden = NO;
    }
}

- (NSString *)moviePath {
    if (nil == _moviePath) {
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy_MM_dd-hh_mm_ss";
        NSString *movieName = [NSString stringWithFormat:@"%@.mp4", [dateFormatter stringFromDate:date]];
        _moviePath = [[NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:movieName];

        NSLog(@"视频路径 %@", _moviePath);
    }

    return _moviePath;
}

@end
