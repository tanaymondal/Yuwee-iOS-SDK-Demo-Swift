//
//  FileManager.h
//  YuWee SDK
//  Copyright © Yuvitime XS Pte. Ltd. All rights reserved.

#import <Foundation/Foundation.h>
#import "YuWeeProtocol.h"

NS_ASSUME_NONNULL_BEGIN



@interface FileManager : NSObject

+ (instancetype)sharedInstance;
- (instancetype)init NS_UNAVAILABLE;

@property (strong,nonatomic) NSMutableArray *uploadQueue;

/// Fet AWS credention to use Yuwee aws storage.
- (void)getAwsCredentialsWithCompletionBlock:(OnGetAwsCredHandler)handler;

/// Set AWS credentials.
- (void)setupAwsCredentialWithAccessKey:(NSString*)accessKeyId
                    withSecretAccessKey:(NSString*)secretAccessKey
                       withSessionToken:(NSString*)sessionToken;

/// Initiate file share in room Id.
/// Call this method for a room before sending any file in room Id.
- (void)initFileShareWithRoomId:(NSString*)roomId
            withCompletionBlock:(OnInitFileShareCompletionHandler)completionHandler;

///Send file in a room.
- (void)sendFileWithRoomId:(NSString*)roomId
      withUniqueIdentifier:(NSString*)uniqueIdentidier
              withFileData:(NSData*)fileData
              withFileName:(NSString*)fileName
         withFileExtension:(NSString*)fileExtension
              withFileSize:(unsigned long)fileSize;

/// Send file upload delegate to get file upload progress, file upload success, file upload failure events.
- (void)setUploadDelegate:(nonnull id <YuWeeFileUploadDelegate>)delegate;

/// Get file URL with file Id.
- (void)getFileUrlWithFileId:(NSString*)fileId
                 withFileKey:(NSString*)fileKey
         withCompletionBlock:(OnInitFileShareCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
