//
//  RPNoteManager.m
//  RobotPenManagerMacSDKDemo
//
//  Created by JMS on 2017/9/1.
//  Copyright © 2017年 JMS. All rights reserved.
//

#import "RPNoteManager.h"
#import <RobotMacPenSDK/RobotPenDevice.h>
@implementation RPNoteManager

+ (NSString *)createFileIdent
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    NSString*uuidss =[NSString stringWithFormat:@"%@", [uuid lowercaseString]];
    return  uuidss;
}
+ (CGSize)obtainWindowSize:(int)DeviceType
{
    CGSize windowsize = CGSizeMake(0, 0);
    RobotPenDevice *device = [RobotPenDevice new];
    device.deviceType = DeviceType;
    windowsize = [device getDeviceSizeWithIsHorizontal:NO];
    return windowsize;
}
+ (NSString *)obtainNoteTitle:(int)DeviceType
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"YYYYMMdd_HHmmss"];
    NSString *  locationTimeString=[dateFormatter stringFromDate:date];
    RobotPenDevice *device = [RobotPenDevice new];
    device.deviceType = DeviceType;
    NSString *name= [NSString stringWithFormat:@"%@",[device getPrefixString]];
   
    name= [NSString stringWithFormat:@"%@_%@",name,locationTimeString];
   
    return name;
}
+ (void)obtainNotelistData:(void(^)(NSArray *data))block
{
    [RobotSqlManager GetAllNoteListWithPage:0 Success:^(id responseObject) {
        NSArray *data = responseObject[@"Data"];
        block(data);
    } Failure:^(NSError *error) {
        
    }];
}

+ (void)obtainNoteTrailData:(RobotNote *)note block:(void(^)(NSArray *data))block
{
    NSMutableArray *BlockArray = [NSMutableArray array];
    [RobotSqlManager GetAllBlockWithNoteKey:note.NoteKey Success:^(id responseObject) {
        [BlockArray addObjectsFromArray:responseObject];
        if (BlockArray.count >0) {
            [RobotSqlManager GetAllTrailsWithNoteKey:note.NoteKey WithBlockKey:BlockArray[0] Success:^(id responseObject) {
                NSArray *array = [NSArray arrayWithArray:responseObject[@"Data"]];
                block(array);
            } Failure:^(NSError *error) {

            }];
        }
    } Failure:^(NSError *error) {

    }];

}

@end
