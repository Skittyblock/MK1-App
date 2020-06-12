// MKScript.h

#import <UIKit/UIKit.h>

@interface MKScript : NSObject

@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *shape;
@property (nonatomic, assign) BOOL legacyFormat;

- (instancetype)initWithPath:(NSString *)path;
- (NSString *)codeWithError:(NSError **)error;
- (NSString *)code;
- (void)setCode:(NSString *)code;

@end

