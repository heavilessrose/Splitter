//
//  AppDelegate.m
//  Splitter
//
//  Created by Kenji on 12/9/15.
//  Copyright (c) 2015 Kenji. All rights reserved.
//

#import "AppDelegate.h"
#import <Carbon/Carbon.h>
#import "KJAccessibilityElement.h"

@interface AppDelegate () {
  
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  
  // check accessibility trusted
  NSDictionary *options = @{(__bridge NSString *)kAXTrustedCheckOptionPrompt : @(YES)};
  if (!AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options)) {
    NSLog(@"don't have permission. warn user");
  }
  
  // setup status bar icon
  self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  [self.statusItem setMenu:self.menuStatus];
  [self.statusItem setTitle:@""];
  [self.statusItem setImage:[NSImage imageNamed:@"StatusBarButtonImage"]];
  [self.statusItem setHighlightMode:YES];
  
  [self.menuStatus itemWithTag:1].title = @"Half Left \t⌥⌘←";
  [self.menuStatus itemWithTag:2].title = @"Half Right \t⌥⌘→";
  
  [NSEvent addGlobalMonitorForEventsMatchingMask:(NSKeyDownMask) handler:^(NSEvent *event) {
    if ((event.modifierFlags & NSCommandKeyMask) && (event.modifierFlags & NSAlternateKeyMask)) {
      if (event.keyCode == 0x7B) {
        [self moveWindowToHalfLeft];
      }
      if (event.keyCode == 0x7C) {
        [self moveWindowToHalfRight];
      }
    }
  }];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}

#pragma mark - Menu Status

- (IBAction)menuStatusClicked:(id)sender {
  NSMenuItem *item = (NSMenuItem *)sender;
  if (item.tag == 1) {
    [self moveWindowToHalfLeft];
  } else if (item.tag == 2) {
    [self moveWindowToHalfRight];
  } else if (item.tag == 999) {
    [[NSApplication sharedApplication] terminate:self];
  }
}

#pragma mark - Windows Management

- (void)moveWindowToHalfLeft {
  CGRect screen = [NSScreen mainScreen].frame;
  CGRect leftFrame = CGRectMake(0, 0, screen.size.width/2, screen.size.height);
  [self moveFrontMostWindowToFrame:leftFrame];
}

- (void)moveWindowToHalfRight {
  CGRect screen = [NSScreen mainScreen].frame;
  CGRect rightFrame = CGRectMake(screen.size.width/2, 0, screen.size.width/2, screen.size.height);
  [self moveFrontMostWindowToFrame:rightFrame];
}

- (void)moveFrontMostWindowToFrame:(CGRect)frame {
  KJAccessibilityElement *frontMostWindow = [KJAccessibilityElement frontMostWindowElement];
  if (frontMostWindow) {
    AXValueRef origin = AXValueCreate(kAXValueCGPointType, (const void *)&frame.origin);
    AXValueRef size = AXValueCreate(kAXValueCGSizeType, (const void *)&frame.size);
    [frontMostWindow setValue:origin forAttribute:kAXPositionAttribute];
    [frontMostWindow setValue:size forAttribute:kAXSizeAttribute];
  }
}

@end
