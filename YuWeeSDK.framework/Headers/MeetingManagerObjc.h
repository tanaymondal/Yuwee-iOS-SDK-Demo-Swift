//
//  MeetingManagerObjc.h
//  YuWee SDK
//  Copyright © Yuvitime XS Pte. Ltd. All rights reserved.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>
#import "YuweeVideoView.h"
#import "YuWeeProtocol.h"
#import "EditMeetingBody.h"
#import "MeetingParams.h"
#import "MuteUnmuteBody.h"
#import "HandRaiseBody.h"
#import "HostMeetingBody.h"
#import "CallAdminBody.h"
#import "CallPresenterBody.h"
#import "RegisterMeetingBody.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^OnMeetingCompletionHandler)(NSDictionary *dict, BOOL success);
typedef void(^OnStartRecordingCompletionHandler)(NSDictionary *dict, BOOL isSuccess);
typedef void(^OnStopRecordingCompletionHandler)(NSString* message, BOOL isSuccess);

typedef NS_ENUM(NSUInteger, RoleType) {
    presenter,
    subPresenter,
    viewer,
};

@interface MeetingManagerObjc : NSObject

+ (nonnull instancetype)sharedInstance;
- (nonnull instancetype)init NS_UNAVAILABLE;

/// Set this delegate to get all events of a meeting.
- (void)setMeetingDelegate:(nonnull id <OnHostedMeetingDelegate>)listenerObject;

/// Call this method to join a meeting.
- (void)joinMeeting:(MeetingParams*)meetingParams
       withlistener:(OnMeetingCompletionHandler)completionHandler;

/// Host a meeting.
- (void)hostMeeting:(HostMeetingBody*)hostMeetingBody
       withlistener:(OnMeetingCompletionHandler)completionHandler;

/// Register a meeting before calling join meeting.
-(void)registerInMeeting:(RegisterMeetingBody*)registerMeetingBody
            withlistener:(OnMeetingCompletionHandler)completionHandler;

/// Get all available remote streams on a meeting.
- (NSMutableArray<OWTRemoteStream *> *)getAllRemoteStream;

/// Attache local camera stream on view.
- (void)attachLocalCameraStream:(YuweeVideoView *)videoView;

/// Detach local camera stream from view.
- (void)detachLocalCameraStream:(YuweeVideoView *)videoView;

/// Attach remote stream on view.
- (void)attachRemoteStream:(OWTRemoteStream*)stream
             withVideoView:(YuweeVideoView*)videoView;

/// Detach remote stream from view.
- (void)detachRemoteStream:(OWTRemoteStream *)stream
                 videoView:(YuweeVideoView *)videoView;

/// Subscribe a remote stream to before you can attach the stream on view.
- (void)subscribeRemoteStream:(OWTRemoteStream *)stream
                 withlistener:(id<YuWeeRemoteStreamSubscriptionDelegate>)listener;

/// Publish camera stream.
- (void)publishCameraStream:(RoleType)roleType
               withlistener:(OnMeetingCompletionHandler)completionHandler;

/// Unpublish camera stream.
- (void)unpublishCameraStream;

/// Swicth camera.
- (void)switchCamera:(RoleType)roleType
        withlistener:(OnMeetingCompletionHandler)completionHandler;

/// Enable or disable audio output to speaker.
- (void)setSpeakerEnabled:(BOOL)isSpeakerEnabled;

/// Enable or disable audio or video.
- (void)setMediaEnabled:(BOOL)isAudioEnabled
       withVideoEnabled:(BOOL)isVideoEnabled
           withlistener:(OnMeetingCompletionHandler)completionHandler;

/// Leave a meeting.
- (void)leaveMeeting:(OnMeetingCompletionHandler)completionHandler;

/// End a meeting. Only admin can end a meeting.
- (void)endMeeting:(OnMeetingCompletionHandler)completionHandler;

/// Fetch all active meetings.
- (void)fetchActiveMeetings:(OnMeetingCompletionHandler)completionHandler;

/// Delete a meeting.
- (void)deleteMeeting:(NSString*)meetingTokenId
         withlistener:(OnMeetingCompletionHandler)completionHandler;

/// Edit a meeting.
- (void)editMeeting:(EditMeetingBody*)body
       withlistener:(OnMeetingCompletionHandler)completionHandler;

/// Toggle participant's audio. Only admin can perform this action.
- (void)toggleParticipantAudio:(MuteUnmuteBody*)body
                  withlistener:(OnMeetingCompletionHandler)completionHandler;

/// Toggle hand raise.
- (void)toggleHandRaise:(HandRaiseBody*)body
           withlistener:(OnMeetingCompletionHandler)completionHandler;

/// Drop a participant. Only admin can peform this action.
- (void)dropParticipant:(NSString*)userId
           withlistener:(OnMeetingCompletionHandler)completionHandler;

/// Update role of a participant. Only admin can perform this action.
- (void)updateParticipantRole:(CallPresenterBody*)body
                     roleType:(RoleType)roleType
                 withlistener:(OnMeetingCompletionHandler)completionHandler;


/// Make or revoke admin status of a participant. Only admin can peform this action.
- (void)makeOrRevokeAdmin:(CallAdminBody*)body
             withlistener:(OnMeetingCompletionHandler)completionHandler;

/// Fetch all active participant list in a meeting.
- (void)fetchActiveParticipantsList:(OnMeetingCompletionHandler)completionHandler;

/// Start call recording in a meeting. Only admin can perform this action.
-(void)startCallRecordingWithRoleType:(RoleType)roleType
                     withSenderUserId:(NSString*)senderUserId
                          withMongoId:(NSString*)mongoId
                  withCompletionBlock:(OnStartRecordingCompletionHandler)handler;

/// Stop call recording in a meeting. Only admin can perform this action.
-(void)stopCallRecordingWithRecordingId:(NSString*)recordingId
                            withMongoId:(NSString*)mongoId
                      withIsRoleUpdated:(BOOL)isRoleUpdated
                    withCompletionBlock:(OnStopRecordingCompletionHandler)handler;

@end

NS_ASSUME_NONNULL_END
