/*

iToast.m

MIT LICENSE

Copyright (c) 2011 Guru Software

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/


#import "iToast.h"
#import <QuartzCore/QuartzCore.h>



@implementation iToast
+(void)showToast:(NSString *)toastMessage{
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        UIWindow * keyWindow = [[UIApplication sharedApplication] keyWindow];
        UILabel *toastView = [[UILabel alloc] init];
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15]};
        CGSize expectedLabelSize = [toastMessage sizeWithAttributes:attributes];
        toastView.frame = CGRectMake(0, 0.0, expectedLabelSize.width + 40, 40.0);
        toastView.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        toastView.text = toastMessage;
        toastView.textAlignment = NSTextAlignmentCenter;
        toastView.textColor = [UIColor whiteColor];
        toastView.layer.cornerRadius = 20;
        toastView.layer.masksToBounds = YES;
        toastView.center = CGPointMake(keyWindow.bounds.size.width/2, keyWindow.bounds.size.height - toastView.bounds.size.height - 20);
        toastView.backgroundColor = [UIColor blackColor];
        toastView.alpha = 0.8;

        [keyWindow addSubview:toastView];
        
        [UIView animateWithDuration: 5.0f
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             
                             toastView.alpha = 0.0;
                         }
                         completion: ^(BOOL finished) {
                             
                             [toastView removeFromSuperview];
                         }
         ];
    }];

    
}

@end
