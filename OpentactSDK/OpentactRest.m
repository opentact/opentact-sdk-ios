//
//  OpentactRest.m
//  OpentactSDK
//
//  Created by hewx on 15/2/5.
//  Copyright (c) 2015年 org.opentact. All rights reserved.
//

#import "OpentactRest.h"
#import "AFNetworking.h"

@implementation OpentactRest

static OpentactRest* sharedInstance = nil;


+ (OpentactRest *)sharedOpentactRest
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc]init];
    });
    return sharedInstance;
}


- (void)setHost: (NSString *)host
    andUserName: (NSString *)username
    andPassword: (NSString *)password
   usingVersion: (NSString *)version
{
    self.host = host;
    self.username = username;
    self.password = password;
    self.version = version;
}

- (void) subAccountBySid: (NSString *)sid
             withSuccess: (void (^)(id))success
{
    NSError *error = nil;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceNone];
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:[NSString stringWithFormat: @"https://%@/%@/accounts/%@.json", self.host, self.version, sid] parameters:nil error:&error];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.securityPolicy.allowInvalidCertificates = YES;
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        success(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
    [manager.operationQueue addOperation:operation];
}

- (void) sipAccountBySid: (NSString *)sid
             withSuccess: (void (^)(id))success
{
    NSError *error = nil;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceNone];
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:[NSString stringWithFormat: @"https://%@/%@/accounts/%@/sip.json", self.host, self.version, sid] parameters:nil error:&error];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.securityPolicy.allowInvalidCertificates = YES;
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            success(responseObject);
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
    [manager.operationQueue addOperation:operation];
}

- (void) imAccountBySid: (NSString *)sid
            withSuccess: (void (^)(id))success
{
    NSError *error = nil;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceNone];
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:[NSString stringWithFormat: @"https://%@/%@/accounts/%@/im.json", self.host, self.version, sid] parameters:nil error:&error];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.securityPolicy.allowInvalidCertificates = YES;
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            success(responseObject);
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
    [manager.operationQueue addOperation:operation];
}

- (void) sipAccountByNumber: (NSString *)number
                withSuccess: (void (^)(id)) success
{
    NSError *error = nil;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceNone];
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:[NSString stringWithFormat: @"https://%@/%@/numbers/%@.json", self.host, self.version, number] parameters:nil error:&error];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.securityPolicy.allowInvalidCertificates = YES;
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            success(responseObject);
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
    [manager.operationQueue addOperation:operation];
}

- (void) getFriendsBySid:(NSString *)sid
             withSuccess: (void (^)(id)) success
{
    NSError *error = nil;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceNone];
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:[NSString stringWithFormat: @"https://%@/%@/friends/%@.json", self.host, self.version, sid] parameters:nil error:&error];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.securityPolicy.allowInvalidCertificates = YES;
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            success(responseObject);
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [manager.operationQueue addOperation:operation];
}

- (void) createSubAccountWithName: (NSString *)name
                      withSuccess: (void (^)(id)) success
{
    NSError *error = nil;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceNone];
    
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"POST" URLString:[NSString stringWithFormat: @"https://%@/%@/accounts.json", self.host, self.version] parameters:@{@"name": name} error:&error];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.securityPolicy.allowInvalidCertificates = YES;
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            success(responseObject);
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [manager.operationQueue addOperation:operation];
}

@end
