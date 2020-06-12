//
//  HTMLUtils.h
//  Copyright © 2018年 vvveiii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLUtils : NSObject

@property(class,nonatomic,strong,readonly) NSDictionary<NSString*,NSString*> *characterEntities;

+ (NSString *)decode:(NSString *)entity;

@end
