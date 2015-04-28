//
//  OpentactSDK.h
//  OpentactSDK
//
//  Created by hewx on 15/2/4.
//  Copyright (c) 2015年 org.opentact. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

//! Project version number for OpentactSDK.
FOUNDATION_EXPORT double OpentactSDKVersionNumber;

//! Project version string for OpentactSDK.
FOUNDATION_EXPORT const unsigned char OpentactSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <OpentactSDK/PublicHeader.h>

#import "OpentactRest.h"

@interface OpentactSDK : NSObject

@property (strong, nonatomic) NSString *sid;
@property (strong, nonatomic) NSString *ssid;
@property (strong, nonatomic) NSString *authToken;

+ (OpentactSDK *)sharedOpentactSDK;


- (void)setSid: (NSString *)sid
       andSsid:(NSString *)ssid
  andAuthToken:(NSString *)authToken;

- (void)startupVoiceOnRegister: (void (^)(BOOL isOK))registerCallback
                onIncomingCall: (void (^)(NSString *sid))incomingCallCallback
                      onHangup: (void (^)(void))hangupCallback
                      onHangon: (void (^)(void))HangonCallback
                        onRing:(void (^)(void))ringCallback;

- (void)makeCallToSid: (NSString *)sid;
- (void)makeCallToTermination: (NSString *)number;

- (void)endCall;

- (void)answerCall;
- (void)startupIMOnIncommingMessage:(void (^)(NSString *))incomingCallback;

- (void)sendMessage: (NSString *)message
              toSid: (NSString *)sid;

- (void)keepAlive;

@end

