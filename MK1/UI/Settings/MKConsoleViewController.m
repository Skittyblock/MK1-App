// MKConsoleViewController.m

#import "MKConsoleViewController.h"
#include <notify.h>

void updateConsoleNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void*object, CFDictionaryRef userInfo){
    [[NSNotificationCenter defaultCenter] postNotificationName:@"xyz.skitty.mk1app.updateconsole" object:nil];
}

@implementation MKConsoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Console";
    
    if (@available(iOS 13, *)) {
        self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    } else {
        self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearLog)];
    
    self.textView = [[UITextView alloc] initWithFrame:self.view.frame];
    self.textView.delegate = self;
    self.textView.attributedText = [[NSMutableAttributedString alloc] initWithString:@"Log is empty"];
    self.textView.font = [UIFont fontWithName:@"Menlo" size:12];
    if (@available(iOS 13.0, *)) {
        self.textView.textColor = [UIColor labelColor];
    }
    self.textView.editable = NO;
    [self updateConsole];
    [self.view addSubview:self.textView];
    
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    if (center) {
        CFNotificationCenterAddObserver(center, NULL, updateConsoleNotification, CFSTR("xyz.skitty.mk1app.updateconsole"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConsole) name:@"xyz.skitty.mk1app.updateconsole" object:nil];
    }
}

- (void)updateConsole {
    NSError *error;
    NSString *logtxt = [NSString stringWithContentsOfFile:@"/tmp/MK1.log" encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        self.textView.text = [error localizedDescription];
    } else if (logtxt.length > 1) {
        UIColor *textColor = [UIColor blackColor];
        UIColor *pinkColor = [UIColor magentaColor];
        UIColor *blueColor = [UIColor blueColor];
        UIColor *redColor = [UIColor redColor];
        UIColor *orangeColor = [UIColor orangeColor];
        if (@available(iOS 13.0, *)) {
            textColor = [UIColor labelColor];
            pinkColor = [UIColor systemPinkColor];
            blueColor = [UIColor systemBlueColor];
            redColor = [UIColor systemRedColor];
            orangeColor = [UIColor systemOrangeColor];
        }
        self.textView.attributedText = [[NSAttributedString alloc] initWithString:logtxt attributes:@{NSForegroundColorAttributeName:textColor}];
        [self setColorForText:@"[DEBUG]" color:pinkColor];
        [self setColorForText:@"[ERROR]" color:redColor];
        [self setColorForText:@"[INFO]" color:blueColor];
        [self setColorForText:@"[WARN]" color:orangeColor];
    }
}

- (void)setColorForText:(NSString *)textToFind color:(UIColor *)color {
    NSMutableAttributedString *str = [self.textView.attributedText mutableCopy];
    [self.textView.attributedText.string enumerateSubstringsInRange:[self.textView.attributedText.string rangeOfString:self.textView.attributedText.string] options:NSStringEnumerationByLines usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if ([substring hasPrefix:textToFind]) [str addAttribute:NSForegroundColorAttributeName value:color range:substringRange];
    }];
    self.textView.attributedText = str;
}

- (void)clearLog {
    [@"[INFO] [MK1] Log cleared." writeToFile:@"/tmp/MK1.log" atomically:NO encoding:NSUTF8StringEncoding error:nil];
    [self updateConsole];
}

@end
