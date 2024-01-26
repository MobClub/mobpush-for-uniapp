//
//  MobPushUniNotiListener.h
//  MobPushUniPlugin
//
//  Created by MobTech-iOS on 2022/11/17.
//

#import <Foundation/Foundation.h>
#import <DCUniModule.h>

@interface MobPushUniNotiListener : NSObject

@property (nonatomic, copy, readonly) UniModuleKeepAliveCallback uniCallBackBlock;

- (instancetype)initWithListener:(UniModuleKeepAliveCallback)listener;

@end
