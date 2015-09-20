//
//  KJUtils.m
//  Splitter
//
//  Created by Kenji on 20/9/15.
//  Copyright © 2015 Kenji. All rights reserved.
//

#import "KJUtils.h"
#import <ServiceManagement/ServiceManagement.h>

NSString * const kSettingsAutoStartWithSystem   = @"splitter_settings_auto_start_with_system";
NSString * const kSettingsNumberOfCells         = @"splitter_settings_number_of_cell";

@implementation KJUtils

+ (void)setSetting:(id)value forKey:(NSString *)key {
  NSData *data = [NSArchiver archivedDataWithRootObject:value];
  [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)getSettingForKey:(NSString *)key defaultValue:(id)defaultValue {
  id value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
  if (value == nil) {
    value = defaultValue;
  } else {
    value = [NSUnarchiver unarchiveObjectWithData:value];
  }
  return value;
}

+ (BOOL)isLoginItemEnabledForBundle:(NSBundle *)bundle
{
  LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
  NSString *applicationPath = bundle.bundlePath;
  BOOL result = NO;
  
  if (sharedFileList) {
    NSArray *sharedFileListArray = nil;
    UInt32 seedValue;
    
    sharedFileListArray = CFBridgingRelease(LSSharedFileListCopySnapshot(sharedFileList, &seedValue));
    
    for (id sharedFile in sharedFileListArray) {
      LSSharedFileListItemRef sharedFileListItem = (__bridge LSSharedFileListItemRef)sharedFile;
      CFURLRef applicationPathURL = NULL;
      
      LSSharedFileListItemResolve(sharedFileListItem, 0, (CFURLRef *)&applicationPathURL, NULL);
      
      if (applicationPathURL != NULL) {
        NSString *resolvedApplicationPath = [(__bridge NSURL *)applicationPathURL path];
        
        CFRelease(applicationPathURL);
        
        if ([resolvedApplicationPath compare:applicationPath] == NSOrderedSame) {
          result = YES;
          
          break;
        }
      }
    }
    
    CFRelease(sharedFileList);
  } else {
    NSLog(@"Unable to create the shared file list.");
  }
  
  return result;
}

+ (void)enableLoginItemForBundle:(NSBundle *)bundle
{
  LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
  NSString *applicationPath = bundle.bundlePath;
  NSURL *applicationPathURL = [NSURL fileURLWithPath:applicationPath];
  
  if (sharedFileList) {
    LSSharedFileListItemRef sharedFileListItem = LSSharedFileListInsertItemURL(sharedFileList,
                                                                               kLSSharedFileListItemLast,
                                                                               NULL,
                                                                               NULL,
                                                                               (__bridge CFURLRef)applicationPathURL,
                                                                               NULL,
                                                                               NULL);
    
    if (sharedFileListItem) {
      CFRelease(sharedFileListItem);
    }
    
    CFRelease(sharedFileList);
  } else {
    NSLog(@"Unable to create the shared file list.");
  }
}

+ (void)disableLoginItemForBundle:(NSBundle *)bundle
{
  LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
  NSString *applicationPath = bundle.bundlePath;
  
  if (sharedFileList) {
    NSArray *sharedFileListArray = nil;
    UInt32 seedValue;
    
    sharedFileListArray = CFBridgingRelease(LSSharedFileListCopySnapshot(sharedFileList, &seedValue));
    
    for (id sharedFile in sharedFileListArray) {
      LSSharedFileListItemRef sharedFileListItem = (__bridge LSSharedFileListItemRef)sharedFile;
      CFURLRef applicationPathURL;
      
      if (LSSharedFileListItemResolve(sharedFileListItem, 0, &applicationPathURL, NULL) == noErr) {
        NSString *resolvedApplicationPath = [(__bridge NSURL *)applicationPathURL path];
        
        if ([resolvedApplicationPath compare:applicationPath] == NSOrderedSame) {
          LSSharedFileListItemRemove(sharedFileList, sharedFileListItem);
        }
        
        CFRelease(applicationPathURL);
      }
    }
    
    CFRelease(sharedFileList);
  } else {
    NSLog(@"Unable to create the shared file list.");
  }
}

+ (NSColor *)colorFromHexadecimalValue:(NSString *)hex {
  
  if ([hex hasPrefix:@"#"]) {
    hex = [hex substringWithRange:NSMakeRange(1, [hex length] - 1)];
  }
  
  unsigned int colorCode = 0;
  
  if (hex) {
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    (void)[scanner scanHexInt:&colorCode];
  }
  
  return [NSColor colorWithDeviceRed:((colorCode>>16)&0xFF)/255.0 green:((colorCode>>8)&0xFF)/255.0 blue:((colorCode)&0xFF)/255.0 alpha:1.0];
}

@end
