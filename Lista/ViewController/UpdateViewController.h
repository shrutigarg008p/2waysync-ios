#import "Constants.h"
#import <sqlite3.h>

@protocol dataUpdateSuccess <NSObject>

-(void)dataUpdatedSucessfully;

@end

@interface UpdateViewController : UIViewController
{
    
    
}
@property (weak, nonatomic) id <dataUpdateSuccess> dataUpdateSuccessDelegate;
@property(nonatomic, retain)NSDictionary *dict_SingleRecord;
@property (weak, nonatomic) IBOutlet UITextField *textfield_Montor;
@property (weak, nonatomic) IBOutlet UITextField *textfield_Datum;
@property (weak, nonatomic) IBOutlet UITextField *textfield_Tid1;
@property (weak, nonatomic) IBOutlet UITextField *textfield_Order;
@property (weak, nonatomic) IBOutlet UITextField *textfield_Tid2;
@property (weak, nonatomic) IBOutlet UITextField *textfield_Todo;
@property (weak, nonatomic) IBOutlet UITextField *textfield_BokadTyp;
@property (weak, nonatomic) IBOutlet UITextField *textfield_Avslutad;
@property (weak, nonatomic) IBOutlet UITextField *textfield_Editedby;
@property (weak, nonatomic) IBOutlet UIButton *button_SaveData;
- (IBAction)button_saveDataClicked:(UIButton *)sender;

@end
