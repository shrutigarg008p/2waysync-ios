
#import "Utility.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#import <netdb.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <sys/utsname.h>
@implementation Utility
+(CGFloat)heightOfTextForString:(NSString *)aString andFont:(UIFont *)aFont maxSize:(CGSize)aSize
{
    // iOS7
    
    CGSize sizeOfText = [aString boundingRectWithSize: aSize
                                              options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                           attributes: [NSDictionary dictionaryWithObject:aFont
                                                                                   forKey:NSFontAttributeName]
                                              context: nil].size;
    
    return ceilf(sizeOfText.height);
    
}

+(UIView *)loadViewFromNib:(NSString *)nibName forClass:(id)forClass{
    
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    for(id currentObject in topLevelObjects)
        if([currentObject isKindOfClass:forClass])
        {
            
            return currentObject ;
        }
    
    return nil;
    
    
}
+(UIView *)addLeftView:(UIImage *)iconImage andSelector:(SEL)selector target:(id)target
{
    UIView *contenarView=[[UIView alloc]initWithFrame:CGRectMake(0, (40-iconImage.size.height)/2, 60, 40)];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 60, 40);
    leftButton.backgroundColor=[UIColor clearColor];
    [leftButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [leftButton setImage:iconImage forState:UIControlStateNormal];
    [leftButton setImage:iconImage forState:UIControlStateHighlighted];
    [leftButton setImage:iconImage forState:UIControlStateSelected];
    [contenarView addSubview:leftButton];
    
    contenarView.backgroundColor=[UIColor clearColor];

    return contenarView;
}
+(UIBarButtonItem*)negativeSpacerWithWidth:(NSInteger)width {
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                             target:nil
                             action:nil];
    item.width = (width >= 0 ? -width : width);
    return item;
}

+(NSString*) deviceModel
{
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    
    static NSDictionary* deviceNamesByCode = nil;
    
    if (!deviceNamesByCode) {
        
        deviceNamesByCode = @{@"i386"      :@"Simulator",
                              @"iPod1,1"   :@"iPod Touch",      // (Original)
                              @"iPod2,1"   :@"iPod Touch",      // (Second Generation)
                              @"iPod3,1"   :@"iPod Touch",      // (Third Generation)
                              @"iPod4,1"   :@"iPod Touch",      // (Fourth Generation)
                              @"iPhone1,1" :@"iPhone",          // (Original)
                              @"iPhone1,2" :@"iPhone",          // (3G)
                              @"iPhone2,1" :@"iPhone",          // (3GS)
                              @"iPad1,1"   :@"iPad",            // (Original)
                              @"iPad2,1"   :@"iPad 2",          //
                              @"iPad3,1"   :@"iPad",            // (3rd Generation)
                              @"iPhone3,1" :@"iPhone 4",        // (GSM)
                              @"iPhone3,3" :@"iPhone 4",        // (CDMA/Verizon/Sprint)
                              @"iPhone4,1" :@"iPhone 4S",       //
                              @"iPhone5,1" :@"iPhone 5",        // (model A1428, AT&T/Canada)
                              @"iPhone5,2" :@"iPhone 5",        // (model A1429, everything else)
                              @"iPad3,4"   :@"iPad",            // (4th Generation)
                              @"iPad2,5"   :@"iPad Mini",       // (Original)
                              @"iPhone5,3" :@"iPhone 5c",       // (model A1456, A1532 | GSM)
                              @"iPhone5,4" :@"iPhone 5c",       // (model A1507, A1516, A1526 (China), A1529 | Global)
                              @"iPhone6,1" :@"iPhone 5s",       // (model A1433, A1533 | GSM)
                              @"iPhone6,2" :@"iPhone 5s",       // (model A1457, A1518, A1528 (China), A1530 | Global)
                              @"iPhone7,1" :@"iPhone 6 Plus",   //
                              @"iPhone7,2" :@"iPhone 6",        //
                              @"iPad4,1"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Wifi
                              @"iPad4,2"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Cellular
                              @"iPad4,4"   :@"iPad Mini",       // (2nd Generation iPad Mini - Wifi)
                              @"iPad4,5"   :@"iPad Mini"        // (2nd Generation iPad Mini - Cellular)
                              };
    }
    
    NSString* deviceName = [deviceNamesByCode objectForKey:code];
    
    if (!deviceName) {
        // Not found on database. At least guess main device type from string contents:
        
        if ([code rangeOfString:@"iPod"].location != NSNotFound) {
            deviceName = @"iPod Touch";
        }
        else if([code rangeOfString:@"iPad"].location != NSNotFound) {
            deviceName = @"iPad";
        }
        else if([code rangeOfString:@"iPhone"].location != NSNotFound){
            deviceName = @"iPhone";
        }
    }
    
    return deviceName;
}
/*
+(NSString *) platformType
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];

    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (China)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3 (2013)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}
*/
+(NSString*)getLocalIP
{
    NSString *address = Nil;// @"novalue";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    NSString *wifiAddress = nil;
    NSString *cellAddress = nil;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
#if TARGET_IPHONE_SIMULATOR
                NSString *interface = @"en1";
                NSLog(@"interface=%@",interface);
#else
                //NSString *interface = @"en0";
#endif
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0
                NSLog(@"NAME: \"%@\" addr: %@", name, addr);
                //if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:interface])
                
                if([name isEqualToString:@"en1"])
                {
                    // Get NSString from C String
                    wifiAddress = addr; //[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
                else if([name isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    wifiAddress = addr; //[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
                else if([name isEqualToString:@"pdp_ip0"])
                {
                    // Interface is the cell connection on the iPhone
                    cellAddress = addr;
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    address = wifiAddress ? wifiAddress : cellAddress;
    
    address = address ? address : @"0.0.0.0";
    
    NSLog(@"LocalIP: %@",address);
    
    return address;
    
}

+(NSString*)getStringFromDate:(NSDate*)date type:(int)type {
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:date];
    if (timeInterval<0) {
        timeInterval=-timeInterval;
        
    }
    
    if(timeInterval>=86400) {
        int days = (timeInterval/86400);
        switch (type) {
            case 1:
                return [NSString stringWithFormat:@"%dd",days];
                
                break;
                
            default:{
                if (days==1) {
                    return [NSString stringWithFormat:@"%d day",days];
                    
                }
                else{
                    return [NSString stringWithFormat:@"%d days",days];
                    
                }
                
            }
                
                break;
        }
    }
    
    else if(timeInterval>=3600) {
        int hours = (timeInterval/3600);
        switch (type) {
            case 1:
                return [NSString stringWithFormat:@"%dh",hours];
                
                break;
                
            default:{
                if (hours==1) {
                    return [NSString stringWithFormat:@"%d hour",hours];
                    
                }
                else{
                    return [NSString stringWithFormat:@"%d hours",hours];
                    
                }
                
            }
                
                break;
        }
        
    }
    
    else if(timeInterval>=60) {
        
        int minutes = timeInterval/60;
        switch (type) {
            case 1:
                return [NSString stringWithFormat:@"%dm",minutes];
                
                break;
                
            default:
                return [NSString stringWithFormat:@"%d minutes",minutes];
                
                break;
        }
    }
    
    else {
        int seconds = timeInterval;
        if(seconds<0)
            seconds = 0;
        switch (type) {
            case 1:
                return [NSString stringWithFormat:@"%ds",seconds];
                
                break;
                
            default:
                return [NSString stringWithFormat:@"%d seconds",seconds];
                
                break;
        }
        
    }
}

+(void)setRoundedView:(UIImageView *)roundedView toDiameter:(float)newSize
{
    
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
    roundedView.clipsToBounds = YES;
    roundedView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    roundedView.layer.borderWidth = 2.5;
    
}
+(void)setRoundedView:(UIImageView *)roundedView toDiameter:(float)newSize toBoarderColor:(UIColor *)color
{
    //  UIImage *image = [UIImage imageNamed:@"home_screen"];
    // NSLog(@"%f",image.size.width);
    
    
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
    roundedView.clipsToBounds = YES;
    roundedView.layer.borderColor = color.CGColor;
    roundedView.layer.borderWidth = 2.5;
    
    
}
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

+(void)showAlertForError:(NSError*)error andTitle:(NSString *)title inViewController:(UIViewController *)viewcontroller {
    
  //  [Utility showAlertWithString:[NSString stringWithFormat:@"%@",error.localizedDescription]];
    
    
    [Utility showAlertWithString:[NSString stringWithFormat:@"%@",error.localizedDescription] andTitle:title inViewController:viewcontroller];
    
}

+(void)showAlertWithString:(NSString*)message andTitle:(NSString *)title inViewController:(UIViewController *)viewcontroller{
    
//    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alertView show];
    
    
    //  create controller
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                       
                                       
                                   }];
    //
    //    UIAlertAction *okAction = [UIAlertAction
    //                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
    //                               style:UIAlertActionStyleDefault
    //                               handler:^(UIAlertAction *action)
    //                               {
    //
    //                               }];
    
    [alertController addAction:cancelAction];
    // [alertController addAction:okAction];
    
    
    [viewcontroller presentViewController:alertController animated:YES completion:nil];
    
    
    
}

+(void) paddingTextField:(UITextField *) textField
{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 20)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
}


+(void) paddingTextFieldInSearchController:(UITextField *) textField
{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    
}
+(NSString *)getRandomNumberString
{
    NSArray *array=[NSArray arrayWithObjects:@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
    NSMutableArray *valurArray=[[NSMutableArray alloc]init];
    
    for (int j=0; j<10; j++) {
        int position=arc4random()%36;
        // NSLog(@"%@",[array objectAtIndex:position]);
        [valurArray addObject:[array objectAtIndex:position]];
    }
    NSString *string=[valurArray componentsJoinedByString:@""];
    
    return string;
    
}
+(BOOL)notNull:(id)object{
    
    if(![object isEqual:[NSNull null]] && object != nil )
        return YES;
    
    return NO;
}
@end
