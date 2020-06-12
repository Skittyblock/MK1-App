// MKScript.m

#import "MKScript.h"
#import "MKManager.h"

@implementation MKScript

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    
    if (self) {
        self.info = @{};
        self.path = path;
        self.author = @"Unknown";
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:@"Script.plist"]]) {
            self.info = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:@"Script.plist"]];
            self.name = [path lastPathComponent];
            self.author = self.info[@"author"] ?: @"Unknown";
            if (self.info[@"image"]) self.image = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:self.info[@"image"]]];
            //if (self.info[@"shape"]) self.shape = self.info[@"shape"];
        } else if ([[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:@"index.js"]]) {
            self.name = [path lastPathComponent];
        } else if ([path.pathExtension isEqualToString:@"js"] && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
            self.legacyFormat = YES;
            self.name = [[path lastPathComponent] stringByDeletingPathExtension];
        } else {
            return nil;
        }
        
//        if (!self.shape) {
//            NSArray *shapes = @[@"circle", @"square", @"triangle"];
//            self.shape = shapes[arc4random_uniform(3)];
//        }
    }
    
    return self;
}

// Code (index.js)
- (NSString *)codeWithError:(NSError **)error {
    return [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/index.js", self.path] encoding:NSUTF8StringEncoding error:error];
}

- (NSString *)code {
    return [self codeWithError:nil];
}

- (void)setCode:(NSString *)code {
    [code writeToFile:[NSString stringWithFormat:@"%@/index.js", self.path] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
