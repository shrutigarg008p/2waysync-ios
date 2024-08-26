
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface Utility : NSObject<UIAlertViewDelegate>{
    
    
    
}
+(CGFloat)heightOfTextForString:(NSString *)aString andFont:(UIFont *)aFont maxSize:(CGSize)aSize;
+(void)setRoundedView:(UIImageView *)roundedView toDiameter:(float)newSize;
+(void)showAlertWithString:(NSString*)message andTitle:(NSString *)title inViewController:(UIViewController *)viewcontroller;
+(void)showAlertForError:(NSError*)error andTitle:(NSString *)title inViewController:(UIViewController *)viewcontroller;
+ (UIView *)loadViewFromNib:(NSString *)nibName forClass:(id)forClass;
+(void) paddingTextFieldInSearchController:(UITextField *) textField;
+(void) paddingTextField:(UITextField *) textField;
+(void)setRoundedView:(UIImageView *)roundedView toDiameter:(float)newSize toBoarderColor:(UIColor *)color;
//+(NSString *) platformType;
+(NSString*)getStringFromDate:(NSDate*)date type:(int)type ;
+(NSString*)getLocalIP;
+(NSString*) deviceModel;
+(UIView *)addLeftView:(UIImage *)iconImage andSelector:(SEL)selector target:(id)target;
+(UIBarButtonItem*)negativeSpacerWithWidth:(NSInteger)width;
+(NSString *)getRandomNumberString;
+(BOOL)notNull:(id)object;

@end
