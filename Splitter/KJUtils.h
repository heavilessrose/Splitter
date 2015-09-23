//
//  KJUtils.h
//  Splitter
//
//  Created by Kenji on 20/9/15.
//  Copyright © 2015 Kenji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

FOUNDATION_EXPORT NSString * const kSettingsAutoStartWithSystem;
FOUNDATION_EXPORT NSString * const kSettingsNumberOfCells;

@interface KJUtils : NSObject

+ (void)setSetting:(id)value forKey:(NSString *)key;
+ (id)getSettingForKey:(NSString *)key defaultValue:(id)defaultValue;

+ (BOOL)isLoginItemEnabledForBundle:(NSBundle *)bundle;
+ (void)enableLoginItemForBundle:(NSBundle *)bundle;
+ (void)disableLoginItemForBundle:(NSBundle *)bundle;

+ (NSColor *)colorFromHexadecimalValue:(NSString *)hex;

@end
