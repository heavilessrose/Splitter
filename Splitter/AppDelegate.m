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
#import "KJSelectSizeWC1.h"
#import "KJSelectSizeWC2.h"

@interface AppDelegate () <KJSelectSizeWC2Delegate> {
  KJAccessibilityElement *_lastElement;
}

@property (nonatomic, strong) KJSelectSizeWC1 *selectSizeWC1;
@property (nonatomic, strong) KJSelectSizeWC2 *selectSizeWC2;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  
  // check accessibility trusted
  NSDictionary *options = @{(__bridge NSString *)kAXTrustedCheckOptionPrompt : @(YES)};
  if (!AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options)) {
    NSLog(@"don't have permission. warn user");
  }
  
  // init windows
  self.selectSizeWC1 = [[KJSelectSizeWC1 alloc] initWithWindowNibName:@"KJSelectSizeWC1"];
  self.selectSizeWC2 = [[KJSelectSizeWC2 alloc] initWithWindowNibName:@"KJSelectSizeWC2"];
  self.selectSizeWC2.delegate = self;
  
  // setup status bar icon
  self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  [self.statusItem setMenu:self.menuStatus];
  [self.statusItem setTitle:@""];
  [self.statusItem setImage:[NSImage imageNamed:@"StatusBarButtonImage"]];
  [self.statusItem setHighlightMode:YES];
  
  [self.menuStatus itemWithTag:1].title = @"Half Left \t⌥⌘←";
  [self.menuStatus itemWithTag:2].title = @"Half Right \t⌥⌘→";
  
  // setup event monitor
  [NSEvent addGlobalMonitorForEventsMatchingMask:(NSKeyDownMask) handler:^(NSEvent *event) {
    if ((event.modifierFlags & NSCommandKeyMask) && (event.modifierFlags & NSAlternateKeyMask)) {
      if (event.keyCode == 0x7B) {
        [self moveWindowToHalfLeft];
      }
      if (event.keyCode == 0x7C) {
        [self moveWindowToHalfRight];
      }
      if (event.keyCode == 40) {
        [self showCustomResizeWindow];
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
  } else if (item.tag == 3) {
    [self showCustomResizeWindow];
  } else if (item.tag == 999) {
    [[NSApplication sharedApplication] terminate:self];
  }
}

#pragma mark - Windows Management

- (void)moveWindowToHalfLeft {
  CGRect screen = [NSScreen mainScreen].frame;
  CGRect leftFrame = CGRectMake(0, 0, screen.size.width/2, screen.size.height);
  [self moveFrontMostWindowToFrame:leftFrame];
  _lastElement = nil;
}

- (void)moveWindowToHalfRight {
  CGRect screen = [NSScreen mainScreen].frame;
  CGRect rightFrame = CGRectMake(screen.size.width/2, 0, screen.size.width/2, screen.size.height);
  [self moveFrontMostWindowToFrame:rightFrame];
  _lastElement = nil;
}

- (void)moveFrontMostWindowToFrame:(CGRect)frame {
  KJAccessibilityElement *frontMostWindow = nil;
  if (_lastElement) {
    frontMostWindow = _lastElement;
  } else {
    frontMostWindow = [KJAccessibilityElement frontMostWindowElement];
  }
  if (frontMostWindow) {
    AXValueRef origin = AXValueCreate(kAXValueCGPointType, (const void *)&frame.origin);
    AXValueRef size = AXValueCreate(kAXValueCGSizeType, (const void *)&frame.size);
    [frontMostWindow setValue:origin forAttribute:kAXPositionAttribute];
    [frontMostWindow setValue:size forAttribute:kAXSizeAttribute];
    [frontMostWindow setValue:(AXValueRef)kCFBooleanTrue forAttribute:kAXMainAttribute];
    [frontMostWindow setValue:(AXValueRef)kCFBooleanTrue forAttribute:kAXFocusedAttribute];
  }
}

- (void)showCustomResizeWindow {
  _lastElement = [KJAccessibilityElement frontMostWindowElement];
  [self.selectSizeWC2.window center];
  [self.selectSizeWC2 refreshUI];
  [self.selectSizeWC2 showWindow:nil];
  [self.selectSizeWC2.window setLevel:NSFloatingWindowLevel];
  [self.selectSizeWC2.window makeKeyWindow];
  [self.selectSizeWC2.window becomeFirstResponder];
}

#pragma mark - KJSelectSizeWC2 Delegate

- (void)selectSizeWC2:(KJSelectSizeWC2 *)windowController didSelectRect:(CGRect)rect {
  [self.selectSizeWC2 close];
  if (rect.size.width > 0 && rect.size.height > 0) {
    CGFloat cellWidth = [NSScreen mainScreen].frame.size.width / 6.0;
    CGFloat cellHeight = [NSScreen mainScreen].frame.size.height / 6.0;
    CGFloat x = rect.origin.x * cellWidth;
    CGFloat y = (6 - rect.origin.y - rect.size.height) * cellHeight;
    CGFloat width = rect.size.width * cellWidth;
    CGFloat height = rect.size.height * cellHeight;
    [self moveFrontMostWindowToFrame:CGRectMake(x, y, width, height)];
  }
}

@end
