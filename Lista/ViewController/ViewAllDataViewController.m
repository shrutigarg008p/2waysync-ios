#import "Constants.h"
#import <sqlite3.h>

@interface ViewAllDataViewCell : UITableViewCell
{
    
}

@property(nonatomic,retain)id<ViewAllDataCellDelegate>viewAllDataCellDelegate;
@property (weak, nonatomic) IBOutlet UILabel *label_Montor;
@property (weak, nonatomic) IBOutlet UILabel *label_Datum;
@property (weak, nonatomic) IBOutlet UIButton *button_update;
- (IBAction)button_updateClicked:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *button_delete;
- (IBAction)button_deleteClicked:(UIButton *)sender;
@end

@implementation ViewAllDataViewCell

- (IBAction)button_updateClicked:(UIButton *)sender{
    
    if ([self.viewAllDataCellDelegate respondsToSelector:@selector(button_updateClicked:)]){
        
        [self.viewAllDataCellDelegate button_updateClicked:sender];
    }
    
}

- (IBAction)button_deleteClicked:(UIButton *)sender{
    
    if ([self.viewAllDataCellDelegate respondsToSelector:@selector(button_deleteClicked:)]){
        
        [self.viewAllDataCellDelegate button_deleteClicked:sender];
    }
    
}
@end

@implementation ViewAllDataViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    array_viewAllData = [NSMutableArray new];
    
    /*
     All calculation is done regarding fetching data from master table and UserTableRecordForLocalData table...
     */
    [self loadRefreshedDataList];
   
    /*
     Add title in center of navigationbar...
     */
    [self addNavigationControllerActivities];

}

-(void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController.navigationBar setHidden:NO];
    
}

#pragma mark ************---------Load Refresh Data----------************
-(void)loadRefreshedDataList{
 
    
    if (array_viewAllData.count>0) {
        [array_viewAllData removeAllObjects];
    }
    
    
    //Fetching total records from master table. For example here 'bokad' table is taken...
    NSArray *ary_dataOfBokadTable = [DataBaseTask selectLocalRecordForUserID:kDeviceID deviceID:kDeviceID tableName:@"bokad"];
    
    if([Utility notNull:ary_dataOfBokadTable] && ary_dataOfBokadTable.count > 0){
        
        array_viewAllData  = [ary_dataOfBokadTable mutableCopy];//Collecting data in array to show in list...
    }
    
    
    //Fetching records from UserTableRecordForLocalData with update operation only...
    NSArray *ary_updatedRecordFromUserTableRecordForLocalData = [DataBaseTask selectOnlyUpdatedRecordIntoUserTableRecordForLocalData:kDeviceID deviceID:kDeviceID tableName:@"bokad"];
    
     //Need to replace some entries in array_viewAllData, if few entries found in UserTableRecordForLocalData for update...
    if (array_viewAllData.count > 0 && ary_updatedRecordFromUserTableRecordForLocalData.count>0) {
        
        for (int i=0; i < array_viewAllData.count; i++) {
            
            NSDictionary *dict = array_viewAllData[i];
          //  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"primarykeyvalue CONTAINS [cd] %@",@"678"];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"primarykeyvalue == %@",dict[@"primarykeyvalue"]];

            NSArray *arryPredicate = [ary_updatedRecordFromUserTableRecordForLocalData filteredArrayUsingPredicate:predicate];
            if(arryPredicate.count > 0){
                
                [array_viewAllData replaceObjectAtIndex:i withObject:arryPredicate[0]];
                
            }
            
        }
        
    }
    
    //Fetching records from UserTableRecordForLocalData with insert operation only...
    NSArray *ary_insertedRecordFromUserTableRecordForLocalData = [DataBaseTask selectOnlyInsertedRecordIntoUserTableRecordForLocalData:kDeviceID deviceID:kDeviceID tableName:@"bokad"];
    
    //Finally adding records from UserTableRecordForLocalData with insert operation only...
    if([Utility notNull:ary_dataOfBokadTable] && ary_insertedRecordFromUserTableRecordForLocalData.count > 0){
        
        [array_viewAllData addObjectsFromArray:ary_insertedRecordFromUserTableRecordForLocalData];
    }
    
    
    //Using NSSortDescriptor data display list can be ordered(ASCENDING/DESCENDING) accroding to requirement...
    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"datum" ascending:NO];
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"montor" ascending:YES];
    NSArray *sortDescriptors = @[dateDescriptor,nameDescriptor];
    
   
    array_viewAllData = [[array_viewAllData sortedArrayUsingDescriptors:sortDescriptors]mutableCopy];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{

        [self->_tableView_viewAllData reloadData];

    });
    
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

#pragma mark ************---------UITableView DataSource----------************
-(void)viewDidLayoutSubviews
{
    if ([_tableView_viewAllData respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView_viewAllData setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([_tableView_viewAllData respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView_viewAllData setLayoutMargins:UIEdgeInsetsZero];
    }
    
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return array_viewAllData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"viewAllDataViewCell";
    ViewAllDataViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.viewAllDataCellDelegate = self;
    NSDictionary *dict = array_viewAllData[indexPath.row];
    cell.label_Montor.text = [NSString stringWithFormat:@"%@",dict[@"montor"]];
    cell.label_Datum.text = [NSString stringWithFormat:@"%@",dict[@"datum"]];
    cell.button_update.layer.actions = dict;
    cell.button_update.accessibilityLabel = [NSString stringWithFormat:@"%ld",indexPath.row];
   
    cell.button_delete.layer.actions = dict;
    cell.button_delete.accessibilityLabel = [NSString stringWithFormat:@"%ld",indexPath.row];

    return cell;
    
}

#pragma mark ************---------Update Button Click----------************
- (void)button_updateClicked:(UIButton *)sender{
    
    NSDictionary *dict_SingleRecord = sender.layer.actions;
    if (![dict_SingleRecord isEqual:[NSNull null]] && dict_SingleRecord != nil) {
        
    UpdateViewController *updateVCObj = [self.storyboard instantiateViewControllerWithIdentifier:@"updateViewController"];
    updateVCObj.dict_SingleRecord = dict_SingleRecord;
    updateVCObj.dataUpdateSuccessDelegate = self;
    [self.navigationController pushViewController:updateVCObj animated:NO];
        
    }
}

#pragma mark ************---------Delete Button Click----------************
- (void)button_deleteClicked:(UIButton *)sender{
    
    
    NSDictionary *dict_SingleRecord = sender.layer.actions;
    if (![dict_SingleRecord isEqual:[NSNull null]] && dict_SingleRecord != nil) {
        
        //Checking that entry is from master table or intermediate table...
        if([dict_SingleRecord[@"isDataFromUserTableRecordForLocalData"] isEqualToString:@"yes"]){
            
            if ([dict_SingleRecord[@"primarykeyname"] isEqualToString:@""]) {//It means operation name is insert...
                
                //If data already exists in UserTableRecordForLocalData, we have to directly delete entry from this...
                [DataBaseTask deleteRecordFromUserTableRecordForLocalData:kDeviceID deviceID:kDeviceID tableName:@"bokad" primaryKeyName:@"ID" primaryKeyValue:[NSString stringWithFormat:@"%@",dict_SingleRecord[@"ID"]]];
                
            }else{
                
                //Record will be directally deleted from master table...
                [DataBaseTask  deleteRecordFromTable:kDeviceID deviceID:kDeviceID tableName:@"bokad" primaryKeyName:[NSString stringWithFormat:@"%@",dict_SingleRecord[@"primarykeyname"]] primaryKeyValue:[NSString stringWithFormat:@"%@",dict_SingleRecord[@"primarykeyvalue"]]];
                
                
                //Also need to delete record from intermediate table, because any user made update operation first and then deleting...
                [DataBaseTask  deleteRecordFromUserTableRecordForLocalData:kDeviceID deviceID:kDeviceID tableName:@"bokad" primaryKeyName:@"ID" primaryKeyValue:[NSString stringWithFormat:@"%@",dict_SingleRecord[@"ID"]]];
                
                
                //Here we are inserting into UserTableRecordForLocalData which is intermediate table...
                [DataBaseTask  insertIntoUserTableRecordForLocalData:kDeviceID deviceID:kDeviceID tableName:@"bokad" withRowData:@"" operation:@"delete" primaryKeyName:[NSString stringWithFormat:@"%@",dict_SingleRecord[@"primarykeyname"]] primaryKeyValue:[NSString stringWithFormat:@"%@",dict_SingleRecord[@"primarykeyvalue"]] version:@"" completion:^(BOOL success){
                    
                }];
                
                
            }
            
            //Delete record from array and UITable also...
            if([sender.accessibilityLabel integerValue] < array_viewAllData.count){
                
                [array_viewAllData removeObjectAtIndex:[sender.accessibilityLabel integerValue]];
                [_tableView_viewAllData reloadData];
            }
            
        }else{
            
            /*
             Record is not exists in UserTableRecordForLocalData, it means this entry is from master table and we have to insert as new record for sync...
             */
            
            //Also need to delete record from intermediate table, because any user made update operation first and then deleting...
            [DataBaseTask  deleteRecordFromTable:kDeviceID deviceID:kDeviceID tableName:@"bokad" primaryKeyName:[NSString stringWithFormat:@"%@",dict_SingleRecord[@"primarykeyname"]] primaryKeyValue:[NSString stringWithFormat:@"%@",dict_SingleRecord[@"primarykeyvalue"]]];
            
            
            //Here we are inserting into UserTableRecordForLocalData which is intermediate table...
            [DataBaseTask  insertIntoUserTableRecordForLocalData:kDeviceID deviceID:kDeviceID tableName:@"bokad" withRowData:@"" operation:@"delete" primaryKeyName:[NSString stringWithFormat:@"%@",dict_SingleRecord[@"primarykeyname"]] primaryKeyValue:[NSString stringWithFormat:@"%@",dict_SingleRecord[@"primarykeyvalue"]] version:@"" completion:^(BOOL success){
                if (success) {
                    
                    //Delete record from array and UITable also...
                    if([sender.accessibilityLabel integerValue] < self->array_viewAllData.count){
                        
                        [self->array_viewAllData removeObjectAtIndex:[sender.accessibilityLabel integerValue]];
                        [self->_tableView_viewAllData reloadData];
                    }
                    
                }}];
        }
        
    }
}

#pragma mark ************---------Data Update Success Delegate----------************
//If data from form updated suucessfully then this delegate will call to refresh the list...
-(void)dataUpdatedSucessfully{
 
    [self loadRefreshedDataList];
}

@end
