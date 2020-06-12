// MKHighlighter.h

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "MKCodeTheme.h"

@interface MKHighlighter : NSObject

@property (nonatomic, strong) MKCodeTheme *theme;

@property (nonatomic, strong) JSValue *hljs;

- (BOOL)setThemeTo:(NSString *)name;
- (NSAttributedString *)highlight:(NSString *)code as:(NSString *)languageName;

@end
