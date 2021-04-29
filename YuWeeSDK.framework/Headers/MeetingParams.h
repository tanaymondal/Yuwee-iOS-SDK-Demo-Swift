//
//  MeetingParams.h
//  YuWee SDK
//
//  Created by Arijit Das on 23/09/20.
//  Copyright © 2020 Prasanna Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MeetingType) {
    CONFERENCE,
    TRAINING,
};

NS_ASSUME_NONNULL_BEGIN

@interface MeetingParams : NSObject

@property (strong,nonatomic) NSString *meetingTokenId;
@property (strong,nonatomic) NSString *callId;
@property (strong,nonatomic) NSString *icsCallResourceId;
@property (strong,nonatomic) NSString *token;
@property (nonatomic,assign) MeetingType meetingType;
@property (strong,nonatomic) NSString *roomId;
@property (assign,nonatomic) BOOL isAudioEnabled;
@property (assign,nonatomic) BOOL isVideoEnabled;

@end

NS_ASSUME_NONNULL_END
