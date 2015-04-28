//
//  OpentactSDK.m
//  OpentactSDK
//
//  Created by hewx on 15/2/5.
//  Copyright (c) 2015年 org.opentact. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpentactSDK.h"
#import "OpentactIM.h"
#import "OpentactUA.h"

NSString* REST_SERVER = @"108.165.2.111";
NSString* VERSION = @"v1";
NSString* SIP_SERVER = @"108.165.2.111:5060";
NSString* IM_SERVER = @"108.165.2.111";

@interface OpentactSDK()
{
    
}


@end


@implementation OpentactSDK

static OpentactSDK* sharedInstance = nil;

+ (OpentactSDK *)sharedOpentactSDK
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc]init];
    });
    return sharedInstance;
}

- (void) setSid: (NSString *)sid
        andSsid:(NSString *)ssid
   andAuthToken:(NSString *)authToken
{
    self.sid = sid;
    self.ssid = ssid;
    self.authToken = authToken;
    [[OpentactRest sharedOpentactRest] setHost:REST_SERVER andUserName:sid andPassword:authToken usingVersion:VERSION];
}

- (void)startupVoiceOnRegister: (void (^)(BOOL isOK))registerCallback
                onIncomingCall: (void (^)(NSString *sid))incomingCallCallback
                      onHangup: (void (^)(void))hangupCallback
                      onHangon: (void (^)(void))HangonCallback
                        onRing:(void (^)(void))ringCallback
{
    NSLog(@"Staring sip");
    OpentactRest *rest = [OpentactRest sharedOpentactRest];
    [rest sipAccountBySid:self.ssid withSuccess:^(id data) {
        NSLog(@"Staring sip account rest webservice");
        NSDictionary *resDict = (NSDictionary *)data;
        NSString *sip_number = [resDict objectForKey:@"sip_number"];
        NSString *sip_password = [resDict objectForKey:@"sip_password"];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"Staring initial ua");
            OpentactUA *ua = [OpentactUA sharedOpentactUA];
            [ua registerToDomain:SIP_SERVER withUser:sip_number andPassword:sip_password onRegister:registerCallback onIncomingCall:incomingCallCallback onHangon:HangonCallback onHangup:hangupCallback onRing:ringCallback];
        }];
    }];
    
}

- (void)makeCallToSid: (NSString *)sid
{
    OpentactRest *rest = [OpentactRest sharedOpentactRest];
    [rest sipAccountBySid:sid withSuccess:^(id data) {
        NSDictionary *resDict = (NSDictionary *)data;
        NSString *sip_number = [resDict objectForKey:@"sip_number"];
        //NSString *uri = [NSString stringWithFormat:@"sip:11111%@@%@;transport=tcp", sip_number, SIP_SERVER];
        NSString *uri = [NSString stringWithFormat:@"sip:11111%@@%@", sip_number, SIP_SERVER];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            OpentactUA *ua = [OpentactUA sharedOpentactUA];
            [ua dialToUri:uri];
        }];
        
    }];
}

- (void)makeCallToTermination: (NSString *)number
{
    //NSString *uri = [NSString stringWithFormat:@"sip:99999%@@%@;transport=tcp", number, SIP_SERVER];
    NSString *uri = [NSString stringWithFormat:@"sip:99999%@@%@", number, SIP_SERVER];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        OpentactUA *ua = [OpentactUA sharedOpentactUA];
        [ua dialToUri:uri];
    }];
}

- (void)endCall
{
    OpentactUA *ua = [OpentactUA sharedOpentactUA];
    [ua hangup];
}


- (void)answerCall
{
    OpentactUA *ua = [OpentactUA sharedOpentactUA];
    [ua answer];
}

- (void)startupIMOnIncommingMessage:(void (^)(NSString *))incomingCallback
{
    OpentactIM *im = [OpentactIM sharedOpentactIM];
    [im registerToHost:IM_SERVER withClientId:self.ssid andUserName:self.ssid andPassword:self.authToken andTopic:[NSString stringWithFormat:@"opentact/%@/%@", self.sid, self.ssid] andIncomingMessage:incomingCallback];
    
}

- (void)sendMessage: (NSString *)message
              toSid: (NSString *)sid
{
    OpentactIM *im = [OpentactIM sharedOpentactIM];
    [im sendMessage:message toTopic:[NSString stringWithFormat:@"opentact/%@/%@", self.sid, sid]];
}

- (void)keepAlive
{
    [[OpentactUA sharedOpentactUA] keepAlive];
}


@end