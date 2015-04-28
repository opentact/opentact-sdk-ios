//
//  OpentactRest.h
//  OpentactSDK
//
//  Created by hewx on 15/2/5.
//  Copyright (c) 2015年 org.opentact. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpentactRest : NSObject


+ (OpentactRest *)sharedOpentactRest;


- (void)setHost: (NSString *)host
    andUserName: (NSString *)username
    andPassword: (NSString *)password
   usingVersion: (NSString *)version;

@property (strong, nonatomic)NSString *host;
@property (strong, nonatomic)NSString *username;
@property (strong, nonatomic)NSString *password;
@property (strong, nonatomic)NSString *version;

- (void) subAccountBySid: (NSString *)sid
             withSuccess: (void (^)(id))success;

- (void) sipAccountBySid: (NSString *)sid
             withSuccess: (void (^)(id))success;

- (void) imAccountBySid: (NSString *)sid
            withSuccess: (void (^)(id))success;

- (void) sipAccountByNumber: (NSString *)number
                withSuccess: (void (^)(id)) success;

- (void) getFriendsBySid:(NSString *)sid
             withSuccess: (void (^)(id)) success;
@end
