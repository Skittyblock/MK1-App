// MKManager.m

#import "MKManager.h"
#import "CPDistributedMessagingCenter.h"
#import <rocketbootstrap/rocketbootstrap.h>

@implementation MKManager

+ (instancetype)sharedInstance {
    static MKManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MKManager alloc] init];
    });
    return sharedInstance;
}

// Returns true if app is running in the simulator
- (BOOL)isSimulator {
#if TARGET_OS_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

// Sends a message to the MK1 tweak (excluding simulator)
- (void)sendMessage:(NSString *)message withInfo:(NSDictionary *)info {
#if !TARGET_OS_SIMULATOR
    static CPDistributedMessagingCenter *c = nil;
    c = [CPDistributedMessagingCenter centerNamed:@"xyz.skitty.mk1"];
    rocketbootstrap_distributedmessagingcenter_apply(c);
    [c sendMessageName:message userInfo:info];
#endif
}

// List of MK1 triggers
- (NSArray<NSString *> *)triggerList {
    return @[
        @"HWBUTTON-VOLUP",
        @"HWBUTTON-VOLDOWN",
        @"HWBUTTON-VOLUP+VOLDOWN",
        @"HWBUTTON-POWER",
        @"HWBUTTON-HOME",
        @"HWBUTTON-HOME+VOLUP",
        @"HWBUTTON-HOME+VOLDOWN",
        @"HWBUTTON-HOME+POWER",
        @"HWBUTTON-RINGERTOGGLE",
        @"HWBUTTON-TOUCHID",

        @"STATUSBAR-SINGLETAP",
        @"STATUSBAR-DOUBLETAP",
        @"STATUSBAR-LONGPRESS",
        @"STATUSBAR-SWIPELEFT",
        @"STATUSBAR-SWIPERIGHT",

        @"BATTERY-STATECHANGE",
        @"BATTERY-LEVELCHANGE",
        @"BATTERY-LEVEL20",
        @"BATTERY-LEVEL50",

        @"WIFI-ENABLED",
        @"WIFI-DISABLED",
        @"WIFI-NETWORKCHANGE",

        @"BLUETOOTH-CONNECTEDCHANGE",

        @"VPN-CONNECTED",
        @"VPN-DISCONNECTED",

        @"APPLICATION-LAUNCH",

        @"DEVICE-DARKMODETOGGLE",
        @"DEVICE-SHAKE",
        @"DEVICE-LOCK",
        @"DEVICE-UNLOCK",

        @"MEDIA-NOWPLAYINGCHANGE",

        @"VOLUME-MEDIACHANGE",
        @"VOLUME-RINGERCHANGE",

        @"CONTROLCENTER-MODULE", // TODO: check if CC toggle package is installed

        @"NOTIFICATION-RECEIVE",
    ];
}

// Path to directory holding scripts
- (NSString *)scriptsDirectory {
    if ([[MKManager sharedInstance] isSimulator]) {
        NSString *path = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject].path stringByAppendingPathComponent:@"Scripts"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        return path;
    }
    return @"/Library/MK1/Scripts";
}

// Get a list of scripts in scriptsDirectory, sorted by last modified
- (NSArray<MKScript *> *)scripts {
    NSMutableArray<MKScript *> *scripts = [NSMutableArray array];
    NSMutableArray *dates = [NSMutableArray array];
    
    // List scripts
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[MKManager sharedInstance] scriptsDirectory] error:nil];
    for (NSString *name in contents) {
        NSString *path = [[[MKManager sharedInstance] scriptsDirectory] stringByAppendingPathComponent:name];
        BOOL isDirectory = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
        if ([path.pathExtension isEqualToString:@"js"] || isDirectory) {
            MKScript *script = [[MKScript alloc] initWithPath:path];
            
            if (script) {
                NSDictionary *properties = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
                NSDate *modDate = [properties objectForKey:NSFileModificationDate];
                [dates addObject:[NSDictionary dictionaryWithObjectsAndKeys:script, @"script", modDate, @"lastModDate", nil]];
            }
        }
    }
    
    // Sort by last modified date
    NSArray<NSDictionary *> *sortedScripts = [dates sortedArrayUsingComparator:^(id script1, id script2) {
        return [[script2 objectForKey:@"lastModDate"] compare:[script1 objectForKey:@"lastModDate"]];
    }];
    
    for (NSDictionary *dict in sortedScripts) {
        [scripts addObject:dict[@"script"]];
    }
    
    return [scripts copy];
}

// Script database (scripts.plist), which stores script triggers
- (NSDictionary *)scriptsDatabase {
    NSString *path = [[[self scriptsDirectory] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"scripts.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (MKScript *script in [self scripts]) {
            dict[script.name] = @{};
        }
        [dict writeToFile:path atomically:YES];
    }
    return [NSDictionary dictionaryWithContentsOfFile:path];
}

// Create a new script with specified name
- (void)createScriptWithName:(NSString *)name author:(NSString *)author {
    NSString *path = [[self scriptsDirectory] stringByAppendingPathComponent:name];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        // Create folder
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        // index.js
        [[NSFileManager defaultManager] createFileAtPath:[path stringByAppendingPathComponent:@"index.js"] contents:nil attributes:nil];
        // Script.plist
//        NSArray *shapes = @[@"circle", @"square", @"triangle"];
//        NSDictionary *initialInfo = @{@"shape": shapes[arc4random_uniform(3)]};
        NSDictionary *initialInfo = @{@"author": author};
        [initialInfo writeToFile:[path stringByAppendingPathComponent:@"Script.plist"] atomically:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"xyz.skitty.mk1.refreshscripts" object:nil];
    }
}

// Delete script with name
- (void)deleteScript:(MKScript *)script {
    NSString *path = script.path;
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"xyz.skitty.mk1.refreshscripts" object:nil];
}

// Rename script
- (void)setName:(NSString *)name forScript:(MKScript *)script {
    if (!script.legacyFormat) {
        NSString *oldPath = script.path;
        NSString *newPath = [[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:name];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:newPath withIntermediateDirectories:NO attributes:nil error:nil];

        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:oldPath error:nil];

        for (NSString *file in contents) {
            NSString *oldFilePath = [oldPath stringByAppendingPathComponent:file];
            NSString *newFilePath = [newPath stringByAppendingPathComponent:file];

            [[NSFileManager defaultManager] moveItemAtPath:oldFilePath toPath:newFilePath error:nil];
        }
        
        [[NSFileManager defaultManager] removeItemAtPath:oldPath error:nil];
    } else {
        NSString *oldPath = script.path;
        NSString *newPath = [[[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"js"];
        [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:nil];
    }
    
    if ([[[self scriptsDatabase] allKeys] containsObject:script.name]) {
        NSMutableDictionary *newDatabase = [[self scriptsDatabase] mutableCopy];
        newDatabase[name] = newDatabase[script.name];
        [newDatabase removeObjectForKey:script.name];
        [newDatabase writeToFile:[[[self scriptsDirectory] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"scripts.plist"] atomically:YES];
    }
}

// Set author
- (void)setAuthor:(NSString *)author forScript:(MKScript *)script {
    if (!script.legacyFormat) {
        NSMutableDictionary *newInfo = [script.info mutableCopy];
        newInfo[@"author"] = author;
        [newInfo writeToFile:[script.path stringByAppendingPathComponent:@"Script.plist"] atomically:YES];
    }
}

// Trigger list for script
- (NSArray<NSString *> *)triggersForScript:(MKScript *)script {
    NSMutableDictionary *scriptDatabase = [[self scriptsDatabase] mutableCopy];
    if ([scriptDatabase objectForKey:script.name]) {
        return scriptDatabase[script.name][@"triggers"] ?: @[];
    }
    return @[];
}

// Add a trigger for a script
- (void)addTrigger:(NSString *)trigger forScript:(MKScript *)script {
    // Get script database
    NSMutableDictionary *scriptDatabase = [[self scriptsDatabase] mutableCopy];
    scriptDatabase[script.name] = [scriptDatabase[script] mutableCopy];
    
    if (!scriptDatabase[script.name]) {
        scriptDatabase[script.name] = [NSMutableDictionary dictionary];
    }
    
    // Make triggers a mutable array
    if (![scriptDatabase[script.name][@"triggers"] isKindOfClass:[NSArray class]]) {
        scriptDatabase[script.name][@"triggers"] = [NSMutableArray array];
    } else {
        // Check if trigger already exists
        if ([scriptDatabase[script.name][@"triggers"] containsObject:trigger]) {
            return;
        }
        scriptDatabase[script.name][@"triggers"] = [scriptDatabase[script][@"triggers"] mutableCopy];
    }
    
    // Add trigger
    [scriptDatabase[script.name][@"triggers"] addObject:trigger];
    
    // Write updated file
    NSString *path = [[[self scriptsDirectory] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"scripts.plist"];
    [scriptDatabase writeToFile:path atomically:YES];
}

- (void)removeTrigger:(NSString *)trigger forScript:(MKScript *)script {
    // Get script database
    NSMutableDictionary *scriptDatabase = [[self scriptsDatabase] mutableCopy];
    scriptDatabase[script.name] = [scriptDatabase[script.name] mutableCopy];
    
    // Make triggers a mutable array
    if (![scriptDatabase[script.name][@"triggers"] isKindOfClass:[NSArray class]]) {
        return;
    } else {
        scriptDatabase[script.name][@"triggers"] = [scriptDatabase[script.name][@"triggers"] mutableCopy];
        [scriptDatabase[script.name][@"triggers"] removeObject:trigger];
    }
    
    // Write updated file
    NSString *path = [[[self scriptsDirectory] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"scripts.plist"];
    [scriptDatabase writeToFile:path atomically:YES];
}

@end
