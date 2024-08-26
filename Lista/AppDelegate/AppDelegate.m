////
//  AppDelegate.m
//  Lista
//
//  Created by ios on 15/11/18.
//

#import "Constants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
   
    [[UINavigationBar appearance] setBarTintColor:k_defaultThemeColor]; //light green
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    /*
     Create database at app launch.
     */
    [self checkAndCreateEditableDatabase];
    return YES;
    
}

#pragma mark Create real database copy into document directory...
-(void)checkAndCreateEditableDatabase{
    
    NSString *databaseName = @"bokatoklart5.sqlite";
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
    // Check if the SQL database has already been saved to the users phone, if not then copy it over
    BOOL success;
    
    // Create a FileManager object, we will use this to check the status
    // of the database and to copy it over if required
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Check if the database has already been created in the users filesystem
    success = [fileManager fileExistsAtPath:databasePath];
    
    // If the database already exists then return without doing anything
    if(success){
        return;
    }
    // If not then proceed to copy the database from the application to the users filesystem
    
    // Get the path to the database in the application package
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
    
    // Copy the database from the package to the users filesystem
    [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
    
}

#pragma mark**********************HUD methods**********************
-(void)showProgressHUD:(NSString*)labelText  {
    
    if(HUD){
        
        [HUD removeFromSuperview];
        HUD = nil;
        
    }
    
    HUD = [[MBProgressHUD alloc] initWithWindow:self.window];
    
    [self.window addSubview:HUD];
    
    HUD.labelText = labelText;
    
    UIDeviceOrientation ortn = [[UIDevice currentDevice] orientation];
    if(ortn == UIDeviceOrientationLandscapeLeft || ortn == UIDeviceOrientationLandscapeRight)
        HUD.labelText = @"";
    
    [HUD show:YES];
    
}
-(void)showProgressHUDWithText:(NSString*)labelText inView:(UIView*)view{
    
    if(HUD){
        
        [HUD removeFromSuperview];
        HUD = nil;
    }
    
    HUD = [[MBProgressHUD alloc] initWithView:view];
    
    [view addSubview:HUD];
    
    HUD.labelText = labelText;
    
    [HUD show:YES];
    
}

-(void)hideProgressHUD {
    
    if(HUD){
        
        [HUD removeFromSuperview];
        [HUD hide:YES];
        
    }
}

/*
HIDE FROM ONLY SUPERVIEW - USE THIS METHOD FOR ALL IN FUTURE
*/
 -(void)hideProgressHUDforView:(UIView *)view {
    
    if(HUD){
        
        [MBProgressHUD hideHUDForView:view animated:YES];
        
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
/*
 Implementation AppDelegate Singleton method.
 */
#pragma --mark global method
AppDelegate *apDelegate (void){
    
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}
