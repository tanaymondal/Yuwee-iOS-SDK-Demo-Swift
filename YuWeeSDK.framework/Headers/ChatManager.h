//
//  ChatManager.h
//  YuWee SDK
//  Copyright © Yuvitime XS Pte. Ltd. All rights reserved.

#import <Foundation/Foundation.h>
#import "YuWeeProtocol.h"
#import "FileManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatManager : NSObject

+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;

/// Fetch chat room using userId
- (void)fetchChatRoomByUserIds:(NSArray*)arrUserIds
          withAllowReuseOfRoom:(BOOL)allowReuseOfRoom
               withIsBroadcast:(BOOL)isBroadcast
                 withGroupName:(NSString*)groupName
           withCompletionBlock:(ChatOperationCompletionBlock)completionBlock;

/// Fetch chat room using emails
- (void)fetchChatRoomByEmails:(NSArray*)arrEmails
         withAllowReuseOfRoom:(BOOL)allowReuseOfRoom
              withIsBroadcast:(BOOL)isBroadcast
                withGroupName:(NSString*)groupName
          withCompletionBlock:(ChatOperationCompletionBlock)completionBlock;

/// Fetch chat list
- (void)fetchChatListWithCompletionBlock:(ChatOperationCompletionBlock)completionBlock;

/// Fetch last 20 chat messages.
/// totalFetchedMessages = 0 (get last 20 messages), totalFetchedMessages = 20 (get next 20 messages) and so on...
- (void)fetchChatMessagesForRoomId:(NSString*)strRoomId totalMessagesCountToSkip:(NSInteger)totalFetchedMessages withCompletionBlock:(ChatOperationCompletionBlock)completionBlock;

/// Mark all messages as read on room.
- (void)markMessagesAsReadInRoomId:(NSString*)strRoomId;

/// mark single messages as read in a room.
- (void)markSingleMessageAsReadInRoomId:(NSString*)strRoomId
                              messageId:(NSString*)messageId;

/// Send typing status to a room Id.
- (void)sendTypingStatusToRoomId:(NSString*)strRoomId;

/// Send new message to a room Id.
- (void)sendMessage:(NSString*)strMessage
           toRoomId:(NSString*)strRoomId
  messageIdentifier:(NSString*)strBrowserMessageId
withQuotedMessageId:(nullable NSString*)quotedMessageId;

/// Clear all messages in a room Id for you.
- (void)clearChatsForRoomId:(NSString*)strRoomId withCompletionBlock:(ChatOperationCompletionBlock)completionBlock;

/// Delete a chat room for you.
- (void)deleteChatRoom:(NSString*)strRoomId withCompletionBlock:(ChatOperationCompletionBlock)completionBlock;

/// Delete a message for you or for all.
- (void)deleteMessageForMessageId:(NSString*)strMessageId roomId:(NSString*)strRoomId deleteType:(enum DeleteType)deleteType withCompletionBlock:(ChatOperationCompletionBlock)completionBlock;

/// Get last seen of a individual user.
- (void)getUserLastSeen:(NSString *)userId
    withCompletionBlock:(UserLastSeenCompletionBlock)completionBlock;

/// Set this delegate to receive new message event.
- (void)setNewMessageReceivedDelegate:(id <YuWeeNewMessageReceivedDelegate>) listenerObject;

/// Set this delegate to know when other users are typing.
- (void)setTypingEventDelegate:(id <YuWeeTypingEventDelegate>) listenerObject;

/// Set this delegate to know when message is delivered.
- (void)setMessageDeliveredDelegate:(id <YuWeeMessageDeliveredDelegate>) listenerObject;

/// Forward a message in a room.
- (void) forwardMessage:(NSString*)message withRoomId:(NSString*)roomId withMessageIdentifier:(NSString*)messageIdentifier;

//- (void) forwardFile:(NSDictionary*)fileDictionary withRoomId:(NSString*) roomId withMessageIdentifier:(NSString*)messageIdentifier;

/// Add members in group using email.
- (void) addMembersInGroupByEmail:(NSString*)roomId withArrayOfEmails:(NSArray*)emailArray withCompletionBlock:(AddMembersInGroupCompletionBlock)completionBlock;

/// Add members in group using user Id.
- (void) addMembersInGroupByUserId:(NSString*)roomId withArrayOfUserIds:(NSArray*)userArray withCompletionBlock:(AddMembersInGroupCompletionBlock)completionBlock;

/// Remove members from group using user Id.
- (void) removeMembersFromGroupByUserId:(NSString*)roomId withArrayOfUserIds:(NSArray*)userArray withCompletionBlock:(AddMembersInGroupCompletionBlock)completionBlock;

/// Remove members from group using email.
- (void) removeMembersFromGroupByEmail:(NSString*)roomId withArrayOfEmails:(NSArray*)emailArray withCompletionBlock:(AddMembersInGroupCompletionBlock)completionBlock;

/// Set this delegate to get message deletion event.
- (void) setMessageDeleteDelegate:(id <YuWeeMessageDeletedDelegate>) listenerObject;

/// Call this to access all file upload related methods.
- (FileManager*) getFileManager;

/// Get room details using room Id.
- (void) getRoomDetailsWithRoomId:(NSString*)roomId
              withCompletionBlock:(ChatOperationCompletionBlock)completionBlock;

/// Broadcast message in a room using room Id.
- (void) broadcastMessageWithRoomId:(NSString*)roomId
                        withMessage:(NSString*)message
                withUniqueMessageId:(NSString*)uniqueMessageId
                       withDelegate:(id <YuWeeBroadcastMessageDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
