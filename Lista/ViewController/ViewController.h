#import "Constants.h"
#import <sqlite3.h>

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    /*
     Singleton method created for AppDelegate.
     */
    NSMutableArray *array_databaseTableList; //for showing all table names from server.
    NSMutableArray *array_Record; //to handle all configuration related to data sync processed for table.
}

@property (weak, nonatomic) IBOutlet UITableView *tableView_databaseTableList;

@property (weak, nonatomic) IBOutlet UIButton *button_Insert;
- (IBAction)button_insertDataClicked:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *button_Update;
- (IBAction)button_updateDataClicked:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *button_Delete;
- (IBAction)button_deleteDataClicked:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *button_viewAllData;
- (IBAction)button_viewAllDataClicked:(UIButton *)sender;
@end
