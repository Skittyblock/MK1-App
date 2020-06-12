// MKScriptSettingsViewController.h

#import <UIKit/UIKit.h>
#import "MKScript.h"

@interface MKScriptSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MKScript *script;
@property (nonatomic, strong) UITableView *tableView;

@end
