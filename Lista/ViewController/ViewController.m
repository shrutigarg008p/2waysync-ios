#import "Constants.h"
#import <sqlite3.h>

@interface DatabaseTableListCell : UITableViewCell
{
    
    
}
@property (weak, nonatomic) IBOutlet UILabel *labelName;

@end

@implementation DatabaseTableListCell

@end


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    array_databaseTableList = [NSMutableArray new]; //to store table records...
    array_Record = [NSMutableArray new];  //to store all table related configuration
    
   //check blank database created or not.
   NSString *str_isBlankDataBaseCretedForUser = [[NSUserDefaults standardUserDefaults]valueForKey:@"isBlankDataBaseCreatedForUser"];
    if(![Utility notNull:str_isBlankDataBaseCretedForUser]){

        //When user is first time login, creating blank database...
        [self getAllDatabaseTableConfiguration];
    }
 
   if([str_isBlankDataBaseCretedForUser isEqualToString:@"yes"]){
       
      
       //Fetch all table's names...
      NSArray *array_tableNames = [DataBaseTask selectAllTableNameFromDataBase];
       if([Utility notNull:array_tableNames] && array_tableNames.count>0){
        
           array_databaseTableList =  [array_tableNames mutableCopy];
           [_tableView_databaseTableList reloadData];
           
       }
    }
    
    
    //AFNetworkReachability used for checking continuous network connectivity with device.
    [self setAFNetworkReachabilityManager];
    
    
    //Timer is calling every 300 seconds to check any table structure is modified or not. This is not fixed interval, user can change to this inverval to check modification in table columns in server side...
    [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(checkInWhichTableColumnsAreModifiedAPICall) userInfo:nil repeats:YES];
    

    //Timer is calling every 20 seconds to check 'UserTableRecordForLocalData' table data, because this is intermediate table where we keep record first for any(insert,update,delete) operation. Suppose if any records exists in this table, then we send data to server.
    [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(checkUserTableRecordForLocalData) userInfo:nil repeats:YES];
    
    
    //Timer is calling every 17 seconds to check any update in server master database.
    [NSTimer scheduledTimerWithTimeInterval:17.0 target:self selector:@selector(syncUpdatedDataFromServerToLocalAPICalled) userInfo:nil repeats:YES];

}
-(void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController.navigationBar setHidden:YES];

}

-(void)setAFNetworkReachabilityManager{
    
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            
            [iToast showToast:@"Your network connetion is not available."];
            
        }
        
        if([AFNetworkReachabilityManager sharedManager].isReachable){
            
            [self  checkDatabaseWhichTableDataIsNotSynced]; //If network connection is available, then check for which table all data is synced or not with page number.
        }
        
    }];
    
}
-(void)checkDatabaseWhichTableDataIsNotSynced{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{//Completing task in background...
        
    if(![AFNetworkReachabilityManager sharedManager].isReachable)
        return;
    
    //Checking how much data is synced with page number...
    NSArray *ary_Record = [DataBaseTask selectTableNameWithPageNumberForUserID:kDeviceID deviceID:kDeviceID];
    if([Utility notNull:ary_Record] && ary_Record.count > 0){
        
        NSString *str_TableName = ary_Record[0];
        NSString *str_PageNumber = ary_Record[1];
        int int_NextPageNumber = [str_PageNumber intValue] + 1; //Here we have to fetch next page data which is already stored in table...
        [self getTableRecordAPICalledForTable:str_TableName userID:kDeviceID deviceID:kDeviceID WithPageNumber:int_NextPageNumber];
        
    }
        
    });
}

#pragma mark ************---------NSTimer Calling----------************
/*
 Cheking in every 300 seconds that which table columns are modified on server side...
 */
-(void)checkInWhichTableColumnsAreModifiedAPICall{
  
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{//Completing task in background...
        
     /*
     API Parameters used.
     database --> name of database.
     dbuser --> database username
     dbpass --> databasepassword
     server --> used server name
     device_id -->[[[[UIDevice currentDevice]identifierForVendor] UUIDString]stringByReplacingOccurrencesOfString:@"-" withString:@""]
     user_id --> here device id is user id(need to replace in real code implemetation)
     */
    
    NSMutableDictionary *dict_Parameters = [NSMutableDictionary new];
    [dict_Parameters setObject:[NSString stringWithFormat:@"%@",kDatabase] forKey:@"databas"];
    [dict_Parameters setObject:[NSString stringWithFormat:@"%@",kDBUser] forKey:@"dbuser"];
    [dict_Parameters setObject:[NSString stringWithFormat:@"%@",kDBPass] forKey:@"dbpass"];
    [dict_Parameters setObject:[NSString stringWithFormat:@"%@",kServer] forKey:@"server"];
    if([kDeviceID isEqualToString:@""]){
        
        [dict_Parameters setObject:[NSString stringWithFormat:@"ListaTest"] forKey:@"device_id"];
        [dict_Parameters setObject:[NSString stringWithFormat:@"ListaTest"] forKey:@"user_id"];
        
    }else{
        
        [dict_Parameters setObject:[NSString stringWithFormat:@"%@",kDeviceID] forKey:@"device_id"];
        [dict_Parameters setObject:[NSString stringWithFormat:@"%@",kDeviceID] forKey:@"user_id"];
        
    }
    
    [[APIManager sharedAPIManager]checkInWhichTableColumnsAreModified:^(id object) {
        
        if (![object isEqual:[NSNull null]] && object != nil) {
            
            if (![object[@"status"] isEqual:[NSNull null]] && object[@"status"] != nil && [object[@"status"]boolValue] && ![object[@"data"] isEqual:[NSNull null]] && object[@"data"] != nil) {
                
                NSArray *array_Record = [object[@"data"]mutableCopy];
                if (![array_Record isEqual:[NSNull null]] && array_Record != nil && array_Record.count > 0){
                    
                    for(int i = 0; i < array_Record.count; i++) {
                        
                        BOOL isDropTableSuccess = [DataBaseTask dropFromLocalDatabaseOldTable:[NSString stringWithFormat:@"%@",array_Record[i][@"table"]]];//Drop already existing table, because now the structure of that table has been modified.
                        
                        if(isDropTableSuccess){
                            
                            [DataBaseTask createBlankTableinLocalDatabase:array_Record[i][@"table"] tableColumns:array_Record[i][@"column"]];//CreateBlankTableinLocalDatabase into bokatoklart5.sqlite file...
                            
                            
                        }
                        
                    }
                    
                }
            }
            
        }
        
    } onError:^(NSError *error) {
        
        [iToast showToast:[NSString stringWithFormat:@"%@",error.localizedDescription]];
        
    }params:dict_Parameters];
        
        
    });
    
}
/*
 Cheking in every 20 seconds that which data is not sent from device to server...
 */
-(void)checkUserTableRecordForLocalData{
    

    if(![AFNetworkReachabilityManager sharedManager].isReachable)
        return;
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{//Completing task in background...

    //Fetch records from 'UserTableRecordForLocalData' table, which exists in this table, it means this data should be sent to the server.
    NSArray *ary_singleRowRecord = [DataBaseTask selectSingleLocalRecordToSendserverForUserID:kDeviceID deviceID:kDeviceID];
    
    if([Utility notNull:ary_singleRowRecord] && ary_singleRowRecord.count > 0){
        
        NSString *str_LocalDataBasePrimaryKeyId = ary_singleRowRecord[0];
        NSString *str_UserId = ary_singleRowRecord[1];
        NSString *str_DeviceId = ary_singleRowRecord[2];
        NSString *str_tableName = ary_singleRowRecord[3];
        NSString *str_rowJSONData = ary_singleRowRecord[4];
        NSString *str_operationName = ary_singleRowRecord[5];
        NSString *primarykeyname = ary_singleRowRecord[6];
        NSString *primarykeyvalue = ary_singleRowRecord[7];
        NSString *str_rowVersion = ary_singleRowRecord[8];
        
        
        //Now send data from intermediate table to server...
        [self sendLocalDataToServerAPICall:str_LocalDataBasePrimaryKeyId userID:str_UserId deviceID:str_DeviceId str_tableName:str_tableName singleRecord:str_rowJSONData operationName:str_operationName primaryKeyName:primarykeyname primaryKeyValue:primarykeyvalue  rowVersion:str_rowVersion];
        
    }
    
        
    });
}
/*
 Cheking in every 17 seconds updated records from server to localdatabase...
 */
-(void)syncUpdatedDataFromServerToLocalAPICalled{
    
    
    /*
     API Parameters used.
     database --> name of database.
     dbuser --> database username
     dbpass --> databasepassword
     server --> used server name
     device_id -->[[[[UIDevice currentDevice]identifierForVendor] UUIDString]stringByReplacingOccurrencesOfString:@"-" withString:@""]
     user_id --> here device id is user id(need to replace in real code implemetation)
     */
    
    NSMutableDictionary *dict_Parameters = [NSMutableDictionary new];
    
    NSString *serviceUrl = [NSString stringWithFormat:@"%@Posts/syncUpdatedData.php?databas=%@&dbuser=%@&dbpass=%@&server=%@&user_id=%@&device_id=%@",kBaseURL,kDatabase,kDBUser,kDBPass,kServer,kDeviceID,kDeviceID];
    
    [[APIManager sharedAPIManager]syncUpdateDataFromServerToLocalAPICall:^(id object) {
      
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{//Completing task in background...

        if (![object isEqual:[NSNull null]] && object != nil) {
            
            if (![object[@"status"] isEqual:[NSNull null]] && object[@"status"] != nil && [object[@"status"]boolValue] && ![object[@"tableData"] isEqual:[NSNull null]] && object[@"tableData"] != nil) {
                
                NSArray *array_dataToBeSynced = object[@"tableData"];//In array depending upon all three operatons(insert,update,delete) data will come to sync from server to local database....
                
                for (int i = 0; i < array_dataToBeSynced.count; i++) {
                    
                    NSDictionary *dict_SingleRecord = array_dataToBeSynced[i];
                    if (![dict_SingleRecord isEqual:[NSNull null]] && dict_SingleRecord != nil){
                        
                        NSString *str_Operation = dict_SingleRecord[@"operation"];
                        if([str_Operation isEqualToString:@"insert"]) {//Insert operation performed here...
                            
                            NSError *jsonError;
                            NSData *objectData = [dict_SingleRecord[@"rowdata"] dataUsingEncoding:NSUTF8StringEncoding];
                            NSDictionary *dict_rowData = [NSJSONSerialization JSONObjectWithData:objectData
                                                                                         options:NSJSONReadingMutableContainers
                                                                                           error:&jsonError];
                            [dict_rowData setValue:[NSString stringWithFormat:@"%@",dict_SingleRecord[@"primarykeyvalue"]] forKey:[NSString stringWithFormat:@"%@",dict_SingleRecord[@"primarykeyname"]]];//Set primary key to make similar row as server table contains...
                            
                            //Insert data into local database after API success...
                            BOOL   success =  [DataBaseTask insertNewDataInToLocalDatabase:[NSArray arrayWithObject:dict_rowData] TableName:dict_SingleRecord[@"table_name"]];
                            
                            if(success){
                                NSLog(@"insert into %@ table success.",dict_SingleRecord[@"table_name"]);
                                
                            }
                            
                        }else if([str_Operation isEqualToString:@"update"]){//Update operation performed here...
                            
                            NSError *jsonError;
                            NSDictionary *dict_rowData = [NSJSONSerialization JSONObjectWithData:[dict_SingleRecord[@"rowdata"] dataUsingEncoding:NSUTF8StringEncoding]options:NSJSONReadingMutableContainers error:&jsonError];
                            
                            
                            NSInteger int_increamentedRowVersion = [dict_SingleRecord[@"version"] integerValue];
                            
                            //Need to update record according to the table record as exists in server table.
                            [DataBaseTask updateTableDataFromServerWithVersion:[NSArray arrayWithObject:dict_rowData] TableName:dict_SingleRecord[@"table_name"] primaryKeyName:dict_SingleRecord[@"primarykeyname"] primaryKeyValue:dict_SingleRecord[@"primarykeyvalue"] version:[NSString stringWithFormat:@"%ld",(long)int_increamentedRowVersion] completion:^(BOOL success){
                                if(success){
                                    NSLog(@"server data updated into %@ table success.",dict_SingleRecord[@"table_name"]);
                                }}];
                            
                            //Delete record also from intermediate table...
                            [DataBaseTask deleteRecordFromUserTableRecordForLocalData:kDeviceID deviceID:kDeviceID tableName:dict_SingleRecord[@"table_name"] primaryKeyName:@"primarykeyvalue" primaryKeyValue:[NSString stringWithFormat:@"%@",dict_SingleRecord[@"primarykeyvalue"]]];
                            
                            
                        }else{//Delete operation performed here...
                            
                            BOOL isDeleteTableDataSuccess =  [DataBaseTask deleteRecordFromTable:kDeviceID deviceID:kDeviceID tableName:dict_SingleRecord[@"table_name"] primaryKeyName:[NSString stringWithFormat:@"%@",dict_SingleRecord[@"primarykeyname"]] primaryKeyValue:[NSString stringWithFormat:@"%@",dict_SingleRecord[@"primarykeyvalue"]]];
                            
                            if(isDeleteTableDataSuccess){
                                NSLog(@"delete from %@ table success.",dict_SingleRecord[@"table_name"]);
                            }
                            
                            
                            //Delete record also from intermediate table...
                            [DataBaseTask deleteRecordFromUserTableRecordForLocalData:kDeviceID deviceID:kDeviceID tableName:dict_SingleRecord[@"table_name"] primaryKeyName:@"primarykeyvalue" primaryKeyValue:[NSString stringWithFormat:@"%@",dict_SingleRecord[@"primarykeyvalue"]]];
                            
                            
                        }
                        
                    }
                }
            }
            
        }
            
        });
        
    } serviceUrl:serviceUrl onError:^(NSError *error) {
        
        //  [iToast showToast:[NSString stringWithFormat:@"%@",error.localizedDescription]];
        
    }params:dict_Parameters];
    
    
}

#pragma mark ************---------API Calling----------************
-(void)getAllDatabaseTableConfiguration{
    
    [apDelegate() showProgressHUDWithText:@"Creating database..." inView:self.view];
    
    /*
     API Parameters used.
     database --> name of database
     dbuser --> database username
     dbpass --> databasepassword
     server --> used server name
     device_id -->[[[[UIDevice currentDevice]identifierForVendor] UUIDString]stringByReplacingOccurrencesOfString:@"-" withString:@""]
     user_id --> here device id is user id(need to replace in real code implemetation)
     */
    
    NSMutableDictionary *dict_Parameters = [NSMutableDictionary new];
    [dict_Parameters setObject:[NSString stringWithFormat:@"%@",kDatabase] forKey:@"databas"];
    [dict_Parameters setObject:[NSString stringWithFormat:@"%@",kDBUser] forKey:@"dbuser"];
    [dict_Parameters setObject:[NSString stringWithFormat:@"%@",kDBPass] forKey:@"dbpass"];
    [dict_Parameters setObject:[NSString stringWithFormat:@"%@",kServer] forKey:@"server"];
    if([kDeviceID isEqualToString:@""]){
        
        [dict_Parameters setObject:[NSString stringWithFormat:@"ListaTest"] forKey:@"device_id"];
        [dict_Parameters setObject:[NSString stringWithFormat:@"ListaTest"] forKey:@"user_id"];

    }else{
        
        [dict_Parameters setObject:[NSString stringWithFormat:@"%@",kDeviceID] forKey:@"device_id"];
        [dict_Parameters setObject:[NSString stringWithFormat:@"%@",kDeviceID] forKey:@"user_id"];

    }

    [[APIManager sharedAPIManager]getAllDatabaseTableConfiguration:^(id object) {
        
        [apDelegate() hideProgressHUD];
        

        if (![object isEqual:[NSNull null]] && object != nil) {
            
            if (![object[@"status"] isEqual:[NSNull null]] && object[@"status"] != nil && [object[@"status"]boolValue] && ![object[@"data"] isEqual:[NSNull null]] && object[@"data"] != nil) {
                
               NSArray *array_Record = [object[@"data"]mutableCopy];
                if (![array_Record isEqual:[NSNull null]] && array_Record != nil && array_Record.count > 0){
                    
                    self->array_databaseTableList = [array_Record mutableCopy];
                    [self->_tableView_databaseTableList reloadData];
                
                    [self createBlankTableinLocalDatabase:self->array_databaseTableList];//CreateBlankTableinLocalDatabase into bokatoklart5.sqlite file...
                    
                }
            }
            
        }
    } onError:^(NSError *error) {
        
        [iToast showToast:[NSString stringWithFormat:@"%@",error.localizedDescription]];
        [apDelegate() hideProgressHUD];
        
    }params:dict_Parameters];
    
    
}
/*
 CreateBlankTableinLocalDatabase into bokatoklart5.sqlite file...
*/
-(void)createBlankTableinLocalDatabase:(NSArray *)arrayTableRecord{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{//Completing task in background...

    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    sqlite3 *database;
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        for (int i = 0; i < arrayTableRecord.count; i++) {
            
            NSMutableString *sqlStatement = [[NSMutableString alloc]initWithString:@"CREATE TABLE IF NOT EXISTS "];

            NSString *strTablename = @"";
            strTablename = arrayTableRecord[i][@"table"];
            [sqlStatement appendString:[NSString stringWithFormat:@"[%@] ",strTablename]];
            
           NSArray *array_totalColums = arrayTableRecord[i][@"column"];
            
            if([Utility notNull:array_totalColums] && array_totalColums.count>0){
                
                for (int j = 0; j < array_totalColums.count; j++) {

                    NSDictionary *dic = array_totalColums[j];

                    NSString *strField = @"";
                    strField = dic[@"Field"];
                    
                    NSString *strType = @"";
                    strType = dic[@"Type"];
                    
                    NSString *strDefault = @"";
                    strDefault = dic[@"Default"];
                    
                    NSString *strExtra = @"";
                    strExtra = dic[@"Extra"];
                    
                    NSString *strKey = @"";
                    strKey = dic[@"Key"];
                    if([strKey isEqualToString:@"PRI"])
                    strKey = @"INTEGER PRIMARY KEY AUTOINCREMENT";
                    
                    NSString *strNull = @"";
                    strNull = dic[@"Null"];
                    
                    
                    if (j==0) {
                        
                        if([strKey isEqualToString:@"INTEGER PRIMARY KEY AUTOINCREMENT"]){
                        [sqlStatement appendString:[NSString stringWithFormat:@"( [%@] %@",strField,strKey]];
                        }else{
                        [sqlStatement appendString:[NSString stringWithFormat:@"( [%@] %@",strField,strType]];
                        }
                        
                    }else if([strKey isEqualToString:@"INTEGER PRIMARY KEY AUTOINCREMENT"]){
                        
                        [sqlStatement appendString:[NSString stringWithFormat:@", [%@] %@",strField,strKey]];

                    }else{
                        
                        [sqlStatement appendString:[NSString stringWithFormat:@", [%@] %@",strField,strType]];

                    }

                    if (j==array_totalColums.count - 1) {
                        
                        [sqlStatement appendString:[NSString stringWithFormat:@")"]];

                    }
                
            }
                
            }
            

        char *errMsg;
        if (sqlite3_exec(database, [sqlStatement UTF8String], NULL, NULL, &errMsg) == SQLITE_OK){
            NSLog(@"Table creation success.");  } } }
    
    sqlite3_close(database);
    
    
    //Make an another table to keep tha track for tables record from server to device...
    [DataBaseTask insertTableNameForUserObservedFromServer:kDeviceID deviceID:kDeviceID withTables:arrayTableRecord completion:^(BOOL success){
        
        if (success) {
            
            [[NSUserDefaults standardUserDefaults]setValue:@"yes" forKey:@"isBlankDataBaseCreatedForUser"];
            
            [self checkDatabaseWhichTableDataIsNotSynced]; //Checking for which table all data is not synced...
            
        }
        
    }];
    
    });
}
/*
 getTableRecordAPICalledForTable to perform operations(Insertion,Updation,Deletion)...
 */
-(void)getTableRecordAPICalledForTable:(NSString *)str_tableName userID:(NSString *)userID deviceID:(NSString *)device_id WithPageNumber:(int )int_NextPageNumber{
    
    
    if(int_NextPageNumber >= 11 && [str_tableName isEqualToString:@"A_Material"]){
        
        //Don't show toast here, now data is fetching in background...
        //[apDelegate() hideProgressHUD];
        
    }else{
        
        [iToast showToast:[NSString stringWithFormat:@"Fetching %@ data",str_tableName]];
        //[apDelegate() showProgressHUDWithText:[NSString stringWithFormat:@"Fetching %@ data",str_tableName] inView:self.view];
    }
    
    /*
     API Parameters used.
     database --> name of database.
     dbuser --> database username
     dbpass --> databasepassword
     server --> used server name
     table --> table name, from which data is fetched.
     paged --> used on which page number data will be fetch.
     device_id -->[[[[UIDevice currentDevice]identifierForVendor] UUIDString]stringByReplacingOccurrencesOfString:@"-" withString:@""]
     */
    
    NSMutableDictionary *dict_Parameters = [NSMutableDictionary new];
    [dict_Parameters setObject:[NSString stringWithFormat:@"%@",kDatabase] forKey:@"databas"];
    [dict_Parameters setObject:[NSString stringWithFormat:@"%@",kDBUser] forKey:@"dbuser"];
    [dict_Parameters setObject:[NSString stringWithFormat:@"%@",kDBPass] forKey:@"dbpass"];
    [dict_Parameters setObject:[NSString stringWithFormat:@"%@",kServer] forKey:@"server"];
    [dict_Parameters setObject:[NSString stringWithFormat:@"%@",str_tableName] forKey:@"table"];
    [dict_Parameters setObject:[NSString stringWithFormat:@"%d",int_NextPageNumber] forKey:@"paged"];
    if([kDeviceID isEqualToString:@""]){
        [dict_Parameters setObject:[NSString stringWithFormat:@"ListaTest"] forKey:@"device_id"];
    }else{
        [dict_Parameters setObject:[NSString stringWithFormat:@"%@",kDeviceID] forKey:@"device_id"];
    }

    [[APIManager sharedAPIManager]getDataFromServerForTableName:^(id object) {
       
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{//Completing task in background...
            
        if (![object isEqual:[NSNull null]] && object != nil) {
            
            if (![object[@"status"] isEqual:[NSNull null]] && object[@"status"] != nil && [object[@"status"]boolValue] && ![object[@"data"] isEqual:[NSNull null]] && object[@"data"] != nil) {
                
               NSArray *aryRecord = [object[@"data"]mutableCopy];
                if (![aryRecord isEqual:[NSNull null]] && aryRecord != nil && aryRecord.count > 0){
    
                    
                    //Insert data into local database after API success which get 500-500 chunks of record from single API call.
                    BOOL success =  [DataBaseTask insertNewDataInToLocalDatabase:aryRecord TableName:str_tableName];
                        
                    if(success){
                        
                        NSLog(@"%@",[NSString stringWithFormat:@"Data inserted into %@ successfully.",str_tableName]);

                    //Update into UserTableRecordForSyncData table, how much data has been synced from server to device.
                      BOOL success_update =   [DataBaseTask updateDataSuccessfullWriteInLocalDatabaseForUserID:userID tableName:str_tableName pageNumber:[NSString stringWithFormat:@"%d",int_NextPageNumber] deviceID:[NSString stringWithFormat:@"%@",device_id]];
                          if(success_update){
                              
                              if(int_NextPageNumber == 10 && [str_tableName isEqualToString:@"A_Material"]){
                                  
                                  //No record found at this page...
                                  [DataBaseTask updateDataSuccessfullSyncedAllDataInLocalDatabaseForUserID:userID tableName:[NSString stringWithFormat:@"%@",str_tableName] deviceID:[NSString stringWithFormat:@"%@",device_id] yesOrNo:@"yes" completion:^(BOOL success){
                                      if(success){
                                          
                                          //Checking for which table all data is not synced...
                                          [self checkDatabaseWhichTableDataIsNotSynced];

                                      }
                                      
                                  }];

                              }else{
                                  
                                  //Checking for which table all data is not synced.
                                [self checkDatabaseWhichTableDataIsNotSynced];
                                  
                              }
                              
                          }


                    }
                    
                    
                }else{
                    
                    [iToast showToast:[NSString stringWithFormat:@"No data found."]];

                }
                
            }else{
                
                //No record found at this page, then update all data from particular is synced.
                [DataBaseTask updateDataSuccessfullSyncedAllDataInLocalDatabaseForUserID:userID tableName:[NSString stringWithFormat:@"%@",str_tableName] deviceID:[NSString stringWithFormat:@"%@",device_id] yesOrNo:@"yes" completion:^(BOOL success){
                    
                    if(success){
                        
                        if([str_tableName isEqualToString:@"reselist"]){
                            
                            //After all tables syncing re-enable flag for 'A_material' to take next remaining records...
                            [DataBaseTask updateDataSuccessfullSyncedAllDataInLocalDatabaseForUserID:userID tableName:[NSString stringWithFormat:@"%@",@"A_Material"] deviceID:[NSString stringWithFormat:@"%@",device_id] yesOrNo:@"no" completion:^(BOOL success){
                                if(success){
                                    
                                    //Checking for which table all data is not synced...
                                    [self checkDatabaseWhichTableDataIsNotSynced];

                                }
                                
                            }];
                            
                        }else{
                            
                            //Checking for which table all data is not synced.
                            [self checkDatabaseWhichTableDataIsNotSynced];

                        }
                        
                    }
                    
                }];
                
            }
        }
        
        });
        
    }onError:^(NSError *error) {
        
        [iToast showToast:[NSString stringWithFormat:@"%@",error.localizedDescription]];
        [apDelegate() hideProgressHUD];
        
    }params:dict_Parameters];
    
}

/*
 InsertDataIntoUserTableRecordForLocalData_InsertOperation to perform insert operation...
 */
-(void)insertDataIntoUserTableRecordForLocalData_InsertOperation:(NSString *)userID deviceID:(NSString *)deviceID{
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{//Completing task in background...
        
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setValue:[NSString stringWithFormat:@"testios"] forKey:@"montor"];
    //Current Date and Time...
    NSDateFormatter *dateFormatter0 = [[NSDateFormatter alloc] init];
    [dateFormatter0 setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter0 setDateFormat:@"yyyy-MM-dd"];
    NSString *stringCurrentDate = [dateFormatter0 stringFromDate:[NSDate date]];
    [dict setValue:[NSString stringWithFormat:@"%@",stringCurrentDate] forKey:@"datum"];
    [dict setValue:[NSString stringWithFormat:@"%@",@"0"] forKey:@"tid1"];
    [dict setValue:[NSString stringWithFormat:@"%@",@"0"] forKey:@"order"];
    [dict setValue:[NSString stringWithFormat:@"%@",@"00:00-00:00"] forKey:@"tid2"];
    [dict setValue:[NSString stringWithFormat:@"%@",@"torrthrtdo0"] forKey:@"todo"];
    [dict setValue:[NSString stringWithFormat:@"%@",@"0"] forKey:@"bokadtyp"];
    [dict setValue:[NSString stringWithFormat:@"%@",@"0"] forKey:@"avslutad"];
    [dict setValue:[NSString stringWithFormat:@"%@",@"EditedBy0"] forKey:@"EditedBy"];
    [dict setValue:[NSString stringWithFormat:@"%@",@"0"] forKey:@"version"];
    
    NSError  *errorRowData;
    NSData   *jsonrowData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&errorRowData];
    NSString *string_SingleRowJSONRecord = [[NSString alloc] initWithData:jsonrowData encoding:NSUTF8StringEncoding];
    
    
    //Here we are inserting into UserTableRecord which is intermediate table...
    [DataBaseTask  insertIntoUserTableRecordForLocalData:userID deviceID:deviceID tableName:@"bokad" withRowData:string_SingleRowJSONRecord operation:@"insert" primaryKeyName:@"" primaryKeyValue:@"" version:@"0" completion:^(BOOL success){
        if (success) {
            
            
        }}];
        
    });
    
    
}
-(void)sendLocalDataToServerAPICall:str_LocalDataBasePrimaryKeyId userID:(NSString *)userId deviceID:(NSString *)deviceID str_tableName:(NSString *)str_tableName singleRecord:(NSString *)str_rowRecord operationName:(NSString *)str_operationName primaryKeyName:(NSString *)primarykeyname primaryKeyValue:(NSString *)primarykeyvalue  rowVersion:(NSString *)str_rowVersion{
    
    /*
     API Parameters used.
     database --> name of database.
     dbuser --> database username.
     dbpass --> databasepassword.
     server --> used server name.
     device_id -->[[[[UIDevice currentDevice]identifierForVendor] UUIDString]stringByReplacingOccurrencesOfString:@"-" withString:@""].
     user_id --> here device id is user id(need to replace in real code implemetation).
     table --> in which data will be inserted.
     tableData --> single row record in json format.
     version --> this only will be needed in update operation. If version value is greater than or equal to current version string available in table in server side, then this change will acceptable otherwise discard.
     primarykeyname --> primary key name(i.e. ID,id,iD)
     primarykeyvalue --> value of primary key(i.e 1,2,3,4,5...).
     */
    
    NSMutableDictionary *dict_Parameters = [NSMutableDictionary new];
    [dict_Parameters setObject:[NSString stringWithFormat:@"%@",str_operationName] forKey:@"operation"];
    
    if([str_operationName isEqualToString:@"insert"]){
        
        [dict_Parameters setObject:[NSString stringWithFormat:@"%@",str_rowRecord] forKey:@"tableData"];

    }else if([str_operationName isEqualToString:@"update"]){
        
        [dict_Parameters setObject:[NSString stringWithFormat:@"%@",primarykeyname] forKey:@"primarykeyname"];
        [dict_Parameters setObject:[NSString stringWithFormat:@"%@",primarykeyvalue] forKey:@"primarykeyvalue"];
        [dict_Parameters setObject:[NSString stringWithFormat:@"%@",str_rowRecord] forKey:@"tableData"];
        [dict_Parameters setObject:[NSString stringWithFormat:@"%@",str_rowVersion] forKey:@"version"];

    }else{
        
        [dict_Parameters setObject:[NSString stringWithFormat:@"%@",primarykeyname] forKey:@"primarykeyname"];
        [dict_Parameters setObject:[NSString stringWithFormat:@"%@",primarykeyvalue] forKey:@"primarykeyvalue"];

    }
    
    NSLog(@"%@",dict_Parameters);
    
      NSString *serviceUrl = [NSString stringWithFormat:@"%@Posts/operationTableData.php?databas=%@&dbuser=%@&dbpass=%@&server=%@&table=%@&user_id=%@&device_id=%@",kBaseURL,kDatabase,kDBUser,kDBPass,kServer,str_tableName,kDeviceID,kDeviceID];
   
    [[APIManager sharedAPIManager]sendLocalDataToServerAPICall:^(id object) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{//Completing task in background...
            
        NSLog(@"%@",object);
        if (![object isEqual:[NSNull null]] && object != nil) {
            
            if (![object[@"data"] isEqual:[NSNull null]] && object[@"data"] != nil && ![object[@"status"] isEqual:[NSNull null]] && object[@"status"] != nil && [object[@"status"]integerValue] == 1) {//When record is successfull operation is performed...
                
                if([str_operationName isEqualToString:@"insert"]){//Insert operation performed here...

                    NSError *jsonError;
                    NSData *objectData = [str_rowRecord dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *dict_rowData = [NSJSONSerialization JSONObjectWithData:objectData
                                                                                 options:NSJSONReadingMutableContainers
                                                                                   error:&jsonError];
                    [dict_rowData setValue:[NSString stringWithFormat:@"%@",object[@"primarykeyvalue"]] forKey:[NSString stringWithFormat:@"%@",object[@"primarykeyname"]]];//Set primary key to make similar row as server table contains...

                    //Insert data into local database after API success...
                   BOOL success = [DataBaseTask insertNewDataInToLocalDatabase:[NSArray arrayWithObject:dict_rowData] TableName:str_tableName];
                    
                        if(success){
                            
                            NSLog(@"insert into %@ table success.",str_tableName);
                        }
                    
                }else if([str_operationName isEqualToString:@"update"]){//Update operation performed here...
                    
                    NSError *jsonError;
                    NSDictionary *dict_rowData = [NSJSONSerialization JSONObjectWithData:[str_rowRecord dataUsingEncoding:NSUTF8StringEncoding]
                                                                                 options:NSJSONReadingMutableContainers
                                                                                   error:&jsonError];
                    
                    
                    NSInteger int_rowVersion = [str_rowVersion integerValue];
                    int_rowVersion += 1; //Auto increament version column...
                    
                    //After successfull sending data from device, we have to make appropriate change in table according to the record.
                    [DataBaseTask updateTableDataFromUserTableRecordForSyncDataTable:[NSArray arrayWithObject:dict_rowData] TableName:str_tableName primaryKeyName:[NSString stringWithFormat:@"%@",object[@"primarykeyname"]] primaryKeyValue:[NSString stringWithFormat:@"%@",object[@"primarykeyvalue"]] version:[NSString stringWithFormat:@"%ld",(long)int_rowVersion] completion:^(BOOL success){
                    if(success){
                        NSLog(@"update into %@ table success.",str_tableName);
                    }}];
                    
                    
                }else{//Delete operation performed here...
                    
                    BOOL isDeleteTableDataSuccess =  [DataBaseTask deleteRecordFromTable:deviceID deviceID:deviceID tableName:str_tableName primaryKeyName:[NSString stringWithFormat:@"%@",object[@"primarykeyname"]] primaryKeyValue:[NSString stringWithFormat:@"%@",object[@"primarykeyvalue"]]];
                    if(isDeleteTableDataSuccess){
                        
                        NSLog(@"delete from %@ table success.",str_tableName);
                        
                    }
                    
                }
                
            }else if(![object[@"status"] isEqual:[NSNull null]] && object[@"status"] != nil && [object[@"status"]integerValue] == 2){ // Status == 2, if update will not success full accepted at server end, because version of row is less than version present version of row in master table at server table.
                
               //[iToast showToast:[NSString stringWithFormat:@"%@",object[@"data"]]];
                
            }
            
            
            //Here needs to delete data from UserTableRecordForLocalData table if any of three(insert,update,delete operation is performed...)
            BOOL isDeleteTableDataSuccess =  [DataBaseTask deleteRecordFromTable:deviceID deviceID:deviceID tableName:@"UserTableRecordForLocalData" primaryKeyName:@"ID" primaryKeyValue:str_LocalDataBasePrimaryKeyId]; //This is UserTableRecordForLocalData table where primary key name is 'ID'...
            if(isDeleteTableDataSuccess){
                
                NSLog(@"isDeletedfrom_UserTableRecordForLocalData");
            }
            
            [self checkUserTableRecordForLocalData];//Need to check again, is there any data entry in UserTableRecordForLocalData for sync...
            
            }
            
    });
        
    } serviceUrl:serviceUrl onError:^(NSError *error) {
        
        [iToast showToast:[NSString stringWithFormat:@"%@",error.localizedDescription]];
        
    }params:dict_Parameters];
    
    
}


#pragma mark ************---------UITableView DataSource----------************
-(void)viewDidLayoutSubviews
{
    if ([_tableView_databaseTableList respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView_databaseTableList setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([_tableView_databaseTableList respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView_databaseTableList setLayoutMargins:UIEdgeInsetsZero];
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
        return array_databaseTableList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"databaseTableListCell";
    DatabaseTableListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.labelName.text = [NSString stringWithFormat:@"%@",array_databaseTableList[indexPath.row][@"table"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

#pragma mark ************---------UIButton Clicks----------************
/*
 Insert a new record, because here no user interface is available...
 */
- (IBAction)button_insertDataClicked:(UIButton *)sender {
    [self insertDataIntoUserTableRecordForLocalData_InsertOperation:kDeviceID deviceID:kDeviceID]; //insert manually data to insert new entry...
}
- (IBAction)button_viewAllDataClicked:(UIButton *)sender{
    
    ViewAllDataViewController *viewAllDataVCObj = [self.storyboard instantiateViewControllerWithIdentifier:@"viewAllDataViewController"];
    [self.navigationController pushViewController:viewAllDataVCObj animated:NO];

}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
@end
