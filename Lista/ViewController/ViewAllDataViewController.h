#import "Constants.h"
#import "UpdateViewController.h"
#import <sqlite3.h>

@protocol ViewAllDataCellDelegate <NSObject>

- (void)button_updateClicked:(UIButton *)sender;
- (void)button_deleteClicked:(UIButton *)sender;

@end

@interface ViewAllDataViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ViewAllDataCellDelegate,dataUpdateSuccess>
{
    NSMutableArray *array_viewAllData;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView_viewAllData;
@end
