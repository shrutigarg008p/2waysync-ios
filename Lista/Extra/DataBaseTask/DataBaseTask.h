#import "Constants.h"
#import <sqlite3.h>
typedef void  (^completionBlock) (BOOL suuccess);


@interface DataBaseTask : NSObject{
    
}

+(void)insertTableNameForUserObservedFromServer:(NSString *)userID deviceID:(NSString *)deviceID withTables:(NSArray *)ary_Tables completion:(completionBlock)success;
+(NSArray *)selectTableNameWithPageNumberForUserID:(NSString *)userID deviceID:(NSString *)deviceID;
+(BOOL)insertNewDataInToLocalDatabase:(NSArray *)ary_Records TableName:(NSString *)tableName;
+(BOOL)updateDataSuccessfullWriteInLocalDatabaseForUserID:(NSString *)userID tableName:(NSString *)tableName pageNumber:(NSString *)pageNumber deviceID:(NSString *)deviceID;
+(void)updateDataSuccessfullSyncedAllDataInLocalDatabaseForUserID:(NSString *)userID tableName:(NSString *)tableName deviceID:(NSString *)deviceID yesOrNo:(NSString *)yesOrNo completion:(completionBlock)success;
+(void)afterDeleteAllDataUpdateDataSuccessfullSyncedAllDataInLocalDatabaseForUserID:(NSString *)userID tableName:(NSString *)tableName deviceID:(NSString *)deviceID yesOrNo:(NSString *)yesOrNo completion:(completionBlock)success;
+(NSArray *)selectAllTableNameFromDataBase;
+(BOOL)dropFromLocalDatabaseOldTable:(NSString *)tableName;
+(void)createBlankTableinLocalDatabase:(NSString *)tableName tableColumns:(NSArray *)arrayTableColumns;
+(BOOL)deleteFromLocalDatabaseOldTableData:(NSString *)tableName;
+(void)insertIntoUserTableRecordForLocalData:(NSString *)userID deviceID:(NSString *)deviceID tableName:(NSString *)tableName withRowData:(NSString *)rowData operation:(NSString *)operationName primaryKeyName:(NSString *)primarykeyname primaryKeyValue:(NSString *)primarykeyvalue version:(NSString *)versionRecord completion:(completionBlock)success;
+(NSArray *)selectSingleLocalRecordToSendserverForUserID:(NSString *)userID deviceID:(NSString *)deviceID;
+(BOOL)deleteRecordFromTable:(NSString *)userID deviceID:(NSString *)deviceID tableName:(NSString *)tableName primaryKeyName:(NSString *)primarykeyname primaryKeyValue:(NSString *)primarykeyvalue;
+(void)updateTableDataFromUserTableRecordForSyncDataTable:(NSArray *)ary_Records TableName:(NSString *)tableName primaryKeyName:(NSString *)primarykeyname primaryKeyValue:(NSString *)primarykeyvalue version:(NSString *)string_Version completion:(completionBlock)success;
+(void)updateTableDataFromServerWithVersion:(NSArray *)ary_Records TableName:(NSString *)tableName primaryKeyName:(NSString *)primarykeyname primaryKeyValue:(NSString *)primarykeyvalue version:(NSString *)string_Version completion:(completionBlock)success;
#pragma UnsyncedDataViewController
+(NSArray *)selectLocalRecordForUserID:(NSString *)userID deviceID:(NSString *)deviceID tableName:(NSString *)tableName;
+(NSArray *)selectOnlyUpdatedRecordIntoUserTableRecordForLocalData:(NSString *)userID deviceID:(NSString *)deviceID tableName:(NSString *)tableName;
+(NSArray *)selectOnlyInsertedRecordIntoUserTableRecordForLocalData:(NSString *)userID deviceID:(NSString *)deviceID tableName:(NSString *)tableName;
+(BOOL)deleteRecordFromUserTableRecordForLocalData:(NSString *)userID deviceID:(NSString *)deviceID tableName:(NSString *)tableName primaryKeyName:(NSString *)primarykeyname primaryKeyValue:(NSString *)primarykeyvalue;
+(NSDictionary *)isRecordExistsInDataBaseForUserID:(NSString *)userID deviceID:(NSString *)deviceID tableName:(NSString *)tableName primaryKeyName:(NSString *)primarykeyname primaryKeyValue:(NSString *)primarykeyvalue versionColumnNumber:(int)versionColumnNumber;
+(BOOL)updateIntoUserTableRecordForLocalData:(NSString *)str_RowData primaryKeyValue:(NSString *)primarykeyvalue;
@end
