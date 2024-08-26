

//  NetworkEngine.m
//  Omini
//  Created by Signity on 18/12/14.
//  Copyright (c) 2014 Signity. All rights reserved.


#import "APIManager.h"
#import "Constants.h"


static APIManager *sharedAPIManager = nil;
@implementation APIManager

+(id)sharedAPIManager{
    
    @synchronized(self) {
        
        if (sharedAPIManager == nil)
            sharedAPIManager = [[self alloc]init];
        
    }

    return sharedAPIManager;
    
    
}

-(id)init {
    
    self = [super init];
    
    if(self) {
        
        self.httpManager = [AFHTTPSessionManager manager];
        self.httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json", @"text/javascript", nil];
//        [self.httpManager.requestSerializer setAuthorizationHeaderFieldWithUsername:nil password:nil];
     //   [self.httpManager.requestSerializer setTimeoutInterval:18000];
        [self.httpManager.requestSerializer setTimeoutInterval:30];

    }
    
    return self;
    
}
-(void)getAllDatabaseTableConfiguration:(completion_block)completionBlock onError:(error_block)errorBlock params:(NSDictionary*)params{
    
    [self.httpManager GET:kBaseURL@"Gets/getTable.php" parameters:params progress:nil success:^(NSURLSessionDataTask *tsk,id responseObject){
        
        completionBlock(responseObject);
        
    }failure:^(NSURLSessionDataTask *tsk, NSError *error){
        
        errorBlock(error);
        
    }];
    
}
-(void)getDataFromServerForTableName:(completion_block)completionBlock onError:(error_block)errorBlock params:(NSDictionary*)params{
    
    [self.httpManager GET:kBaseURL@"Gets/getDataFromTable.php" parameters:params progress:nil success:^(NSURLSessionDataTask *tsk,id responseObject){
        
        completionBlock(responseObject);
        
    }failure:^(NSURLSessionDataTask *tsk, NSError *error){
        
        errorBlock(error);
        
    }];
    
}

-(void)postDataFromDataBase:(completion_block)completionBlock onError:(error_block)errorBlock url:(NSString*)url{
    
    [self.httpManager POST:url parameters:nil progress:nil success:^(NSURLSessionDataTask *tsk,id responseObject){
        
        completionBlock(responseObject);
        
        
    }failure:^(NSURLSessionDataTask *tsk, NSError *error){
        
        errorBlock(error);
        
    }];
    
}
-(void)getDataFromServerDataBase:(completion_block)completionBlock onError:(error_block)errorBlock url:(NSString*)url{
    
    
    [self.httpManager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask *tsk,id responseObject){
        
        completionBlock(responseObject);
        
        
    }failure:^(NSURLSessionDataTask *tsk, NSError *error){
        
        errorBlock(error);
        
    }];
   
}

-(void)checkInWhichTableColumnsAreModified:(completion_block)completionBlock onError:(error_block)errorBlock params:(NSDictionary*)params{
    
    [self.httpManager GET:kBaseURL@"Gets/UpdateAdditionlField.php" parameters:params progress:nil success:^(NSURLSessionDataTask *tsk,id responseObject){
        
        completionBlock(responseObject);
        
    }failure:^(NSURLSessionDataTask *tsk, NSError *error){
        
        errorBlock(error);
        
    }];
    
}

-(void)sendLocalDataToServerAPICall:(completion_block)completionBlock serviceUrl:(NSString *)serviceUrl onError:(error_block)errorBlock params:(NSDictionary*)params{
    
    [self.httpManager POST:serviceUrl parameters:params progress:nil success:^(NSURLSessionDataTask *tsk,id responseObject){
        
        completionBlock(responseObject);
        
    }failure:^(NSURLSessionDataTask *tsk, NSError *error){
        
        errorBlock(error);
        
    }];
    
}
-(void)syncUpdateDataFromServerToLocalAPICall:(completion_block)completionBlock serviceUrl:(NSString *)serviceUrl onError:(error_block)errorBlock params:(NSDictionary*)params{
    
    [self.httpManager POST:serviceUrl parameters:params progress:nil success:^(NSURLSessionDataTask *tsk,id responseObject){
        
        completionBlock(responseObject);
        
    }failure:^(NSURLSessionDataTask *tsk, NSError *error){
        
        errorBlock(error);
        
    }];
    
}
@end
