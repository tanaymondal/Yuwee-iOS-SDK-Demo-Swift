//
//  EditMeetingBody.h
//  YuWee SDK
//  Copyright © Yuvitime XS Pte. Ltd. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EditMeetingBody : NSObject

@property (strong,nonatomic) NSString *meetingTokenId;
@property (strong,nonatomic) NSString *meetingName;
@property (assign,nonatomic) int maxAllowedParticipant;
@property (assign,nonatomic) BOOL isCallAllowedWithoutInitiator;
@property (assign,nonatomic) int meetingStartTime;
@property (assign,nonatomic) int meetingExpirationTime;
@property (assign,nonatomic) int callMode;
@property (strong,nonatomic) NSMutableArray<NSString *> *addCallAdmin;
@property (strong,nonatomic) NSMutableArray<NSString *> *removeCallAdmin;
@property (strong,nonatomic) NSMutableArray<NSString *> *addPresenter;
@property (strong,nonatomic) NSMutableArray<NSString *> *removePresenter;

@end

NS_ASSUME_NONNULL_END
