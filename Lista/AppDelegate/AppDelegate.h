//
//  AppDelegate.h
//  Lista
//
//  Created by ios on 15/11/18.
//

#import "Constants.h"
#import "MBProgressHUD.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    /*
     Show loader at API calling.
    */
    MBProgressHUD *HUD;

}
@property (strong, nonatomic) UIWindow *window;
/*
 Instance methods to show loader.
 */
-(void)showProgressHUDWithText:(NSString*)labelText inView:(UIView*)view;
-(void)showProgressHUD:(NSString*)labelText ;
-(void)hideProgressHUDforView:(UIView*)view;
-(void)hideProgressHUD;

@end
/*
 Singleton method created for AppDelegate.
*/
AppDelegate *apDelegate (void);

