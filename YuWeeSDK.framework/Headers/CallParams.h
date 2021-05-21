//
//  CallParams.h
//  YuWee SDK
//  Copyright © Yuvitime XS Pte. Ltd. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CallParams : NSObject

typedef NS_ENUM(NSInteger, MediaType) {
    VIDEO = 0,
    AUDIO = 1
};

@property (assign, nonatomic) BOOL isGroup;
@property (strong, nonatomic) NSString *inviteeEmail, *inviteeName, *invitationMessage, *groupName, *groupId, *roomId;

@property (strong, nonatomic) NSMutableArray *groupEmailList;

@property (assign, nonatomic) MediaType mediaType;

@end

NS_ASSUME_NONNULL_END


