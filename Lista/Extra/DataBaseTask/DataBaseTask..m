
#import "Constants.h"
#import <sqlite3.h>

@implementation DataBaseTask : NSObject

+(void)insertTableNameForUserObservedFromServer:(NSString *)userID deviceID:(NSString *)deviceID withTables:(NSArray *)ary_Tables completion:(completionBlock)success{
    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    NSString *sqlStatement;
    sqlite3_stmt *compiledStatement;
    sqlite3 *database;
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        for (int i = 0; i < ary_Tables.count; i++) {

        sqlStatement = [NSString stringWithFormat:@"insert into 'UserTableRecordForSyncData' (ID,user_ID, device_ID, tableName, pageNumber, isSyncedAllData) VALUES (?,?, ?, ?, ?, ?)"];
        
        if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            
                sqlite3_bind_text(compiledStatement, 2, [userID UTF8String], -1, SQLITE_TRANSIENT);
                
                sqlite3_bind_text(compiledStatement, 3, [deviceID UTF8String], -1, SQLITE_TRANSIENT);
                
                NSString *tablename = [NSString stringWithFormat:@"%@",ary_Tables[i][@"table"]];
                sqlite3_bind_text(compiledStatement, 4, [tablename UTF8String], -1, SQLITE_TRANSIENT);

                NSString *pageNumber = @"0";
                sqlite3_bind_text(compiledStatement, 5, [pageNumber UTF8String], -1, SQLITE_TRANSIENT);
                
                NSString *isSyncedAllData = @"no";
                sqlite3_bind_text(compiledStatement, 6, [isSyncedAllData UTF8String], -1, SQLITE_TRANSIENT);
                
                if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
                    
                    if (i == (ary_Tables.count - 1))
                        sqlite3_finalize(compiledStatement);
                    else
                        sqlite3_reset(compiledStatement);
                    
                }else {
                    
                    NSLog(@"Insertion failed.");
                    success(NO);

                }
                
            }
            
        }
    }
    
    sqlite3_close(database);
    
    
    success(YES);
    
}

+(NSArray *)selectTableNameWithPageNumberForUserID:(NSString *)userID deviceID:(NSString *)deviceID{
    

    
    NSMutableArray *array_tableNameWithPageNumber = [NSMutableArray new];
    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    NSString *sqlStatement;
    sqlite3_stmt *compiledStatement;
    sqlite3 *database;
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        sqlStatement = [NSString stringWithFormat:@"SELECT * FROM `UserTableRecordForSyncData` where user_ID == \"%@\" AND isSyncedAllData == \"%@\"",userID,@"no"];
        
        if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
                
                NSString *string_TableName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
                [array_tableNameWithPageNumber addObject:string_TableName];

                NSString *string_PageNumber = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
                [array_tableNameWithPageNumber addObject:string_PageNumber];
                break;
            }
            
        }
        sqlite3_finalize(compiledStatement);
        
    }
    
    sqlite3_close(database);
    
    return array_tableNameWithPageNumber;
    
}

+(BOOL)insertNewDataInToLocalDatabase:(NSArray *)ary_Records TableName:(NSString *)tableName{
    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    sqlite3 *database;
    sqlite3_stmt *compiledStatement = NULL;

        
    NSMutableString *string_InsertStatement = [[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"INSERT INTO '%@' (",tableName]];
    NSArray *ary_allKeys = [ary_Records[0]allKeys];
    if ([Utility notNull:ary_allKeys] && ary_allKeys.count > 0) {
        
        for (int i = 0; i < ary_allKeys.count; i++) {
            
            if(ary_allKeys.count == 1)
                [string_InsertStatement appendString:[NSString stringWithFormat:@"`%@`)",ary_allKeys[i]]];    //Note:`` back quote is used to bypass reserve keyword of sqlite(i.e order,delete,schaema etc)
            else if (i == ary_allKeys.count-1)
                [string_InsertStatement appendString:[NSString stringWithFormat:@"`%@`) VALUES (",ary_allKeys[i]]];
            else
                [string_InsertStatement appendString:[NSString stringWithFormat:@"`%@`,",ary_allKeys[i]]];
            
        }
        
    }
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        char* errorMessage;
        sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
        
        NSMutableString *sqlStatement = [[NSMutableString alloc]init];
        
        NSMutableString *string_Values = [[NSMutableString alloc]init];
        
        for (int i = 0; i < ary_Records.count; i++) {
            
            [sqlStatement setString:@""];
            [string_Values setString:@""];
            
            if ([Utility notNull:ary_allKeys] && ary_allKeys.count > 0) {
                
                for (int j = 0; j < ary_allKeys.count; j++) {
                    
                    NSString *str_CheckForSpecialChars = ary_Records[i][ary_allKeys[j]]; //Handling if string contains ' character...
                    if (![str_CheckForSpecialChars isEqual:[NSNull null]] && str_CheckForSpecialChars != nil && ![str_CheckForSpecialChars isEqualToString:@"<null>"]){
                        
                        str_CheckForSpecialChars = [str_CheckForSpecialChars stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

                    }else{
                        
                        str_CheckForSpecialChars = @"";
                    }

                    if(ary_allKeys.count == 1)
                        [string_Values appendString:[NSString stringWithFormat:@"'%@')",str_CheckForSpecialChars]];
                    else if (j == ary_allKeys.count-1)
                        [string_Values appendString:[NSString stringWithFormat:@"'%@')",str_CheckForSpecialChars]];
                    else
                        [string_Values appendString:[NSString stringWithFormat:@"'%@',",str_CheckForSpecialChars]];
                    
                }
                
            }
            [sqlStatement appendString:[NSString stringWithFormat:@"%@%@",string_InsertStatement,string_Values]];
        
            
            if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
                
                if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
                    
                }else{
                 
                    sqlite3_reset(compiledStatement);
                    
                }
                
            }
            
            sqlite3_finalize(compiledStatement);

            
        }
        
        sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
        
        sqlStatement = nil;
        string_Values = nil;

    }
    
    string_InsertStatement = nil;
    sqlite3_close(database);
    return YES;
    
}

+(BOOL)updateDataSuccessfullWriteInLocalDatabaseForUserID:(NSString *)userID tableName:(NSString *)tableName pageNumber:(NSString *)pageNumber deviceID:(NSString *)deviceID{
    
    
        NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
        NSString *sqlStatement;
        sqlite3_stmt *compiledStatement;
        sqlite3 *database;
    
        if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {

            sqlStatement = [NSString stringWithFormat:@"UPDATE 'UserTableRecordForSyncData' SET pageNumber = \"%@\" WHERE user_ID = \"%@\" AND tableName =  \"%@\"",pageNumber,userID,tableName];
    
            if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
    
                if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
                    
                    
                }
            }
    
            sqlite3_finalize(compiledStatement);
    
        }

    sqlite3_close(database);
    
    return YES;

}

+(void)updateDataSuccessfullSyncedAllDataInLocalDatabaseForUserID:(NSString *)userID tableName:(NSString *)tableName deviceID:(NSString *)deviceID yesOrNo:(NSString *)yesOrNo completion:(completionBlock)success{
    
    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    NSString *sqlStatement;
    sqlite3_stmt *compiledStatement;
    sqlite3 *database;
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        if ([yesOrNo isEqualToString:@"yes"]) {
            
            sqlStatement = [NSString stringWithFormat:@"UPDATE 'UserTableRecordForSyncData' SET isSyncedAllData = \"%@\" WHERE user_ID = \"%@\" AND tableName =  \"%@\"",yesOrNo,userID,tableName];
            
        }else{
            
           sqlStatement = [NSString stringWithFormat:@"UPDATE 'UserTableRecordForSyncData' SET isSyncedAllData = \"%@\" WHERE user_ID = \"%@\" AND tableName =  \"%@\"",@"no",userID,tableName];
            
        }
       
        
        if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
            }
        }
        
        sqlite3_finalize(compiledStatement);
        
    }
    
    sqlite3_close(database);
    
    success(YES);
    
}

+(void)afterDeleteAllDataUpdateDataSuccessfullSyncedAllDataInLocalDatabaseForUserID:(NSString *)userID tableName:(NSString *)tableName deviceID:(NSString *)deviceID yesOrNo:(NSString *)yesOrNo completion:(completionBlock)success{
    
    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    NSString *sqlStatement;
    sqlite3_stmt *compiledStatement;
    sqlite3 *database;
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        if ([yesOrNo isEqualToString:@"yes"]) {
            
            sqlStatement = [NSString stringWithFormat:@"UPDATE 'UserTableRecordForSyncData' SET isSyncedAllData = \"%@\" WHERE user_ID = \"%@\" AND tableName =  \"%@\"",yesOrNo,userID,tableName];
            
        }else{
            
            sqlStatement = [NSString stringWithFormat:@"UPDATE 'UserTableRecordForSyncData' SET pageNumber = 0, isSyncedAllData = \"%@\" WHERE user_ID = \"%@\" AND tableName =  \"%@\"",@"no",userID,tableName];
            
        }
        
        
        if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
            }
        }
        
        sqlite3_finalize(compiledStatement);
        
    }
    
    sqlite3_close(database);
    
    success(YES);
    
}

+(NSArray *)selectAllTableNameFromDataBase{
    
    NSMutableArray *array_tableName = [NSMutableArray new];
    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    NSString *sqlStatement;
    sqlite3_stmt *compiledStatement;
    sqlite3 *database;
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        sqlStatement = [NSString stringWithFormat:@"SELECT * FROM 'UserTableRecordForSyncData'"];
        
        if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
                NSString *string_TableName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
                NSMutableDictionary *dic_tableName = [[NSMutableDictionary alloc]init];
                [dic_tableName setValue:string_TableName forKey:@"table"];
                [array_tableName addObject:dic_tableName];
              
            }
        }
        sqlite3_finalize(compiledStatement);
        
    }
    
    sqlite3_close(database);
    return array_tableName;
    
}

+(BOOL)dropFromLocalDatabaseOldTable:(NSString *)tableName{
    
    BOOL isDropTableSuccess = NO;
    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    NSString *sqlStatement;
    sqlite3_stmt *compiledStatement;
    sqlite3 *database;
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        sqlStatement = [NSString stringWithFormat:@"DROP TABLE IF EXISTS \"%@\"",tableName];
        
        if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
                isDropTableSuccess = YES;
            }
        }
        sqlite3_finalize(compiledStatement);
        
    }
    
    sqlite3_close(database);
    
    return isDropTableSuccess;
    
}

+(void)createBlankTableinLocalDatabase:(NSString *)tableName tableColumns:(NSArray *)arrayTableColumns{
    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    sqlite3 *database;
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        
            NSMutableString *sqlStatement = [[NSMutableString alloc]initWithString:@"CREATE TABLE IF NOT EXISTS "];
            
            [sqlStatement appendString:[NSString stringWithFormat:@"[%@] ",tableName]];
            
        
            if([Utility notNull:arrayTableColumns] && arrayTableColumns.count>0){
                
                for (int j = 0; j < arrayTableColumns.count; j++) {
                    
                    NSDictionary *dic = arrayTableColumns[j];
                    
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
                    
                    if (j==arrayTableColumns.count-1) {
                        
                        [sqlStatement appendString:[NSString stringWithFormat:@")"]];
                        
                    }
                    
                }
                
            }
            
            char *errMsg;
            if (sqlite3_exec(database, [sqlStatement UTF8String], NULL, NULL, &errMsg) == SQLITE_OK)
            {
                
                NSLog(@"Table creation success.");

                //No record found at this page...
                [DataBaseTask afterDeleteAllDataUpdateDataSuccessfullSyncedAllDataInLocalDatabaseForUserID:kDeviceID tableName:[NSString stringWithFormat:@"%@",tableName] deviceID:[NSString stringWithFormat:@"%@",kDeviceID] yesOrNo:@"no" completion:^(BOOL success){
                    if(success){
                        
                    }
                    
                }];
                
            }
        
    }
    
    sqlite3_close(database);
    
}

+(BOOL)deleteFromLocalDatabaseOldTableData:(NSString *)tableName{
    
    BOOL isDeleteTableDataSuccess = NO;
    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    NSString *sqlStatement;
    sqlite3_stmt *compiledStatement;
    sqlite3 *database;
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        sqlStatement = [NSString stringWithFormat:@"DELETE FROM \"%@\"",tableName];
        
        if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
                
                isDeleteTableDataSuccess = YES;
                
                //No record found at this page...
                [DataBaseTask afterDeleteAllDataUpdateDataSuccessfullSyncedAllDataInLocalDatabaseForUserID:kDeviceID tableName:[NSString stringWithFormat:@"%@",tableName] deviceID:[NSString stringWithFormat:@"%@",kDeviceID] yesOrNo:@"no" completion:^(BOOL success){
                    if(success){
                        
                    }
                    
                }];
            }
        }
        sqlite3_finalize(compiledStatement);
        
    }
    
    sqlite3_close(database);
    
    return isDeleteTableDataSuccess;
    
}

+(void)insertIntoUserTableRecordForLocalData:(NSString *)userID deviceID:(NSString *)deviceID tableName:(NSString *)tableName withRowData:(NSString *)rowData operation:(NSString *)operationName primaryKeyName:(NSString *)primarykeyname primaryKeyValue:(NSString *)primarykeyvalue version:(NSString *)versionRecord completion:(completionBlock)success{
    
        NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
        NSString *sqlStatement;
        sqlite3_stmt *compiledStatement;
        sqlite3 *database;
    
        if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
            
            sqlStatement = [NSString stringWithFormat:@"insert into 'UserTableRecordForLocalData' (`ID`, `user_ID`, `device_ID`, `tableName`, `rowData`, `operationName`, `primarykeyname`, `primarykeyvalue`, `version`) VALUES (?,?, ?, ?, ?, ?, ?, ?, ?)"];
            
            if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
                
                
                sqlite3_bind_text(compiledStatement, 2, [[NSString stringWithFormat:@"%@",userID] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(compiledStatement, 3, [[NSString stringWithFormat:@"%@",deviceID] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(compiledStatement, 4, [[NSString stringWithFormat:@"%@",tableName] UTF8String], -1, SQLITE_TRANSIENT);
                if (![rowData isEqual:[NSNull null]] && rowData != nil && ![rowData isEqualToString:@"<null>"]){
                    
                    rowData = [rowData stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                    
                }else{
                    
                    rowData = @"";
                }
                sqlite3_bind_text(compiledStatement, 5, [[NSString stringWithFormat:@"%@",rowData] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(compiledStatement, 6, [[NSString stringWithFormat:@"%@",operationName] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(compiledStatement, 7, [[NSString stringWithFormat:@"%@",primarykeyname] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(compiledStatement, 8, [[NSString stringWithFormat:@"%@",primarykeyvalue] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(compiledStatement, 9, [[NSString stringWithFormat:@"%@",versionRecord] UTF8String], -1, SQLITE_TRANSIENT);

                if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
                    
                    NSLog(@"Success full inserted into UserTableRecordForLocalData for %@.",operationName);

                }
                
            }
            
            sqlite3_finalize(compiledStatement);
            
        }
    
        sqlite3_close(database);
    
    
        success(YES);
    
}

+(NSArray *)selectSingleLocalRecordToSendserverForUserID:(NSString *)userID deviceID:(NSString *)deviceID{
    
    NSMutableArray *array_SingleRecordOfTable = [NSMutableArray new];
    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    NSString *sqlStatement;
    sqlite3_stmt *compiledStatement;
    sqlite3 *database;
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        sqlStatement = [NSString stringWithFormat:@"SELECT * FROM `UserTableRecordForLocalData` where user_ID == \"%@\" AND device_ID == \"%@\"",userID,deviceID];
        
        if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
                NSString *string_Id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
                [array_SingleRecordOfTable addObject:string_Id];
                
                NSString *string_userID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                [array_SingleRecordOfTable addObject:string_userID];
                
                NSString *string_deviceID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                [array_SingleRecordOfTable addObject:string_deviceID];
                
                NSString *string_TableName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
                [array_SingleRecordOfTable addObject:string_TableName];
                
                NSString *string_rowData = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
                [array_SingleRecordOfTable addObject:string_rowData];
             
                NSString *string_operationName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
                [array_SingleRecordOfTable addObject:string_operationName];
                
                NSString *string_primarykeyname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
                [array_SingleRecordOfTable addObject:string_primarykeyname];
                
                NSString *string_primarykeyvalue = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
                [array_SingleRecordOfTable addObject:string_primarykeyvalue];
                
                NSString *string_rowVersion = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
                [array_SingleRecordOfTable addObject:string_rowVersion];
                break;
            }
            
        }
        sqlite3_finalize(compiledStatement);
        
    }
    
    sqlite3_close(database);

    return array_SingleRecordOfTable;
    
}

+(BOOL)deleteRecordFromTable:(NSString *)userID deviceID:(NSString *)deviceID tableName:(NSString *)tableName primaryKeyName:(NSString *)primarykeyname primaryKeyValue:(NSString *)primarykeyvalue{
    
    BOOL isDeleteTableDataSuccess = NO;
    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    NSString *sqlStatement;
    sqlite3 *database;
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
      
        sqlite3_stmt *compiledStatement;
        sqlStatement = [NSString stringWithFormat:@"DELETE FROM `%@` where %@ = %@",tableName,primarykeyname,primarykeyvalue];
        
        if(sqlite3_prepare(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) == SQLITE_DONE) {

                isDeleteTableDataSuccess = YES;
            }
            
        }
        sqlite3_finalize(compiledStatement);
        
    }
    
    sqlite3_close(database);
    
    return isDeleteTableDataSuccess;
    
    
}

+(void)updateTableDataFromUserTableRecordForSyncDataTable:(NSArray *)ary_Records TableName:(NSString *)tableName primaryKeyName:(NSString *)primarykeyname primaryKeyValue:(NSString *)primarykeyvalue version:(NSString *)string_Version completion:(completionBlock)success{
    
    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    sqlite3_stmt *compiledStatement = NULL;
    sqlite3 *database;
    NSMutableString *string_sqlUpadateStatement = [[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"UPDATE '%@' SET",tableName]];
    NSArray *ary_allKeys = [ary_Records[0]allKeys];

    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
            if ([Utility notNull:ary_allKeys] && ary_allKeys.count > 0) {
                
                for (int i = 0; i < ary_allKeys.count; i++) {
                    
                    NSString *str_CheckForSpecialChars = ary_Records[0][ary_allKeys[i]]; //Handling if string contains ' character...
                    if (![str_CheckForSpecialChars isEqual:[NSNull null]] && str_CheckForSpecialChars != nil && ![str_CheckForSpecialChars isEqualToString:@"<null>"]){
                        
                        str_CheckForSpecialChars = [str_CheckForSpecialChars stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                        
                    }else{
                        
                        str_CheckForSpecialChars = @"";
                    }
                    
                    if(ary_allKeys.count == 1)
                        [string_sqlUpadateStatement appendString:[NSString stringWithFormat:@"`%@` = '%@'",ary_allKeys[i],str_CheckForSpecialChars]];
                    else if (i == ary_allKeys.count-1)
                        [string_sqlUpadateStatement appendString:[NSString stringWithFormat:@" '%@' = '%@'",ary_allKeys[i],str_CheckForSpecialChars]];
                    else
                        [string_sqlUpadateStatement appendString:[NSString stringWithFormat:@" '%@' = '%@',",ary_allKeys[i],str_CheckForSpecialChars]];
                    
                }
                
            }
        
        [string_sqlUpadateStatement appendString:[NSString stringWithFormat:@", 'version' = '%@'",string_Version]];
        [string_sqlUpadateStatement appendString:[NSString stringWithFormat:@" where %@ = %@",primarykeyname,primarykeyvalue]];

        NSLog(@"%@",string_sqlUpadateStatement);
        
            if(sqlite3_prepare_v2(database, [string_sqlUpadateStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
                
                if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
                    
                    sqlite3_finalize(compiledStatement);
                    success(YES);

                }
                
            }
            
        
        
    }
    
    sqlite3_close(database);
    
    success(NO);

}

+(void)updateTableDataFromServerWithVersion:(NSArray *)ary_Records TableName:(NSString *)tableName primaryKeyName:(NSString *)primarykeyname primaryKeyValue:(NSString *)primarykeyvalue version:(NSString *)string_Version completion:(completionBlock)success{
    
    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    sqlite3_stmt *compiledStatement = NULL;
    sqlite3 *database;
    NSMutableString *string_sqlUpadateStatement = [[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"UPDATE '%@' SET",tableName]];
    NSArray *ary_allKeys = [ary_Records[0]allKeys];
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        if ([Utility notNull:ary_allKeys] && ary_allKeys.count > 0) {
            
            for (int i = 0; i < ary_allKeys.count; i++) {
                
                NSString *str_CheckForSpecialChars = ary_Records[0][ary_allKeys[i]]; //Handling if string contains ' character...
                if (![str_CheckForSpecialChars isEqual:[NSNull null]] && str_CheckForSpecialChars != nil && ![str_CheckForSpecialChars isEqualToString:@"<null>"]){
                    
                    str_CheckForSpecialChars = [str_CheckForSpecialChars stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                    
                }else{
                    
                    str_CheckForSpecialChars = @"";
                }
                
                if(ary_allKeys.count == 1)
                    [string_sqlUpadateStatement appendString:[NSString stringWithFormat:@"`%@` = '%@'",ary_allKeys[i],str_CheckForSpecialChars]];
                else if (i == ary_allKeys.count-1)
                    [string_sqlUpadateStatement appendString:[NSString stringWithFormat:@" '%@' = '%@'",ary_allKeys[i],str_CheckForSpecialChars]];
                else
                    [string_sqlUpadateStatement appendString:[NSString stringWithFormat:@" '%@' = '%@',",ary_allKeys[i],str_CheckForSpecialChars]];
                
            }
            
        }
        
        [string_sqlUpadateStatement appendString:[NSString stringWithFormat:@", 'version' = '%@'",string_Version]];
        [string_sqlUpadateStatement appendString:[NSString stringWithFormat:@" where %@ = %@",primarykeyname,primarykeyvalue]];
        
        
        NSLog(@"%@",string_sqlUpadateStatement);
        
        if(sqlite3_prepare_v2(database, [string_sqlUpadateStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
                
                success(YES);
                
            }
            
        }
        
        sqlite3_finalize(compiledStatement);

        
    }
    
    sqlite3_close(database);
    
    success(NO);
    
}
#pragma mark UnsyncedDataViewController
+(NSArray *)selectLocalRecordForUserID:(NSString *)userID deviceID:(NSString *)deviceID tableName:(NSString *)tableName{
    
    NSMutableArray *array_TotalRecordsOfBokadTable= [NSMutableArray new];
    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    NSString *sqlStatement;
    sqlite3_stmt *compiledStatement;
    sqlite3 *database;
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        //sqlStatement = [NSString stringWithFormat:@"SELECT * FROM `%@` where user_ID == \"%@\"",tableName,userID];
        sqlStatement = [NSString stringWithFormat:@"SELECT * FROM `%@`",tableName];

        if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
                NSDictionary *dic_SingleRecord = [NSMutableDictionary new];

                NSString *string_ID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
                [dic_SingleRecord setValue:string_ID forKey:@"ID"];
                
                [dic_SingleRecord setValue:@"ID" forKey:@"primarykeyname"];
                [dic_SingleRecord setValue:string_ID forKey:@"primarykeyvalue"];

                
                NSString *string_Montor = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                [dic_SingleRecord setValue:string_Montor forKey:@"montor"];

                NSString *string_Datum = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                [dic_SingleRecord setValue:string_Datum forKey:@"datum"];
                
                NSString *string_Tid1 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
                [dic_SingleRecord setValue:string_Tid1 forKey:@"tid1"];
                
                NSString *string_Order = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
                [dic_SingleRecord setValue:string_Order forKey:@"order"];
                
                NSString *string_Tid2 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
                [dic_SingleRecord setValue:string_Tid2 forKey:@"tid2"];
                
                NSString *string_Todo = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
                [dic_SingleRecord setValue:string_Todo forKey:@"todo"];
                
                NSString *string_Bokadtyp = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
                [dic_SingleRecord setValue:string_Bokadtyp forKey:@"bokadtyp"];
                
                NSString *string_Avslutad = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
                [dic_SingleRecord setValue:string_Avslutad forKey:@"avslutad"];
                
                NSString *string_EditedBy = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 9)];
                [dic_SingleRecord setValue:string_EditedBy forKey:@"EditedBy"];
                
                
                NSString *string_Version = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 10)];
                [dic_SingleRecord setValue:string_Version forKey:@"version"];
                
                [dic_SingleRecord setValue:@"no" forKey:@"isDataFromUserTableRecordForLocalData"];//this is extra flag added with each row, by which we can identify that this entry is from master/intermediate table.

                [array_TotalRecordsOfBokadTable addObject:dic_SingleRecord];
                
                dic_SingleRecord = nil;

            }
            
        }
        
        sqlite3_finalize(compiledStatement);
        
    }
    
    sqlite3_close(database);
    
    return array_TotalRecordsOfBokadTable;
    
}

+(NSArray *)selectOnlyUpdatedRecordIntoUserTableRecordForLocalData:(NSString *)userID deviceID:(NSString *)deviceID tableName:(NSString *)tableName{
    
    NSMutableArray *array_unsyncedData = [NSMutableArray new];
    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    NSString *sqlStatement;
    sqlite3_stmt *compiledStatement;
    sqlite3 *database;
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        //sqlStatement = [NSString stringWithFormat:@"SELECT * FROM `%@` where user_ID == \"%@\"",tableName,userID];
        sqlStatement = [NSString stringWithFormat:@"SELECT * FROM `UserTableRecordForLocalData` where tablename == \"%@\" AND  operationName == \"%@\"",tableName,@"update"];
        
        if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
               // NSMutableDictionary *dic_SingleRecord = [NSMutableDictionary new];
                
               

//                NSString *string_Montor = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
//                [dic_SingleRecord setValue:string_Montor forKey:@"montor"];
//
//                NSString *string_Datum = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
//                [dic_SingleRecord setValue:string_Datum forKey:@"datum"];
//
//                NSString *string_Tid1 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
//                [dic_SingleRecord setValue:string_Tid1 forKey:@"tid1"];

                NSString *string_SingleRowJSONRecord = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
                //[dic_SingleRecord setValue:string_SingleRowJSONRecord forKey:@"order"];

                NSError *jsonError;
                NSData *objectData = [string_SingleRowJSONRecord dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dic_SingleRecord = [NSJSONSerialization JSONObjectWithData:objectData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&jsonError];
                
                NSString *string_ID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
                [dic_SingleRecord setValue:string_ID forKey:@"ID"];
                
                
                NSString *string_PrimaryKeyName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
                [dic_SingleRecord setValue:string_PrimaryKeyName forKey:@"primarykeyname"];
                
                NSString *string_PrimaryKeyValue = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
                [dic_SingleRecord setValue:string_PrimaryKeyValue forKey:@"primarykeyvalue"];
                
                [dic_SingleRecord setValue:@"yes" forKey:@"isDataFromUserTableRecordForLocalData"];//this is extra flag added with each row, by which we can identify that this entry is from master/intermediate table.

                
                [array_unsyncedData addObject:dic_SingleRecord];
                
                dic_SingleRecord = nil;
                
                
            }
            
        }
        sqlite3_finalize(compiledStatement);
        
    }
    
    sqlite3_close(database);
    
    return array_unsyncedData;
    
}

+(NSArray *)selectOnlyInsertedRecordIntoUserTableRecordForLocalData:(NSString *)userID deviceID:(NSString *)deviceID tableName:(NSString *)tableName{
    
    NSMutableArray *array_unsyncedData = [NSMutableArray new];
    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    NSString *sqlStatement;
    sqlite3_stmt *compiledStatement;
    sqlite3 *database;
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        //sqlStatement = [NSString stringWithFormat:@"SELECT * FROM `%@` where user_ID == \"%@\"",tableName,userID];
        sqlStatement = [NSString stringWithFormat:@"SELECT * FROM `UserTableRecordForLocalData` where tablename == \"%@\" AND operationName == \"%@\"",tableName,@"insert"];
        
        if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
                // NSMutableDictionary *dic_SingleRecord = [NSMutableDictionary new];
                
                
                
                //                NSString *string_Montor = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                //                [dic_SingleRecord setValue:string_Montor forKey:@"montor"];
                //
                //                NSString *string_Datum = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                //                [dic_SingleRecord setValue:string_Datum forKey:@"datum"];
                //
                //                NSString *string_Tid1 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
                //                [dic_SingleRecord setValue:string_Tid1 forKey:@"tid1"];
                
                NSString *string_SingleRowJSONRecord = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
                //[dic_SingleRecord setValue:string_SingleRowJSONRecord forKey:@"order"];
                
                NSError *jsonError;
                NSData *objectData = [string_SingleRowJSONRecord dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *dic_SingleRecord = [NSJSONSerialization JSONObjectWithData:objectData
                                                                                 options:NSJSONReadingMutableContainers
                                                                                   error:&jsonError];
                
                NSString *string_ID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
                [dic_SingleRecord setValue:string_ID forKey:@"ID"];
                
                
                NSString *string_PrimaryKeyName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
                [dic_SingleRecord setValue:string_PrimaryKeyName forKey:@"primarykeyname"];
                
                NSString *string_PrimaryKeyValue = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
                [dic_SingleRecord setValue:string_PrimaryKeyValue forKey:@"primarykeyvalue"];
                
                
                
                
                
                [dic_SingleRecord setValue:@"yes" forKey:@"isDataFromUserTableRecordForLocalData"];//this is extra flag added with each row, by which we can identify that this entry is from master/intermediate table.
                
                
                [array_unsyncedData addObject:dic_SingleRecord];
                
                dic_SingleRecord = nil;
                
                
            }
            
        }
        sqlite3_finalize(compiledStatement);
        
    }
    
    sqlite3_close(database);
    
    return array_unsyncedData;
    
}
+(BOOL)deleteRecordFromUserTableRecordForLocalData:(NSString *)userID deviceID:(NSString *)deviceID tableName:(NSString *)tableName primaryKeyName:(NSString *)primarykeyname primaryKeyValue:(NSString *)primarykeyvalue{
    
    BOOL isDeleteTableDataSuccess = NO;
    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    NSString *sqlStatement;
    sqlite3 *database;
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        sqlite3_stmt *compiledStatement;
        sqlStatement = [NSString stringWithFormat:@"DELETE FROM `UserTableRecordForLocalData` where tableName = \"%@\" AND %@ = %@",tableName,primarykeyname,primarykeyvalue];
        
        if(sqlite3_prepare(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) == SQLITE_DONE) {

                isDeleteTableDataSuccess = YES;
            }
            
        }
        sqlite3_finalize(compiledStatement);
        
    }
    
    sqlite3_close(database);
    
    return isDeleteTableDataSuccess;
    
    
}

+(NSDictionary *)isRecordExistsInDataBaseForUserID:(NSString *)userID deviceID:(NSString *)deviceID tableName:(NSString *)tableName primaryKeyName:(NSString *)primarykeyname primaryKeyValue:(NSString *)primarykeyvalue versionColumnNumber:(int)versionColumnNumber{
    
    NSMutableDictionary *dict_isExistsWithVersion = [NSMutableDictionary new];
    [dict_isExistsWithVersion setValue:@"no" forKey:@"isExists"];
    [dict_isExistsWithVersion setValue:@"" forKey:@"version"];


    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    NSString *sqlStatement;
    sqlite3_stmt *compiledStatement;
    sqlite3 *database;
    
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {

        sqlStatement = [NSString stringWithFormat:@"SELECT * FROM `%@` WHERE %@ == %@",tableName,primarykeyname,primarykeyvalue];
        
        if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {

            NSString *string_Version = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, versionColumnNumber)];
            [dict_isExistsWithVersion setValue:[NSString stringWithFormat:@"%@",string_Version] forKey:@"version"];
            [dict_isExistsWithVersion setValue:@"yes" forKey:@"isExists"];

            }
        }
        sqlite3_finalize(compiledStatement);
        
    }
    
    sqlite3_close(database);
    
    return dict_isExistsWithVersion;

}

+(BOOL)updateIntoUserTableRecordForLocalData:(NSString *)str_RowData primaryKeyValue:(NSString *)primarykeyvalue{
    
    BOOL success = NO;
    
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bokatoklart5.sqlite"];
    
    sqlite3_stmt *compiledStatement = NULL;
    sqlite3 *database;
    NSMutableString *string_sqlUpadateStatement = [[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"UPDATE 'UserTableRecordForLocalData' SET rowData = '%@'  WHERE ID == '%@'",str_RowData,primarykeyvalue]];
    NSLog(@"%@",string_sqlUpadateStatement);

    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        if(sqlite3_prepare_v2(database, [string_sqlUpadateStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
                
                success = YES;
            }
            
        }
        
        sqlite3_finalize(compiledStatement);
        
    }
    
    sqlite3_close(database);
    
    return success;
    
}

@end
