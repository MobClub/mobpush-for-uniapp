//
//  MobPushUniPlugin.m
//  MobPushUniPlugin
//
//  Created by MobTech-iOS on 2022/11/17.
//

#import "MobPushUniPlugin.h"
#import "MobPushUniNotiListener.h"

#import <MobPush/MobPush.h>
#import <MobPush/MobPush+Test.h>
#import <MOBFoundation/MOBFoundation.h>

static BOOL isDebug = NO;
#define MobPushDebugLog(info, ...) if (isDebug) { NSLog((@"\n********** MobPush Debug **********\n" info "\n********** MobPush Debug **********\n"), ##__VA_ARGS__); }
static BOOL HasAddedObserver = NO;

@interface NSString (Utils)

- (BOOL)isEmpty;

@end

@interface MobPushUniPlugin ()

@property (nonatomic, strong) NSMutableArray *listeners;
@property (nonatomic, strong) dispatch_queue_t listenerWRQueue;

@end

@implementation MobPushUniPlugin

UNI_EXPORT_METHOD(@selector(enableLog:))
- (void)enableLog:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return;
    if (![dict objectForKey:@"enableLog"]) return;
    id enableLog = [dict objectForKey:@"enableLog"];
    if ([enableLog respondsToSelector:@selector(boolValue)]) {
        isDebug = [enableLog boolValue];
        MobPushDebugLog(@"%s Result: %d", __func__, isDebug);
    }
}

UNI_EXPORT_METHOD(@selector(submitPolicyGrantResult:))
- (void)submitPolicyGrantResult:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return;
    if (![dict objectForKey:@"grant"]) return;
    id grant = [dict objectForKey:@"grant"];
    if ([grant respondsToSelector:@selector(boolValue)]) {
        [MobSDK uploadPrivacyPermissionStatus:[grant boolValue] onResult:^(BOOL success) {
            MobPushDebugLog(@"%s: %d", __func__, success);
        }];
    }
}

UNI_EXPORT_METHOD(@selector(setAPNsForProduction:))
- (void)setAPNsForProduction:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return;
    if (![dict objectForKey:@"isPro"]) return;
    id isPro = [dict objectForKey:@"isPro"];
    if ([isPro respondsToSelector:@selector(boolValue)]) {
        [MobPush setAPNsForProduction:[isPro boolValue]];
        MobPushDebugLog(@"%s, isPro: %d", __func__, [isPro boolValue]);
    }
}

UNI_EXPORT_METHOD(@selector(setAPNsShowForegroundType:))
- (void)setAPNsShowForegroundType:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return;
    if (![dict objectForKey:@"type"]) return;
    id type = [dict objectForKey:@"type"];
    if ([type respondsToSelector:@selector(intValue)]) {
        [MobPush setAPNsShowForegroundType:[type intValue]];
        MobPushDebugLog(@"%s, Type: %d", __func__, [type intValue]);
    }
}

UNI_EXPORT_METHOD(@selector(setAPNsNotification:))
- (void)setAPNsNotification:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return;
    if (![dict objectForKey:@"type"]) return;
    id type = [dict objectForKey:@"type"];
    if ([type respondsToSelector:@selector(intValue)]) {
        MPushNotificationConfiguration *configuration = [[MPushNotificationConfiguration alloc] init];
        configuration.types = [type intValue];
        [MobPush setupNotification:configuration];
        MobPushDebugLog(@"%s, Type: %d", __func__, [type intValue]);
    }
}

UNI_EXPORT_METHOD(@selector(getRegistrationID:))
- (void)getRegistrationID:(UniModuleKeepAliveCallback)callback {
    __weak typeof(self) weakSelf = self;
    [MobPush getRegistrationID:^(NSString *regID, NSError *error) {
        MobPushDebugLog(@"%s: %@, Err: %@", __func__, regID, error);
        NSDictionary *result = [weakSelf formatReturnDict:regID err:error];
        if (callback) callback(result, NO);
    }];
}

UNI_EXPORT_METHOD(@selector(addPushReceiver:))
- (void)addPushReceiver:(UniModuleKeepAliveCallback)callback {
    if (![self listeners]) {
        self.listeners = [NSMutableArray array];
    }
    
    if (self.listenerWRQueue == NULL) {
        self.listenerWRQueue = dispatch_queue_create("com.mob.mobpush.wr", DISPATCH_QUEUE_CONCURRENT);
    }
    
    [self addMessageObserver];
    
    MobPushUniNotiListener *listener = [[MobPushUniNotiListener alloc] initWithListener:callback];
    [self addListenersWith:listener];
}

UNI_EXPORT_METHOD(@selector(clearPushReceivers))
- (void)clearPushReceivers {
    [self clearListeners];
    
    MobPushDebugLog(@"Clear Listeners Success");
}

UNI_EXPORT_METHOD(@selector(isPushStopped:))
- (void)isPushStopped:(UniModuleKeepAliveCallback)callback {
    NSDictionary *ret = [self formatReturnDict:@([MobPush isPushStopped])
                                           err:nil];
    if (callback) callback(ret, NO);
}

UNI_EXPORT_METHOD(@selector(stopPush))
- (void)stopPush {
    [MobPush stopPush];
    
    MobPushDebugLog(@"Current Push Service: %d", [MobPush isPushStopped]);
}

UNI_EXPORT_METHOD(@selector(restartPush))
- (void)restartPush {
    [MobPush restartPush];
    
    MobPushDebugLog(@"Current Push Service: %d", [MobPush isPushStopped]);
}

UNI_EXPORT_METHOD(@selector(setAlias:))
- (void)setAlias:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return;
    if (![dict objectForKey:@"alias"]) return;
    id alias = [dict objectForKey:@"alias"];
    if (![alias isKindOfClass:[NSString class]]
        || [alias isEmpty]) return;
    
    [MobPush setAlias:alias result:^(NSError *error) {
        MobPushDebugLog(@"%s: %@", __func__, error);
    }];
}

UNI_EXPORT_METHOD(@selector(getAlias))
- (void)getAlias {
    __weak typeof(self) weakSelf = self;
    [MobPush getAliasWithResult:^(NSString *alias, NSError *error) {
        MobPushDebugLog(@"%s result: %@, error: %@", __func__, alias, error);
        
        NSDictionary *ret = [weakSelf formatReturnDict:alias err:error];
        NSMutableDictionary *m_ret = [NSMutableDictionary dictionaryWithDictionary:ret];
        [m_ret setObject:@"onAliasCallback" forKey:@"action"];
        
        [weakSelf postNotiToObserver:m_ret];
    }];
}

UNI_EXPORT_METHOD(@selector(deleteAlias))
- (void)deleteAlias {
    [MobPush deleteAlias:^(NSError *error) {
        MobPushDebugLog(@"%s: %@", __func__, error);
    }];
}

UNI_EXPORT_METHOD(@selector(addTags:))
- (void)addTags:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return;
    if (![dict objectForKey:@"tags"]) return;
    id tmp_tags = [dict objectForKey:@"tags"];
    if (![tmp_tags isKindOfClass:[NSArray class]]) return;
    
    NSArray *tags = (NSArray *)tmp_tags;
    [MobPush addTags:tags result:^(NSError *error) {
        MobPushDebugLog(@"%s: %@", __func__, error);
    }];
}

UNI_EXPORT_METHOD(@selector(getTags))
- (void)getTags {
    __weak typeof(self) weakSelf = self;
    [MobPush getTagsWithResult:^(NSArray *tags, NSError *error) {
        MobPushDebugLog(@"%s result:%@, error:%@", __func__, [tags componentsJoinedByString:@";"], error);
        
        NSDictionary *ret = [weakSelf formatReturnDict:tags err:error];
        NSMutableDictionary *m_dict = [NSMutableDictionary dictionaryWithDictionary:ret];
        [m_dict setObject:@"onTagsCallback" forKey:@"action"];
        
        [weakSelf postNotiToObserver:m_dict];
    }];
}

UNI_EXPORT_METHOD(@selector(deleteTags:))
- (void)deleteTags:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return;
    if (![dict objectForKey:@"tags"]) return;
    id tmp_tags = [dict objectForKey:@"tags"];
    if (![tmp_tags isKindOfClass:[NSArray class]]) return;
    
    NSArray *tags = (NSArray *)tmp_tags;
    [MobPush deleteTags:tags result:^(NSError *error) {
        MobPushDebugLog(@"%s: %@", __func__, error);
    }];
}

UNI_EXPORT_METHOD(@selector(cleanAllTags))
- (void)cleanAllTags {
    [MobPush cleanAllTags:^(NSError *error) {
        MobPushDebugLog(@"%s: %@", __func__, error);
    }];
}

UNI_EXPORT_METHOD(@selector(setBadge:))
- (void)setBadge:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) return;
    if (![dict objectForKey:@"badge"]) return;
    id badge = [dict objectForKey:@"badge"];
    if ([badge respondsToSelector:@selector(integerValue)]) {
        NSInteger value = [badge integerValue];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:value];
        [MobPush setBadge:value];
        MobPushDebugLog(@"%s Badge: %ld", __func__, (long)value);
    }
}

UNI_EXPORT_METHOD(@selector(getBadge:))
- (void)getBadge:(UniModuleKeepAliveCallback)callback {
    __weak typeof(self) weakSelf = self;
    [MobPush getBadgeWithhandler:^(NSInteger badge, NSError *error) {
        MobPushDebugLog(@"%s Badge: %ld Error: %@", __func__, (long)badge, error);
        
        NSDictionary *ret = [weakSelf formatReturnDict:@(badge)
                                                   err:error];
        if (callback) callback(ret, NO);
    }];
}

UNI_EXPORT_METHOD(@selector(clearBadge))
- (void)clearBadge {
    [MobPush clearBadge];
    MobPushDebugLog(@"%s", __func__);
}

- (void)dealloc {
    HasAddedObserver = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark ----
#pragma mark Private Methods
- (NSDictionary *)formatReturnDict:(id)content err:(NSError *)error {
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    
    BOOL success = error ? NO : YES;
    id err = error ? : [NSNull null];
    id res = content ? : [NSNull null];
    if ([res isKindOfClass:[NSDictionary class]]) {
        res = [MOBFJson jsonStringFromObject:res];
    }
    
    [mDict setObject:res forKey:@"res"];
    [mDict setObject:err forKey:@"error"];
    [mDict setObject:@(success) forKey:@"success"];
    
    return [mDict copy];
}

- (void)addListenersWith:(MobPushUniNotiListener *)listener {
    if (!listener) return;
    
    __weak typeof(self) weakSelf = self;
    dispatch_barrier_sync(self.listenerWRQueue, ^{
        [[weakSelf listeners] addObject:listener];
    });
}

- (void)clearListeners {
    if (!self.listeners || ![[self listeners] count]) return;
    
    __weak typeof(self) weakSelf = self;
    dispatch_barrier_sync(self.listenerWRQueue, ^{
        [[weakSelf listeners] removeAllObjects];
    });
}

- (NSArray *)getListeners {
    __block NSArray *arr = nil;
    
    __weak typeof(self) weakSelf = self;
    dispatch_sync(self.listenerWRQueue, ^{
        arr = [NSArray arrayWithArray:[weakSelf listeners]];
    });
    
    return arr;
}

- (void)addMessageObserver {
    if (HasAddedObserver) return;
    HasAddedObserver = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notiCallBack:)
                                                 name:MobPushDidReceiveMessageNotification
                                               object:nil];
}

- (void)notiCallBack:(NSNotification *)noti {
    if (![[noti object] isKindOfClass:[MPushMessage class]]) return;
    
    MPushMessage *message = [noti object];
    NSString *eventName = @"";
    NSMutableDictionary *content = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    
    switch ([message messageType]) {
        case MPushMessageTypeCustom: {
            eventName = @"onCustomMessageReceive";
        }
            break;
        case MPushMessageTypeAPNs: {
            eventName = @"onNotifyMessageReceive";
        }
            break;
        case MPushMessageTypeLocal: {
            eventName = @"onLocalMessageReceive";
        }
            break;
        case MPushMessageTypeClicked: {
            eventName = @"onNotifyMessageOpenedReceive";
        }
            break;
        default:
            break;
    }
    
    if (message.notification.userInfo) {
        [content setObject:message.notification.userInfo forKey:@"extrasMap"];
    }
    if (message.notification.body) {
        [content setObject:message.notification.body forKey:@"content"];
    }
    if (message.messageID) {
        [content setObject:message.messageID forKey:@"messageId"];
    }
    [content addEntriesFromDictionary:message.notification.convertDictionary];
    
    if ([content count]) {
        [resultDict setObject:content forKey:@"result"];
    }
    NSString *result_json_str = [MOBFJson jsonStringFromObject:resultDict];
    NSDictionary *ret = @{
        @"success": @(YES),
        @"res": result_json_str,
        @"error": [NSNull null],
        @"action": eventName
    };
    
    [self postNotiToObserver:ret];
}

- (void)postNotiToObserver:(NSDictionary *)ret {
    if (!ret || ![ret isKindOfClass:[NSDictionary class]]) return;
    
    NSArray *tmp_listeners = [self getListeners];
    [tmp_listeners enumerateObjectsUsingBlock:^(MobPushUniNotiListener *obj,
                                                NSUInteger idx,
                                                BOOL * _Nonnull stop) {
        if ([obj uniCallBackBlock]) {
            obj.uniCallBackBlock(ret, YES);
        }
    }];
}

@end

@implementation NSString (Utils)

- (BOOL)isEmpty {
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    NSString *tmp_str = [self stringByTrimmingCharactersInSet:set];
    return ([tmp_str length] ? NO : YES);
}

@end
