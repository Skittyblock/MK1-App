// MKManager.h

#import <Foundation/Foundation.h>
#import "MKScript.h"

@interface MKManager : NSObject

+ (instancetype)sharedInstance;
- (BOOL)isSimulator;

- (void)sendMessage:(NSString *)message withInfo:(NSDictionary *)info;

// Listing Scripts
- (NSString *)scriptsDirectory;
- (NSArray<MKScript *> *)scripts;
- (NSDictionary *)scriptsDatabase;

// Managing scripts
- (void)createScriptWithName:(NSString *)name author:(NSString *)author;
- (void)deleteScript:(MKScript *)script;
- (void)setName:(NSString *)name forScript:(MKScript *)script;
- (void)setAuthor:(NSString *)author forScript:(MKScript *)script;

// Triggers
- (NSArray<NSString *> *)triggerList;
- (NSArray<NSString *> *)triggersForScript:(MKScript *)script;
- (void)addTrigger:(NSString *)trigger forScript:(MKScript *)script;
- (void)removeTrigger:(NSString *)trigger forScript:(MKScript *)script;

@end
