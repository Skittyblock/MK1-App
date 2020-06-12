// MKSelectTriggerViewController.h

#import <UIKit/UIKit.h>
#import "MKScript.h"

@interface MKSelectTriggerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MKScript *script;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSString *> *triggers;
@property (nonatomic, strong) NSMutableArray<NSString *> *selectedTriggers;

- (instancetype)initWithScript:(MKScript *)script;

@end
