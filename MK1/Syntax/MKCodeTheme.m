// MKCodeTheme.m

#import "MKCodeTheme.h"

@implementation MKCodeTheme

- (instancetype)initWithThemeString:(NSString *)themeString {
    self = [super init];
    if (self) {
        self.theme = themeString;

        // TODO: Make fonts customizable?
        self.codeFont = [UIFont fontWithName:@"Menlo-Regular" size:14];
        self.boldCodeFont = [UIFont fontWithName:@"Menlo-Bold" size:14];
        self.italicCodeFont = [UIFont fontWithName:@"Menlo-Italic" size:14];
        
        self.strippedTheme = [self stripTheme:themeString];
        self.themeAttributes = [self strippedThemeToAttributeDictionary:self.strippedTheme];
        
        NSString *bgColorHex = self.strippedTheme[@".hljs"][@"background"] ?: self.strippedTheme[@".hljs"][@"background-color"];
        self.themeBackgroundColor = bgColorHex ? [self colorWithHexString:bgColorHex] : [UIColor whiteColor];
    }

    return self;
}

// Applies css style classes to string
- (NSAttributedString *)applyStyleToString:(NSString *)string styleList:(NSArray<NSString *> *)styleList {
    NSMutableDictionary<NSAttributedStringKey, id> *attributes = [NSMutableDictionary dictionary];
    
    // Set font
    attributes[NSFontAttributeName] = self.codeFont;
    
    // Apply other styles (e.g. hljs-keyword, hljs-comment, etc.)
    if (styleList.count > 0) {
        for (NSString *style in styleList) {
            NSMutableDictionary *themeStyle = self.themeAttributes[style];
            if (themeStyle) {
                [themeStyle enumerateKeysAndObjectsUsingBlock:^(NSAttributedStringKey attrName, id attrValue, BOOL *stop) {
                    attributes[attrName] = attrValue;
                }];
            }
        }
    }

    return [[NSAttributedString alloc] initWithString:string attributes:attributes];
}

// Parses theme css into dictionary
- (MKStrippedThemeDictionary *)stripTheme:(NSString *)themeString {
    // Regex to match _minified_ css (no spaces)
    NSRegularExpression *cssRegex = [NSRegularExpression regularExpressionWithPattern:@"(?:(\\.[a-zA-Z0-9\\-_]*(?:[, ]\\.[a-zA-Z0-9\\-_]*)*)\\{([^\\}]*?)\\})" options:NSRegularExpressionCaseInsensitive error:NULL];

    NSArray<NSTextCheckingResult *> *results = [cssRegex matchesInString:themeString options:NSMatchingReportCompletion range:NSMakeRange(0, themeString.length)];

    NSMutableDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *resultDict = [NSMutableDictionary dictionary];

    // Parse css styles directly into dictionary
    for (NSTextCheckingResult *result in results) {
        if (result.numberOfRanges == 3) {
            NSMutableDictionary<NSString *, NSString *> *attributes = [NSMutableDictionary dictionary];
            NSArray<NSString *> *cssPairs = [[themeString substringWithRange:[result rangeAtIndex:2]] componentsSeparatedByString:@";"];

            for (NSString *pair in cssPairs) {
                NSArray<NSString *> *cssPropComp = [pair componentsSeparatedByString:@":"];
                if (cssPropComp.count == 2) {
                    attributes[cssPropComp[0]] = cssPropComp[1];
                }
            }

            if (attributes.count > 0) {
                resultDict[[themeString substringWithRange:[result rangeAtIndex:1]]] = attributes;
            }
        }
    }
    
    // Sort css styles into individual keys
    MKStrippedThemeDictionary *returnDict = [MKStrippedThemeDictionary dictionary];

    [resultDict enumerateKeysAndObjectsUsingBlock:^(NSString *keys, NSDictionary<NSString *, NSString *> *result, BOOL *stop) {
        NSArray<NSString *> *keyArray = [[keys stringByReplacingOccurrencesOfString:@" " withString:@","] componentsSeparatedByString:@","];

        for (NSString *key in keyArray) {
            NSMutableDictionary<NSString *, NSString *> *properties = returnDict[key] ?: [NSMutableDictionary dictionary];

            [result enumerateKeysAndObjectsUsingBlock:^(NSString *pName, NSString *pValue, BOOL *stop) {
                properties[pName] = pValue;
            }];

            returnDict[key] = properties;
        }
    }];
    
    return returnDict;
}

// Parses stripped theme dictionary into attribute dictionary
- (MKThemeDictionary *)strippedThemeToAttributeDictionary:(MKStrippedThemeDictionary *)theme {
    MKThemeDictionary *returnTheme = [MKThemeDictionary dictionary];

    [theme enumerateKeysAndObjectsUsingBlock:^(NSString *className, NSMutableDictionary<NSString *,NSString *> *props, BOOL *stop) {
        NSMutableDictionary<NSAttributedStringKey,id> *keyProps = [NSMutableDictionary dictionary];

        [props enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *prop, BOOL *stop) {
            if ([key isEqualToString:@"color"]) {
                keyProps[NSForegroundColorAttributeName] = [self colorWithHexString:prop];
            } else if ([key isEqualToString:@"background-color"]) {
                keyProps[NSBackgroundColorAttributeName] = [self colorWithHexString:prop];
            } else if ([key isEqualToString:@"font-style"]) {
                keyProps[NSFontAttributeName] = [self fontForCSSStyle:prop];
            } else if ([key isEqualToString:@"font-weight"]) {
                keyProps[NSFontAttributeName] = [self fontForCSSStyle:prop];
            }
        }];

        if (keyProps.count > 0) {
            NSString *key = [className stringByReplacingOccurrencesOfString:@"." withString:@""];
            returnTheme[key] = keyProps;
        }
    }];

    return returnTheme;
}

// Determines which font to use for css style
- (UIFont *)fontForCSSStyle:(NSString *)fontStyle {
    if ([fontStyle isEqualToString:@"bold"] ||
        [fontStyle isEqualToString:@"bolder"] ||
        [fontStyle isEqualToString:@"600"] ||
        [fontStyle isEqualToString:@"700"] ||
        [fontStyle isEqualToString:@"800"] ||
        [fontStyle isEqualToString:@"900"]) {
        return self.boldCodeFont;
    } else if ([fontStyle isEqualToString:@"italic"] || [fontStyle isEqualToString:@"oblique"]) {
        return self.italicCodeFont;
    }
    return self.codeFont;
}

// Converts css hex colors (#FF0000) to UIColors
- (UIColor *)colorWithHexString:(NSString *)hex {
    NSString *cString = [hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([cString hasPrefix:@"#"]) { // hex string
        cString = [cString substringFromIndex:1];
    } else { // named color
        if ([cString isEqualToString:@"white"]) {
            return [UIColor whiteColor];
        } else if ([cString isEqualToString:@"black"]) {
            return [UIColor blackColor];
        } else if ([cString isEqualToString:@"red"]) {
            return [UIColor redColor];
        } else if ([cString isEqualToString:@"green"]) {
            return [UIColor greenColor];
        } else if ([cString isEqualToString:@"blue"]) {
            return [UIColor blueColor];
        }
        return [UIColor grayColor];
    }

    unsigned r = 0, g = 0, b = 0;
    NSString *rString, *gString, *bString;
    CGFloat divisor;

    if (cString.length == 6) {
        rString = [cString substringToIndex:2]; // #XX0000
        gString = [cString substringWithRange:NSMakeRange(2, 2)]; // #00XX00
        bString = [cString substringWithRange:NSMakeRange(4, 2)]; // #0000XX
        divisor = 255.0;
    } else if (cString.length == 3) {
        rString = [cString substringToIndex:1]; // #X00
        gString = [cString substringWithRange:NSMakeRange(1, 1)]; // #0X0
        bString = [cString substringWithRange:NSMakeRange(2, 1)]; // #00X
        divisor = 15.0;
    } else {
        return [UIColor grayColor];
    }

    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];

    return [UIColor colorWithRed:(CGFloat)r/divisor green:(CGFloat)g/divisor blue:(CGFloat)b/divisor alpha:1];
}

@end
