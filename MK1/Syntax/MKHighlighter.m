// MKHighlighter.m
// Piggybacks off highlight.js to provide syntax highlighting
// https://highlightjs.org

#import "MKHighlighter.h"
#import "HTMLUtils.h"

@implementation MKHighlighter

- (instancetype)init {
    self = [super init];
    
    if (self) {
        JSContext *jsContext = [[JSContext alloc] init];
        JSValue *window = [JSValue valueWithNewObjectInContext:jsContext];
        [jsContext setObject:window forKeyedSubscript:@"window"];

        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *jsPath = [bundle pathForResource:@"highlight.min" ofType:@"js"];

        NSString *js = [[NSString alloc] initWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:NULL];
        JSValue *value = [jsContext evaluateScript:js];
        if (!value.toBool) {
            return nil;
        }

        self.hljs = window[@"hljs"];

        if (!self.hljs) {
            return nil;
        }
    }
    
    return self;
}

// Sets theme css
- (BOOL)setThemeTo:(NSString *)name {
    NSString *themePath = [[NSBundle bundleForClass:[self class]] pathForResource:[name stringByAppendingString:@".min"] ofType:@"css"];
    if (!themePath) {
        return NO;
    }

    NSString *themeString = [[NSString alloc] initWithContentsOfFile:themePath encoding:NSUTF8StringEncoding error:NULL];
    self.theme = [[MKCodeTheme alloc] initWithThemeString:themeString];

    return YES;
}


// Processes plain code string into html string
- (NSAttributedString *)highlight:(NSString *)code as:(NSString *)languageName {
    JSValue *ret;
    if (languageName) {
        ret = [self.hljs invokeMethod:@"highlight" withArguments:@[languageName, code, /*@(self.ignoreIllegals)*/ @YES]];
    } else { // auto detect language
        ret = [self.hljs invokeMethod:@"highlightAuto" withArguments:@[code]];
    }

    JSValue *res = ret[@"value"];
    NSString *string = res.toString;
    if (!string) {
        return nil;
    }

    return [self processHTMLString:string];
}

// Transforms html string into attributed string
- (NSAttributedString *)processHTMLString:(NSString *)string {
    NSString *spanStart = @"span class=\"";
    NSString *spanStartClose = @"\">";
    NSString *spanEnd = @"/span>";
    
    NSScanner *scanner = [NSScanner scannerWithString:string];
    scanner.charactersToBeSkipped = nil;
    NSString *scannedString;
    NSMutableAttributedString *resultString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSMutableArray *propStack = [NSMutableArray arrayWithObject:@"hljs"];

    while (!scanner.isAtEnd) {
        BOOL ended = NO;

        if ([scanner scanUpToString:@"<" intoString:&scannedString]) {
            if (scanner.isAtEnd) {
                ended = YES;
            }
        }

        if (scannedString && scannedString.length > 0) {
            NSAttributedString *attrScannedString = [self.theme applyStyleToString:scannedString styleList:propStack];
            [resultString appendAttributedString:attrScannedString];
            if (ended) {
                continue;
            }
        }

        scanner.scanLocation += 1;

        NSString *string = scanner.string;
        NSString *nextChar = [string substringWithRange:NSMakeRange(scanner.scanLocation, 1)];
        if ([nextChar isEqualToString:@"s"]) {
            scanner.scanLocation += spanStart.length;
            [scanner scanUpToString:spanStartClose intoString:&scannedString];
            scanner.scanLocation += spanStartClose.length;
            [propStack addObject:scannedString];
        } else if ([nextChar isEqualToString:@"/"]) {
            scanner.scanLocation += spanEnd.length;
            [propStack removeLastObject];
        } else {
            NSAttributedString *attrScannedString = [self.theme applyStyleToString:@"<" styleList:propStack];
            [resultString appendAttributedString:attrScannedString];
            scanner.scanLocation += 1;
        }

        scannedString = nil;
    }
    
    
    NSArray<NSTextCheckingResult *> *results = [[NSRegularExpression regularExpressionWithPattern:@"&#?[a-zA-Z0-9]+?;" options:NSRegularExpressionCaseInsensitive error:NULL] matchesInString:resultString.string options:NSMatchingReportCompletion range:NSMakeRange(0, resultString.length)];

    NSInteger locOffset = 0;
    for (NSTextCheckingResult *result in results) {
        NSRange fixedRange = NSMakeRange(result.range.location-locOffset, result.range.length);
        NSString *entity = [resultString.string substringWithRange:fixedRange];
        NSString *decodedEntity = [HTMLUtils decode:entity];
        if (decodedEntity) {
            [resultString replaceCharactersInRange:fixedRange withString:decodedEntity];
            locOffset += result.range.length-1;
        }
    }

    return resultString;
}

@end
