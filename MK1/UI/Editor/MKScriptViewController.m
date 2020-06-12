// MKScriptViewController.m

#import "MKScriptViewController.h"
#import "MKScriptSettingsViewController.h"
#import "MKManager.h"

@implementation MKScriptViewController

- (instancetype)initWithScript:(MKScript *)script {
    self = [super init];
    
    if (self) {
        self.script = script;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.script.name;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    UIImage *ellipsisImage;
    
    if (@available(iOS 13.0, *)) {
        ellipsisImage = [UIImage systemImageNamed:@"ellipsis"];
        self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    } else {
        self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:ellipsisImage style:UIBarButtonItemStylePlain target:self action:@selector(openMenu)];
    
    // Text view
    self.textStorage = [[MKTextStorage alloc] init];
    [self.textStorage.highlighter setThemeTo:@"monokai-sublime"]; // monokai-sublime, dracula, atom-one-dark, railscasts
    self.textStorage.language = @"js";
    [self updateColors];

    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [self.textStorage addLayoutManager:layoutManager];

    NSTextContainer *textContainer = [[NSTextContainer alloc] init];
    [layoutManager addTextContainer:textContainer];
    
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds textContainer:textContainer];
    self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textView.smartDashesType = UITextSmartDashesTypeNo;
    self.textView.smartQuotesType = UITextSmartQuotesTypeNo;
    self.textView.smartInsertDeleteType = UITextSmartInsertDeleteTypeNo;
    self.textView.delegate = self;
    //self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.text = [self.script code];
    
    // Text view toolbar
    UIToolbar *editorToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    //UIToolbar *editorToolbar = [[UIToolbar alloc] init];
    //[editorToolbar sizeToFit];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard)];
    editorToolbar.items = @[flexSpace, doneBarButton];
    
    self.textView.inputAccessoryView = editorToolbar;
    
    [self.view addSubview:self.textView];
    
//    [self.textView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
//    [self.textView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
//    [self.textView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
//    [self.textView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    
    // Theme background color
    //self.view.backgroundColor = self.textStorage.highlighter.theme.themeBackgroundColor;
    //self.textView.backgroundColor = self.textStorage.highlighter.theme.themeBackgroundColor;
    
    // Keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self saveScript];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.script = [[MKScript alloc] initWithPath:self.script.path];
    if (self.script) {
        self.title = self.script.name;
        self.textView.text = [self.script code];
    }
}

- (void)orientationChanged {
    self.textView.frame = self.view.bounds;
}

- (void)dismiss {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)openMenu {
    MKScriptSettingsViewController *settingsViewController = [[MKScriptSettingsViewController alloc] init];
    settingsViewController.script = self.script;
    UINavigationController *settingsNavController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    [self.navigationController presentViewController:settingsNavController animated:YES completion:nil];
}

- (void)saveScript {
    [self.script setCode:self.textView.text];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (self.textView.bounds.size.height == self.view.bounds.size.height) {
        CGRect keyboardRect = [[[notification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGFloat delta = keyboardRect.size.height;
        if (delta < 258) delta += 44;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.frame.size.width, self.textView.frame.size.height - delta);
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect keyboardRect = [[[notification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat delta = keyboardRect.size.height;
    if (delta < 258) delta += 44;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.textView.frame = self.view.bounds;
    [UIView commitAnimations];
    
    [self saveScript];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self saveScript];
}

- (void)dismissKeyboard {
    [self.textView resignFirstResponder];
}

// Auto indentation
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        NSArray<NSString *> *lines = [textView.text componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet];
        
        NSInteger currentLoc = 0;
        NSInteger currentLine = 0;
        while (currentLoc <= range.location) {
            currentLoc += lines[currentLine].length + 1;
            currentLine++;
        }
        
        UITextPosition *start = [textView positionFromPosition:textView.beginningOfDocument offset:range.location];
        UITextPosition *end = [textView positionFromPosition:start offset:range.length];
        UITextRange *textRange = [textView textRangeFromPosition:start toPosition:end];
        
        NSString *lineIndent = @"\n";
        
        for (int i = 0; i < lines[currentLine-1].length; i++) {
            if ([[lines[currentLine-1] substringWithRange:NSMakeRange(i, 1)] rangeOfCharacterFromSet:NSCharacterSet.whitespaceCharacterSet].location != NSNotFound) {
                lineIndent = [lineIndent stringByAppendingString:[lines[currentLine-1] substringWithRange:NSMakeRange(i, 1)]];
            } else {
                break;
            }
        }
        
        [textView replaceRange:textRange withText:lineIndent];
            
        return NO;
    }
    
    return YES;
}

// Color themes
- (void)updateColors {
    if (@available(iOS 13.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            [self.textStorage.highlighter setThemeTo:@"monokai-sublime"];
        } else {
            [self.textStorage.highlighter setThemeTo:@"default"];
        }
    } else {
        [self.textStorage.highlighter setThemeTo:@"default"];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self updateColors];
}

@end
