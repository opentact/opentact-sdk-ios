//
//  OpentactUA.h
//  OpentactSDK
//
//  Created by hewx on 15/2/4.
//  Copyright (c) 2015年 org.opentact. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pjsua-lib/pjsua.h>

@interface OpentactUA : NSObject

+ (OpentactUA *)sharedOpentactUA;

- (BOOL)registerToDomain:(NSString *)domain
                withUser:(NSString *)user
             andPassword:(NSString *)password
              onRegister:(void (^)(BOOL))registerCallback
          onIncomingCall:(void (^)(NSString *sid))incomingCallCallback
                onHangon:(void (^)(void))hangonCallback
                onHangup:(void (^)(void))hangupCallback
                  onRing:(void (^)(void))ringCallback;

- (BOOL)dialToUri: (NSString *)uri;
- (void)answer;
- (void)hangup;
- (void)keepAlive;

@end
