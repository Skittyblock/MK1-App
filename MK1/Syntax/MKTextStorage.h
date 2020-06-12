// MKTextStorage.h

#import <UIKit/UIKit.h>
#import "MKHighlighter.h"

@interface MKTextStorage : NSTextStorage

@property (nonatomic, strong) MKHighlighter *highlighter;
@property (nonatomic, copy) NSString *language;
@property (nonatomic,strong) NSTextStorage *stringStorage;

- (instancetype)initWithHighlighter:(MKHighlighter *)highlighter;
- (void)highlight:(NSRange)range;

@end
