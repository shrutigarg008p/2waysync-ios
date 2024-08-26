#import "Constants.h"
#import <sqlite3.h>

@interface UpdateViewController ()

@end

@implementation UpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Setting all editable fields value from last screen...
    _textfield_Montor.text = [NSString stringWithFormat:@"%@",_dict_SingleRecord[@"montor"]];
    _textfield_Datum.text = [NSString stringWithFormat:@"%@",_dict_SingleRecord[@"datum"]];
    _textfield_Tid1.text = [NSString stringWithFormat:@"%@",_dict_SingleRecord[@"tid1"]];
    _textfield_Order.text = [NSString stringWithFormat:@"%@",_dict_SingleRecord[@"order"]];
    _textfield_Tid2.text = [NSString stringWithFormat:@"%@",_dict_SingleRecord[@"tid2"]];
    _textfield_Todo.text = [NSString stringWithFormat:@"%@",_dict_SingleRecord[@"todo"]];
    _textfield_BokadTyp.text = [NSString stringWithFormat:@"%@",_dict_SingleRecord[@"bokadtyp"]];
    _textfield_Avslutad.text = [NSString stringWithFormat:@"%@",_dict_SingleRecord[@"avslutad"]];
    _textfield_Editedby.text = [NSString stringWithFormat:@"%@",_dict_SingleRecord[@"EditedBy"]];
   
    
    /*
     Add title in center of navigationbar...
     */
    [self addNavigationControllerActivities];
    
}
/*
 Set header's title...
 */

-(void)addNavigationControllerActivities
{
    
    NSString *strTitle = @"bokad";
    UILabel *_labelCenterTitle =  [[UILabel alloc] init];
    _labelCenterTitle.text = strTitle;
    CGFloat textWidth = [_labelCenterTitle.text sizeWithAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:18] }].width;
    _labelCenterTitle.frame = CGRectMake(0, 0, textWidth, 32);
    _labelCenterTitle.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = _labelCenterTitle;
    
}
#pragma mark ************---------Save Button Click----------************
- (IBAction)button_saveDataClicked:(UIButton *)sender{
    
        //Checking that entry is from master table or intermediate table...
        if([_dict_SingleRecord[@"isDataFromUserTableRecordForLocalData"] isEqualToString:@"yes"]){
         
            /*
             Here checking data exists in master table and version of data is same when fetch from table at list time, because this can be change by another user in between form editing time...
             */
             NSDictionary *dict_isExistsWithVersion = [DataBaseTask isRecordExistsInDataBaseForUserID:kDeviceID deviceID:kDeviceID tableName:@"UserTableRecordForLocalData" primaryKeyName:@"ID" primaryKeyValue:_dict_SingleRecord[@"ID"] versionColumnNumber:8]; //Here we are checking that entry is available in UserTableRecordForLocalData table or not...
            
            //Checking data existence and row version is same...
            if ([dict_isExistsWithVersion[@"isExists"] isEqualToString:@"yes"] && [dict_isExistsWithVersion[@"version"]integerValue] == [_dict_SingleRecord[@"version"]integerValue]) {

                /*
                 Need to update UserTableRecordForLocalData table with latest values from form, because this entry is already from UserTableRecordForLocalData table...
                */
                [self updateIntoUserTableRecordForLocalData];
                
            }else{
                
                [iToast showToast:@"Data couldn't be saved because this entry has been synced, please refresh data."];
                
            }
            
        }else{
            
            /*
             Here checking data exists in master table and version of data is same when fetch from table at list time, because this can be change by another user in between form editing time...
             */
            NSDictionary *dict_isExistsWithVersion = [DataBaseTask isRecordExistsInDataBaseForUserID:kDeviceID deviceID:kDeviceID tableName:@"bokad" primaryKeyName:@"ID" primaryKeyValue:_dict_SingleRecord[@"ID"] versionColumnNumber:10]; //Here we are checking that entry is available in Master table or not...
            
            //Checking data existence and row version is same...
            if ([dict_isExistsWithVersion[@"isExists"] isEqualToString:@"yes"] && [dict_isExistsWithVersion[@"version"]integerValue] == [_dict_SingleRecord[@"version"]integerValue]) {
                
                /*
                 Need to insert into UserTableRecordForLocalData table with latest values from form, because this entry need to send UserTableRecordForLocalData table...
                */
                [self insertIntoUserTableRecordForLocalData];
                

            }else{
                
                [Utility showAlertWithString:@"Data couldn't be saved, because this entry has been synced, please refresh data." andTitle:@"Alert" inViewController:self];

            }
        }
        
    }
/*
Need to update UserTableRecordForLocalData table, if entry is exists in intermediate table...
*/
-(void)updateIntoUserTableRecordForLocalData{
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    NSString *string_Montor = _textfield_Montor.text;
    string_Montor = [[NSString stringWithFormat:@"%@",string_Montor] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([string_Montor isEqual:[NSNull null]] || string_Montor == nil || string_Montor.length == 0){
        
        [Utility showAlertWithString:[NSString stringWithFormat:@"%@",@"Please enter montor value."] andTitle:@"Alert" inViewController:self];
        return;
        
    }
    
    
    NSString *string_Datum = _textfield_Datum.text;
    string_Datum = [[NSString stringWithFormat:@"%@",string_Datum] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([string_Datum isEqual:[NSNull null]] || string_Datum == nil || string_Datum.length == 0){
        
        [Utility showAlertWithString:[NSString stringWithFormat:@"%@",@"Please enter datum value."] andTitle:@"Alert" inViewController:self];
        return;
        
    }
    
    NSString *string_Tid1 = _textfield_Tid1.text;
    string_Tid1 = [[NSString stringWithFormat:@"%@",string_Tid1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([string_Tid1 isEqual:[NSNull null]] || string_Tid1 == nil || string_Tid1.length == 0){
        
        [Utility showAlertWithString:[NSString stringWithFormat:@"%@",@"Please enter tid1 value."] andTitle:@"Alert" inViewController:self];
        return;
        
    }
    
    NSString *string_Order = _textfield_Order.text;
    string_Order = [[NSString stringWithFormat:@"%@",string_Order] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([string_Order isEqual:[NSNull null]] || string_Order == nil || string_Order.length == 0){
        
        [Utility showAlertWithString:[NSString stringWithFormat:@"%@",@"Please enter order value."] andTitle:@"Alert" inViewController:self];
        return;
        
    }
    
    NSString *string_Tid2 = _textfield_Tid2.text;
    string_Tid2 = [[NSString stringWithFormat:@"%@",string_Tid2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([string_Tid2 isEqual:[NSNull null]] || string_Tid2 == nil || string_Tid2.length == 0){
        
        [Utility showAlertWithString:[NSString stringWithFormat:@"%@",@"Please enter tid2 value."] andTitle:@"Alert" inViewController:self];
        return;
        
    }
    
    NSString *string_Todo = _textfield_Todo.text;
    string_Todo = [[NSString stringWithFormat:@"%@",string_Todo] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([string_Todo isEqual:[NSNull null]] || string_Todo == nil || string_Todo.length == 0){
        
        [Utility showAlertWithString:[NSString stringWithFormat:@"%@",@"Please enter todo value."] andTitle:@"Alert" inViewController:self];
        return;
        
    }
    
    
    NSString *string_BokadTyp = _textfield_BokadTyp.text;
    string_BokadTyp = [[NSString stringWithFormat:@"%@",string_BokadTyp] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([string_BokadTyp isEqual:[NSNull null]] || string_BokadTyp == nil || string_BokadTyp.length == 0){
        
        [Utility showAlertWithString:[NSString stringWithFormat:@"%@",@"Please enter bokadtyp value."] andTitle:@"Alert" inViewController:self];
        return;
        
    }
    
    NSString *string_Avslutad = _textfield_Avslutad.text;
    string_Avslutad = [[NSString stringWithFormat:@"%@",string_Avslutad] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([string_Avslutad isEqual:[NSNull null]] || string_Avslutad == nil || string_Avslutad.length == 0){
        
        [Utility showAlertWithString:[NSString stringWithFormat:@"%@",@"Please enter avslutad value."] andTitle:@"Alert" inViewController:self];
        return;
        
    }
    
    
    NSString *string_Edited = _textfield_Editedby.text;
    string_Edited = [[NSString stringWithFormat:@"%@",string_Edited] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([string_Edited isEqual:[NSNull null]] || string_Edited == nil || string_Edited.length == 0){
        
        [Utility showAlertWithString:[NSString stringWithFormat:@"%@",@"Please enter editedby value."] andTitle:@"Alert" inViewController:self];
        return;
        
    }
    
    [dict setValue:[NSString stringWithFormat:@"%@",string_Montor] forKey:@"montor"];
    [dict setValue:[NSString stringWithFormat:@"%@",string_Datum] forKey:@"datum"];
    [dict setValue:[NSString stringWithFormat:@"%@",string_Tid1] forKey:@"tid1"];
    [dict setValue:[NSString stringWithFormat:@"%@",string_Order] forKey:@"order"];
    [dict setValue:[NSString stringWithFormat:@"%@",string_Tid2] forKey:@"tid2"];
    [dict setValue:[NSString stringWithFormat:@"%@",string_Todo] forKey:@"todo"];
    [dict setValue:[NSString stringWithFormat:@"%@",string_BokadTyp] forKey:@"bokadtyp"];
    [dict setValue:[NSString stringWithFormat:@"%@",string_Avslutad] forKey:@"avslutad"];
    [dict setValue:[NSString stringWithFormat:@"%@",string_Edited] forKey:@"EditedBy"];
    
    NSError  *errorRowData;
    NSData   *jsonrowData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&errorRowData];
    NSString *string_SingleRowJSONRecord = [[NSString alloc] initWithData:jsonrowData encoding:NSUTF8StringEncoding];
    
    
    //Here we are updating UserTableRecordForLocalData which is intermediate table...
    BOOL success = [DataBaseTask  updateIntoUserTableRecordForLocalData:string_SingleRowJSONRecord  primaryKeyValue:_dict_SingleRecord[@"ID"]];
    
        if (success) {
            
            //When data is successfully updated, then setting delegate for previous screen to refresh data...
            if([self.dataUpdateSuccessDelegate respondsToSelector:@selector(dataUpdatedSucessfully)]){
                
                [self.dataUpdateSuccessDelegate dataUpdatedSucessfully];
                
            }
            
            [iToast showToast:[NSString stringWithFormat:@"Data successfully updated."]];
            [self.navigationController popViewControllerAnimated:NO];
            
        }else{
            
            [Utility showAlertWithString:@"Data couldn't be update, because this entry has been synced, please refresh data." andTitle:@"Alert" inViewController:self];
        }
    
}
-(void)insertIntoUserTableRecordForLocalData{
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    NSString *string_Montor = _textfield_Montor.text;
    string_Montor = [[NSString stringWithFormat:@"%@",string_Montor] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([string_Montor isEqual:[NSNull null]] || string_Montor == nil || string_Montor.length == 0){
        
        [Utility showAlertWithString:[NSString stringWithFormat:@"%@",@"Please enter montor value."] andTitle:@"Alert" inViewController:self];
        return;
        
    }
    
    
    NSString *string_Datum = _textfield_Datum.text;
    string_Datum = [[NSString stringWithFormat:@"%@",string_Datum] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([string_Datum isEqual:[NSNull null]] || string_Datum == nil || string_Datum.length == 0){
        
        [Utility showAlertWithString:[NSString stringWithFormat:@"%@",@"Please enter datum value."] andTitle:@"Alert" inViewController:self];
        return;
        
    }
    
    NSString *string_Tid1 = _textfield_Tid1.text;
    string_Tid1 = [[NSString stringWithFormat:@"%@",string_Tid1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([string_Tid1 isEqual:[NSNull null]] || string_Tid1 == nil || string_Tid1.length == 0){
        
        [Utility showAlertWithString:[NSString stringWithFormat:@"%@",@"Please enter tid1 value."] andTitle:@"Alert" inViewController:self];
        return;
        
    }
    
    NSString *string_Order = _textfield_Order.text;
    string_Order = [[NSString stringWithFormat:@"%@",string_Order] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([string_Order isEqual:[NSNull null]] || string_Order == nil || string_Order.length == 0){
        
        [Utility showAlertWithString:[NSString stringWithFormat:@"%@",@"Please enter order value."] andTitle:@"Alert" inViewController:self];
        return;
        
    }
    
    NSString *string_Tid2 = _textfield_Tid2.text;
    string_Tid2 = [[NSString stringWithFormat:@"%@",string_Tid2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([string_Tid2 isEqual:[NSNull null]] || string_Tid2 == nil || string_Tid2.length == 0){
        
        [Utility showAlertWithString:[NSString stringWithFormat:@"%@",@"Please enter tid2 value."] andTitle:@"Alert" inViewController:self];
        return;
        
    }
    
    NSString *string_Todo = _textfield_Todo.text;
    string_Todo = [[NSString stringWithFormat:@"%@",string_Todo] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([string_Todo isEqual:[NSNull null]] || string_Todo == nil || string_Todo.length == 0){
        
        [Utility showAlertWithString:[NSString stringWithFormat:@"%@",@"Please enter todo value."] andTitle:@"Alert" inViewController:self];
        return;
        
    }
    

    NSString *string_BokadTyp = _textfield_BokadTyp.text;
    string_BokadTyp = [[NSString stringWithFormat:@"%@",string_BokadTyp] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([string_BokadTyp isEqual:[NSNull null]] || string_BokadTyp == nil || string_BokadTyp.length == 0){
        
        [Utility showAlertWithString:[NSString stringWithFormat:@"%@",@"Please enter bokadtyp value."] andTitle:@"Alert" inViewController:self];
        return;
        
    }
    
    NSString *string_Avslutad = _textfield_Avslutad.text;
    string_Avslutad = [[NSString stringWithFormat:@"%@",string_Avslutad] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([string_Avslutad isEqual:[NSNull null]] || string_Avslutad == nil || string_Avslutad.length == 0){
        
        [Utility showAlertWithString:[NSString stringWithFormat:@"%@",@"Please enter avslutad value."] andTitle:@"Alert" inViewController:self];
        return;
        
    }
    
    
    NSString *string_Edited = _textfield_Editedby.text;
    string_Edited = [[NSString stringWithFormat:@"%@",string_Edited] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([string_Edited isEqual:[NSNull null]] || string_Edited == nil || string_Edited.length == 0){
        
        [Utility showAlertWithString:[NSString stringWithFormat:@"%@",@"Please enter editedby value."] andTitle:@"Alert" inViewController:self];
        return;
        
    }
    
    [dict setValue:[NSString stringWithFormat:@"%@",string_Montor] forKey:@"montor"];
    [dict setValue:[NSString stringWithFormat:@"%@",string_Datum] forKey:@"datum"];
    [dict setValue:[NSString stringWithFormat:@"%@",string_Tid1] forKey:@"tid1"];
    [dict setValue:[NSString stringWithFormat:@"%@",string_Order] forKey:@"order"];
    [dict setValue:[NSString stringWithFormat:@"%@",string_Tid2] forKey:@"tid2"];
    [dict setValue:[NSString stringWithFormat:@"%@",string_Todo] forKey:@"todo"];
    [dict setValue:[NSString stringWithFormat:@"%@",string_BokadTyp] forKey:@"bokadtyp"];
    [dict setValue:[NSString stringWithFormat:@"%@",string_Avslutad] forKey:@"avslutad"];
    [dict setValue:[NSString stringWithFormat:@"%@",string_Edited] forKey:@"EditedBy"];
    
    NSError  *errorRowData;
    NSData   *jsonrowData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&errorRowData];
    NSString *string_SingleRowJSONRecord = [[NSString alloc] initWithData:jsonrowData encoding:NSUTF8StringEncoding];
    
    
    //Here we are inserting into UserTableRecord which is intermediate table...
    [DataBaseTask  insertIntoUserTableRecordForLocalData:kDeviceID deviceID:kDeviceID tableName:@"bokad" withRowData:string_SingleRowJSONRecord operation:@"update" primaryKeyName:@"ID" primaryKeyValue:_dict_SingleRecord[@"ID"] version:_dict_SingleRecord[@"version"] completion:^(BOOL success){
        if (success) {
            
            //When data is successfully updated, then setting delegate for previous screen to refresh data...
            if([self.dataUpdateSuccessDelegate respondsToSelector:@selector(dataUpdatedSucessfully)]){
                
                [self.dataUpdateSuccessDelegate dataUpdatedSucessfully];
                
            }
            
            [iToast showToast:[NSString stringWithFormat:@"Data successfully updated."]];
            [self.navigationController popViewControllerAnimated:NO];
            
        }}];
}
@end
