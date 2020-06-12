// MKNewScriptViewController.m

#import "MKNewScriptViewController.h"
#import "MKScriptsViewController.h"
#import "MKEditableTableViewCell.h"
#import "MKManager.h"

@implementation MKNewScriptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.title = @"New Script";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStylePlain target:self action:@selector(createScript)];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if (@available(iOS 13, *)) {
        self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    } else {
        self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
//    self.nameField = [[UITextField alloc] initWithFrame:CGRectMake(30, 100, [UIScreen mainScreen].bounds.size.width - 60, 40)];
//    self.nameField.placeholder = @"Name";
//    self.nameField.borderStyle = UITextBorderStyleRoundedRect;
//    self.nameField.delegate = self;
//    [self.view addSubview:self.nameField];
    
//    UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectMake(40, 100, [UIScreen mainScreen].bounds.size.width - 80, 40)];
//    nameField.placeholder = @"Name";
//    nameField.borderStyle = UITextBorderStyleRoundedRect;
//    [self.view addSubview:nameField];
    
//    self.doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    self.doneButton.frame = CGRectMake(30, 150, [UIScreen mainScreen].bounds.size.width - 60, 40);
//    self.doneButton.enabled = NO;
//    [self.doneButton setTitle:@"Create Script" forState:UIControlStateNormal];
//    [self.doneButton addTarget:self action:@selector(createScript) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.doneButton];
}

- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createScript {
    MKEditableTableViewCell *nameCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    MKEditableTableViewCell *authorCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [[MKManager sharedInstance] createScriptWithName:nameCell.textField.text author:authorCell.textField.text];
    [self close];
}

- (void)textFieldDidChangeSelection:(UITextField *)textField {
    if (textField.text.length > 0 && ![textField.text containsString:@"/"]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

// Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { // Open console cell
        MKEditableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell"];
        if (!cell) {
            cell = [[MKEditableTableViewCell alloc] initWithStyle:1000 reuseIdentifier:@"TextCell"];
        }
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Name";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Author";
        }
        cell.textField.delegate = self;
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
    }
    return 0;
}

@end

