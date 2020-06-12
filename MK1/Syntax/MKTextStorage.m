// MKTextStorage.m

#import "MKTextStorage.h"
#import "MKHighlighter.h"

@implementation MKTextStorage

- (instancetype)initWithHighlighter:(MKHighlighter *)highlighter {
    self = [super init];
    
    if (self) {
        self.highlighter = highlighter;
    }
    
    return self;
}

- (instancetype)init {
    return [self initWithHighlighter:[[MKHighlighter alloc] init]];
}

// String storage
- (NSTextStorage *)stringStorage {
    if (!_stringStorage) {
        _stringStorage = [[NSTextStorage alloc] init];
    }

    return _stringStorage;
}

- (NSString *)string {
    return self.stringStorage.string;
}

- (NSDictionary<NSAttributedStringKey, id> *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range {
    return [self.stringStorage attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    [self.stringStorage replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters range:range changeInLength:str.length - range.length];
}

- (void)setAttributes:(NSDictionary<NSAttributedStringKey,id> *)attrs range:(NSRange)range {
    [self.stringStorage setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

// Highlight text after editing
- (void)processEditing {
    [super processEditing];

    if (self.language) {
        if (self.editedMask & NSTextStorageEditedCharacters) {
            NSString *string = self.string;
            NSRange range = [string paragraphRangeForRange:self.editedRange];
            [self highlight:range];
        }
    }
}

// Highlight text in range
- (void)highlight:(NSRange)range {
    if (!self.language) {
        return;
    }
    
    NSString *string = self.string;
    NSString *line = [string substringWithRange:range];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSAttributedString *tmpStrg = [self.highlighter highlight:line as:self.language];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Validate highlighting
            if ((range.location + range.length) > self.stringStorage.length) return;
            if (![tmpStrg.string isEqualToString:[self.stringStorage attributedSubstringFromRange:range].string]) return;

            // Highlight stored string
            [self beginEditing];
            [tmpStrg enumerateAttributesInRange:NSMakeRange(0, tmpStrg.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange locRange, BOOL * _Nonnull stop) {
                NSRange fixedRange = NSMakeRange(range.location+locRange.location, locRange.length);
                fixedRange.length = (fixedRange.location + fixedRange.length < string.length) ? fixedRange.length : string.length-fixedRange.location;
                fixedRange.length = (fixedRange.length >= 0) ? fixedRange.length : 0;
                [self.stringStorage setAttributes:attrs range:fixedRange];
            }];
            [self endEditing];
            [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
        });
    });
}

@end
