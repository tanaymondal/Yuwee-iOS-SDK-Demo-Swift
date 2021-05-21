//
//  ContactManager.h
//  YuWee SDK
//  Copyright © Yuvitime XS Pte. Ltd. All rights reserved.

#import <Foundation/Foundation.h>
#import "YuWeeProtocol.h"
#import "ContactModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactManager : NSObject
+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;

/// Add contact.
-(void)addContact:(ContactModel*)contactModel
withCompletionBlock:(ContactOperationCompletionBlock)completionBlock;

/// Fetch contact details using contact Id.
-(void)fetchContactDetailsWithContactId:(NSString*)contactId
                    withCompletionBlock:(ContactOperationCompletionBlock)completionBlock;

/// Fetch contact list.
-(void)fetchContactList:(ContactOperationCompletionBlock)completionBlock;

/// Delete contact with contact Id.
-(void)deleteContactWithContactId:(NSString*)contactId
              withCompletionBlock:(ContactOperationCompletionBlock)completionBlock;


@end

NS_ASSUME_NONNULL_END
