// MKSelectTriggerViewController.m

#import "MKSelectTriggerViewController.h"
#import "MKManager.h"

@implementation MKSelectTriggerViewController

- (instancetype)initWithScript:(MKScript *)script {
    self = [super init];
    
    if (self) {
        self.script = script;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Triggers";
    
    if (@available(iOS 13, *)) {
        self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    } else {
        self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    
    self.triggers = [[MKManager sharedInstance] triggerList];
    self.selectedTriggers = [[[MKManager sharedInstance] triggersForScript:self.script] mutableCopy];
    
    NSLog(@"self.selectedTriggers: %@", self.selectedTriggers);
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TriggerCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:3 reuseIdentifier:@"TriggerCell"];
    }

    cell.textLabel.text = self.triggers[indexPath.row];

    if ([self.selectedTriggers containsObject:self.triggers[indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *trigger = self.triggers[indexPath.row];

    if (![self.selectedTriggers containsObject:trigger]) {
        [self.selectedTriggers addObject:trigger];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        [[MKManager sharedInstance] addTrigger:trigger forScript:self.script];
    } else {
        [self.selectedTriggers removeObject:trigger];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        [[MKManager sharedInstance] removeTrigger:trigger forScript:self.script];
    }
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.triggers.count;
}

@end
