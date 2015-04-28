//
//  OpentactIM.m
//  OpentactSDK
//
//  Created by hewx on 15/1/20.
//  Copyright (c) 2015年 hewx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpentactIM.h"

@implementation OpentactIM

static OpentactIM* sharedInstance = nil;

+(OpentactIM *)sharedOpentactIM
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc]init];
    });
    return sharedInstance;
}

- (void) registerToHost: (NSString *)host
            withClientId: (NSString *)clientID
             andUserName: (NSString *)username
             andPassword: (NSString *)password
                andTopic: (NSString *)topic
      andIncomingMessage: (IncomingMessage)incomingMessage
{
    self.session = [[MQTTSession alloc] initWithClientId:clientID userName:username
                                                password:password keepAlive:60 cleanSession:NO];
    [self.session connectToHost:host port:1883 withConnectionHandler:^(MQTTSessionEvent event) {
        switch (event) {
            case MQTTSessionEventConnected:
                NSLog(@"connected");
                break;
            case MQTTSessionEventConnectionRefused:
                NSLog(@"connection refused");
                break;
            case MQTTSessionEventConnectionClosed:
                NSLog(@"connection closed");
                break;
            case MQTTSessionEventConnectionError:
                NSLog(@"connection error");
                NSLog(@"reconnecting...");
                [self.session connectToHost:host port:1883];
                // Forcing reconnection
                break;
            case MQTTSessionEventProtocolError:
                NSLog(@"protocol error");
                break;
        }
    } messageHandler:^(NSData *data, NSString *topic) {
        NSString *payloadString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"new message: %@", payloadString);
        incomingMessage(payloadString);
    }];
    
    [self.session subscribeToTopic:topic atLevel:1];
}

- (void) sendMessage: (NSString *)message toTopic: (NSString *)topic
{
    NSData* pubData=[message dataUsingEncoding:NSUTF8StringEncoding];
    [self.session publishDataAtLeastOnce:pubData onTopic:topic];
}

- (void) disconnect
{
    self.session = nil;
}

@end
