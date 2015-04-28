//
//  OpentactIM.h
//  OpentactSDK
//
//  Created by hewx on 15/1/20.
//  Copyright (c) 2015年 hewx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQTTSession.h"

/**
 * The callback for incoming message.
 */
typedef void (^IncomingMessage)(NSString *message);

@interface OpentactIM : NSObject

/**
 * Get the singleton OpentactIM
 */
+ (OpentactIM *)sharedOpentactIM;


@property (strong, nonatomic)MQTTSession *session;

- (void) registerToHost: (NSString *)host
           withClientId: (NSString *)clientID
            andUserName: (NSString *)username
            andPassword: (NSString *)password
               andTopic: (NSString *)topic
     andIncomingMessage: (IncomingMessage)incomingMessage;

- (void) sendMessage: (NSString *)message toTopic: (NSString *)topic;

- (void) disconnect;

@end

