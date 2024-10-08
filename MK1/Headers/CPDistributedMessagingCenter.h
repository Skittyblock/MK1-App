/**
 * This header is generated by class-dump-z 0.1-11s.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/AppSupport.framework/AppSupport
 */

#include <SystemConfiguration/SystemConfiguration.h>
#include <mach/message.h>
#include <CoreFoundation/CoreFoundation.h>

typedef audit_token_t XXStruct_kUSYWB;

/*
typedef struct {
    unsigned _field1[8];
} XXStruct_kUSYWB;
 
 [0] -> audit user ID
 [1] -> effective user ID
 [2] -> effective group ID
 [3] -> real user ID
 [4] -> real group ID
[5] -> process ID
 [6] -> task or sender's audit session ID
 [7] -> task or sender's terminal ID
 
 */

#if __cplusplus
extern "C" {
#endif
    
CFStringRef CPSystemRootDirectory(void);    // "/"
CFStringRef CPMailComposeControllerAutosavePath(void);    // ~/Library/Mail/OrphanedDraft-com.yourcompany.appName
bool CPMailComposeControllerHasAutosavedMessage(void);
CFStringRef CPCopyBundleIdentifierFromAuditToken(audit_token_t* token, bool* unknown);
CFStringRef CPSharedResourcesDirectory(void);    // "/var/mobile", or value of envvar IPHONE_SHARED_RESOURCES_DIRECTORY
bool CPCanSendMMS(void);
CFStringRef CPCopySharedResourcesPreferencesDomainForDomain(CFStringRef domain);    // /var/mobile/Library/Preferences/domain
CFStringRef CPGetDeviceRegionCode(void);
bool CPCanSendMail(void);

#if __cplusplus
}
#endif


//#import "AppSupport-Structs.h"
#import <Foundation/NSObject.h>

@class NSLock, NSMutableDictionary, NSOperationQueue, NSString, NSDictionary, NSError;

@interface CPDistributedMessagingCenter : NSObject {
    NSString* _centerName;
    NSLock* _lock;
    unsigned _sendPort;
    CFMachPortRef _invalidationPort;
    NSOperationQueue* _asyncQueue;
    CFRunLoopSourceRef _serverSource;
    NSString* _requiredEntitlement;
    NSMutableDictionary* _callouts;
}
+(CPDistributedMessagingCenter*)centerNamed:(NSString*)serverName;
-(id)_initWithServerName:(NSString*)serverName;
// inherited: -(void)dealloc;
-(NSString*)name;
-(unsigned)_sendPort;
-(void)_serverPortInvalidated;
-(BOOL)sendMessageName:(NSString*)name userInfo:(NSDictionary*)info;
-(NSDictionary*)sendMessageAndReceiveReplyName:(NSString*)name userInfo:(NSDictionary*)info;
-(NSDictionary*)sendMessageAndReceiveReplyName:(NSString*)name userInfo:(NSDictionary*)info error:(NSError**)error;
-(void)sendMessageAndReceiveReplyName:(NSString*)name userInfo:(NSDictionary*)info toTarget:(id)target selector:(SEL)selector context:(void*)context;
-(BOOL)_sendMessage:(id)message userInfo:(id)info receiveReply:(id*)reply error:(id*)error toTarget:(id)target selector:(SEL)selector context:(void*)context;
-(BOOL)_sendMessage:(id)message userInfoData:(id)data oolKey:(id)key oolData:(id)data4 receiveReply:(id*)reply error:(id*)error;
-(void)runServerOnCurrentThread;
-(void)runServerOnCurrentThreadProtectedByEntitlement:(id)entitlement;
-(void)stopServer;
-(void)registerForMessageName:(NSString*)messageName target:(id)target selector:(SEL)selector;
-(void)unregisterForMessageName:(NSString*)messageName;
-(void)_dispatchMessageNamed:(id)named userInfo:(id)info reply:(id*)reply auditToken:(XXStruct_kUSYWB*)token;
-(BOOL)_isTaskEntitled:(XXStruct_kUSYWB*)entitled;
-(id)_requiredEntitlement;
@end
