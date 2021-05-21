//
//  HostMeetingBody.h
//  YuWee SDK
//  Copyright © Yuvitime XS Pte. Ltd. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HostMeetingBody : NSObject

@property (strong,nonatomic) NSString *accessType;
@property (strong,nonatomic) NSString *meetingName;
@property (assign,nonatomic) int maxAllowedParticipant;
@property (assign,nonatomic) int callMode;
@property (assign,nonatomic) int meetingExpireDuration;
@property (assign,nonatomic) long meetingStartTime;
@property (strong,nonatomic) NSMutableArray<NSString *> *presenters;
@property (strong,nonatomic) NSMutableArray<NSString *> *callAdmins;
@property (assign,nonatomic) BOOL isCallAllowedWithoutInitiator;

@end

NS_ASSUME_NONNULL_END
