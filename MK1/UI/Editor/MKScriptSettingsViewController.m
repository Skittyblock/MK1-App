// MKScriptSettingsViewController.m

#import "MKScriptSettingsViewController.h"
#import "MKSelectTriggerViewController.h"
#import "MKScriptViewController.h"
#import "MKEditableTableViewCell.h"
#import "MKManager.h"

@implementation MKScriptSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Settings";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
    
    if (@available(iOS 13, *)) {
        self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    } else {
        self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Update name
    MKEditableTableViewCell *nameCell = (MKEditableTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (nameCell.textField.text.length > 0 && ![nameCell.textField.text containsString:@"/"]) {
        [[MKManager sharedInstance] setName:nameCell.textField.text forScript:self.script];
        self.script = [[MKScript alloc] initWithPath:[[[MKManager sharedInstance] scriptsDirectory] stringByAppendingPathComponent:nameCell.textField.text]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"xyz.skitty.mk1.refreshscripts" object:nil];
        if ([self.presentingViewController isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController *)self.presentingViewController popToRootViewControllerAnimated:YES];
        }
    }
    
    // Update author
    MKEditableTableViewCell *authorCell = (MKEditableTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    if (authorCell.textField.text.length > 0) {
        [[MKManager sharedInstance] setAuthor:authorCell.textField.text forScript:self.script];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"xyz.skitty.mk1.refreshscripts" object:nil];
    }
    
    [[MKManager sharedInstance] sendMessage:@"updateScripts" withInfo:nil];
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { // Text cell
        MKEditableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell"];
        if (!cell) {
            cell = [[MKEditableTableViewCell alloc] initWithStyle:1000 reuseIdentifier:@"TextCell"];
        }
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Name";
            cell.textField.placeholder = self.script.name;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Author";
            cell.textField.placeholder = self.script.author;
        }
           
        return cell;
    } else if (indexPath.section == 1) { // Trigger list cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListSelectCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ListSelectCell"];
        }

        cell.textLabel.text = @"Triggers";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if (indexPath.section == 2) { // link cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LinkCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LinkCell"];
        }

        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Run Script";
                break;
            case 1:
                cell.textLabel.text = @"Share";
                break;
        }
        cell.textLabel.textColor = [UIColor systemBlueColor];
        
        return cell;
    } else if (indexPath.section == 3) { // danger cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LinkCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LinkCell"];
        }

        cell.textLabel.text = @"Delete Script";
        cell.textLabel.textColor = [UIColor systemRedColor];
           
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 1) {
        if (indexPath.row == 0) { // Trigger list
            MKSelectTriggerViewController *selectTriggerController = [[MKSelectTriggerViewController alloc] initWithScript:self.script];
            [self.navigationController pushViewController:selectTriggerController animated:YES];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) { // Run script
            [[MKManager sharedInstance] sendMessage:@"runScript" withInfo:@{@"name": self.script.name}];
            [self close];
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) { // Delete script
            [[MKManager sharedInstance] deleteScript:self.script];
            if ([self.presentingViewController isKindOfClass:[UINavigationController class]]) {
                [(UINavigationController *)self.presentingViewController popToRootViewControllerAnimated:YES];
            }
            [self close];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            if (!self.script.legacyFormat) return 2;
            return 1;
        case 1:
            return 1;
        case 2:
            return 1;
        case 3:
            return 1;
    }
    return 0;
}

@end
