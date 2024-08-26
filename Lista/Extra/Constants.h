
#ifndef Constants_h
#define Constants_h

#import "APIManager.h"
#import "AppDelegate.h"
#import "AFNetworkReachabilityManager.h"
#import "DataBaseTask.h"
#import "iToast/iToast.h"
#import "ViewAllDataViewController.h"
#import "UpdateViewController.h"
#import "Utility/Utility.h"
#import "ViewController.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//Client URL--->
#define kBaseURL @"http://52.66.58.148/Kbbs/"
#define kDatabase @"mowindemo"
#define kDBUser @"root"
#define kDBPass @"oACT71QGeSo3sbsP"
#define kServer @"localhost"
#define kDeviceID  [[[[UIDevice currentDevice]identifierForVendor] UUIDString]stringByReplacingOccurrencesOfString:@"-" withString:@""]

#define k_MessageGetData @"No data available. Please try again."
#define k_MessagePostData @"Please try again."

#define k_defaultThemeColor [UIColor colorWithRed:20.0/255.0 green:177.0/255.0 blue:138.0/255.0 alpha:1.0] //light green


#endif /* Constants_h */
