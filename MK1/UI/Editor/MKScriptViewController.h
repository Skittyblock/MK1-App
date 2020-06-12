// MKScriptViewController.h

#import <UIKit/UIKit.h>
#import "MKScript.h"
#import "MKTextStorage.h"

@interface MKScriptViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) MKScript *script;
@property (nonatomic, strong) MKTextStorage *textStorage;
@property (nonatomic, strong) UITextView *textView;

- (instancetype)initWithScript:(MKScript *)script;
- (void)dismiss;

@end
