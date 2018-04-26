//
//  WhiteBoardController.m
//  RobotPenManagerMacSDKDemo
//
//  Created by JMS on 2017/8/31.
//  Copyright © 2017年 JMS. All rights reserved.
//

#import "WhiteBoardController.h"
#import "RPNoteManager.h"
#import "DrawBoradView.h"
#define kWidth 500
#define kHeight 680
@interface WhiteBoardController ()<NSTableViewDelegate,NSTableViewDataSource>
{
    CGFloat ratio;
}
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *pointX;
@property (weak) IBOutlet NSTextField *pointY;
@property (weak) IBOutlet NSView *bgView;
@property (strong , nonatomic) DrawBoradView *drawView; // 画布
@property (strong , nonatomic) NSMutableArray *dataSource; //数据源
@end

@implementation WhiteBoardController

- (void)windowDidLoad {
    [super windowDidLoad];
    [self ConfigUI];
    [self obtainData];
}
#pragma mark ------ConfigUI------
- (void)ConfigUI
{
    CGSize aSize = [RPNoteManager obtainWindowSize:self.robotNote.DeviceType];
    //SDK方法 设置场景尺寸，isOriginal = NO时必须设置
    [[RobotPenManager sharePenManager] setSceneSizeWithWidth:aSize.width andHeight:aSize.height andIsHorizontal:NO];
    self.drawView = [[DrawBoradView alloc] init];
    ratio = kHeight/aSize.height;
    NSRect rect = NSMakeRect(0, 0, aSize.width * ratio , kHeight);
    self.drawView.frame = rect;
    [self.bgView addSubview:self.drawView];
}

#pragma mark ------TabelViewDelegate------
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.dataSource.count;
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSTableCellView *cell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    RobotNote *note = self.dataSource[row];
    cell.textField.stringValue = note.Title;
    return cell;
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    RobotNote *note = [self selectedModel];
    if (note) {
        self.robotNote = note;
        [self ConfigUI];
        [RPNoteManager obtainNoteTrailData:note block:^(NSArray *data) {
            [self.drawView showNoteListTrail:data];
        }];
    }
}
#pragma mark ------PublickMethod-------
- (void)whiteBoardDrawView:(RobotPenUtilPoint *)point
{
    point.optimizeX = point.optimizeX * ratio;
    point.optimizeY = point.optimizeY * ratio;
    self.pointX.stringValue = [NSString stringWithFormat:@"%f",point.optimizeX];
    self.pointY.stringValue = [NSString stringWithFormat:@"%f",point.optimizeY];
    [self.drawView getOptimizesPointInfo:point];
}
#pragma mark ------PrivateMethod-------

- (IBAction)addTemple:(id)sender {
  
}
- (IBAction)removeTemple:(id)sender {
    RobotNote *note = [self selectedModel];
    if (note) {
        [RobotSqlManager DeleteNoteWithNoteKey:note.NoteKey Success:^(id responseObject) {
            [self.dataSource removeObject:note];
            [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:self.tableView.selectedRow] withAnimation:NSTableViewAnimationSlideRight];
        } Failure:^(NSError *error) {
        }];
    }
}
- (RobotNote *)selectedModel
{
    NSInteger select = [self.tableView selectedRow];
    if (select >= 0 && self.dataSource.count >select) {
        RobotNote *note = [self.dataSource objectAtIndex:select];
        return note;
    }
    return nil;
}
- (IBAction)clearAll:(id)sender {
    [self.drawView clearAll];
}
- (void)obtainData
{
    [RPNoteManager obtainNotelistData:^(NSArray *data) {
        self.dataSource = data.mutableCopy;
        [self.tableView reloadData];
    }];
}

@end
