//
//  NetworkEngine.h
//  Omini
//  Created by Signity on 18/12/14.
//  Copyright (c) 2014 Signity. All rights reserved.
//

/*
 
 Class used for declaring webservices. It is a sub class of NSObject.
 */

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void (^completion_block)(id object);
typedef void (^error_block)(NSError *error);
typedef void (^upload_completeBlock)(NSString *url);

@interface APIManager : NSObject {
    
    // dispatch_queue_t facebookQueue ;
   
}
@property(nonatomic,retain) AFHTTPSessionManager *httpManager;
+ (id)sharedAPIManager;
-(void)getAllDatabaseTableConfiguration:(completion_block)completionBlock onError:(error_block)errorBlock params:(NSDictionary*)params;
-(void)getDataFromServerForTableName:(completion_block)completionBlock onError:(error_block)errorBlock params:(NSDictionary*)params;
-(void)postDataFromDataBase:(completion_block)completionBlock onError:(error_block)errorBlock url:(NSString*)url;
-(void)getDataFromServerDataBase:(completion_block)completionBlock onError:(error_block)errorBlock url:(NSString*)url;
-(void)sendOTPAPICalled:(completion_block)completionBlock onError:(error_block)errorBlock params:(NSDictionary*)params;
-(void)checkInWhichTableColumnsAreModified:(completion_block)completionBlock onError:(error_block)errorBlock params:(NSDictionary*)params;
-(void)sendLocalDataToServerAPICall:(completion_block)completionBlock serviceUrl:(NSString *)serviceUrl onError:(error_block)errorBlock params:(NSDictionary*)params;
-(void)syncUpdateDataFromServerToLocalAPICall:(completion_block)completionBlock serviceUrl:(NSString *)serviceUrl onError:(error_block)errorBlock params:(NSDictionary*)params;
@end
