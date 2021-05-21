//
//  StatusManager.h
//  YuWee SDK
//  Copyright © Yuvitime XS Pte. Ltd. All rights reserved.

#import <Foundation/Foundation.h>
#import "YuWeeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface StatusManager : NSObject

+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;

/// Set your status.
/// ONLINE
/// BUSY
/// AWAY
/// INVISIBLE
-(void)setStatus:(Status)status;

/// Get user status of email.
-(void)getParticularUserStatusByEmail:(NSString*)email
                  withCompletionBlock:(UserStatusCompletionBlock)completionBlock;

/// Get user status by user Id.
-(void)getParticularUserStatusByUserId:(NSString*)userId
                   withCompletionBlock:(UserStatusCompletionBlock)completionBlock;

/// Get user status by contact Id.
-(void)getParticularUserStatusByContactId:(NSString*)contactId
                      withCompletionBlock:(UserStatusCompletionBlock)completionBlock;

/// Fetch all contact status.
-(void)fetchAllContactsStatus:(UserStatusCompletionBlock)completionBlock;

/// Set delegate to get status change of other user who are in your contact list.
-(void)setContactStatusChangeDelegate:(id <YuWeeUserStatusChangeDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
