// MKCodeTheme.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSString *> *> MKStrippedThemeDictionary;
typedef NSMutableDictionary<NSString *, NSMutableDictionary<NSAttributedStringKey, id> *> MKThemeDictionary;

@interface MKCodeTheme : NSObject

@property (nonatomic, copy) NSString *theme;
@property (nonatomic, strong) UIColor *themeBackgroundColor;
@property (nonatomic, strong) UIFont *codeFont;
@property (nonatomic, strong) UIFont *boldCodeFont;
@property (nonatomic, strong) UIFont *italicCodeFont;

@property (nonatomic, strong) MKStrippedThemeDictionary *strippedTheme;
@property (nonatomic, strong) MKThemeDictionary *themeAttributes;

- (instancetype)initWithThemeString:(NSString *)themeString;
- (NSAttributedString *)applyStyleToString:(NSString *)string styleList:(NSArray<NSString *> *)styleList;

@end
