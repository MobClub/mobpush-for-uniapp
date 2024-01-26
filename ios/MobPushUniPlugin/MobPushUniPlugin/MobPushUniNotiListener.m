//
//  MobPushUniNotiListener.m
//  MobPushUniPlugin
//
//  Created by MobTech-iOS on 2022/11/17.
//

#import "MobPushUniNotiListener.h"

@implementation MobPushUniNotiListener

- (instancetype)initWithListener:(UniModuleKeepAliveCallback)listener {
    self = [super init];
    
    if (self) {
        _uniCallBackBlock = listener;
    }
    
    return self;
}

@end
