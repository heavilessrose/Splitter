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
#import "KJSelectSizeWC2.h"
#import "KJPreferencesWC.h"

static int NumberOfCells = 8;

@interface AppDelegate () <KJSelectSizeWC2Delegate> {
  KJAccessibilityElement *_lastElement;
}

@property (nonatomic, strong) KJSelectSizeWC2 *selectSizeWC2;
@property (nonatomic, strong) KJPreferencesWC *preferencesWC;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  
  // request accessibility
  [self requestAccessibilityPermissonWithPrompt:YES];
  
  // init windows
  self.selectSizeWC2 = [[KJSelectSizeWC2 alloc] initWithWindowNibName:@"KJSelectSizeWC2"];
  self.selectSizeWC2.delegate = self;
  self.selectSizeWC2.numberOfCells = NumberOfCells;
  
  self.preferencesWC = [[KJPreferencesWC alloc] initWithWindowNibName:@"KJPreferencesWC"];
  self.preferencesWC.window.alphaValue = 0.0;
  [self.preferencesWC showWindow:nil];
  [self.preferencesWC close];
  self.preferencesWC.window.alphaValue = 1.0;
  
  // setup status bar icon
  self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  [self.statusItem setMenu:self.menuStatus];
  [self.statusItem setTitle:@""];
  [self.statusItem setImage:[NSImage imageNamed:@"StatusBarButtonImage"]];
  [self.statusItem setHighlightMode:YES];
  
  [self.menuStatus itemWithTag:1].title = @"Half Left \t⌥⌘←";
  [self.menuStatus itemWithTag:2].title = @"Half Right \t⌥⌘→";
  
  // auto start with system
#ifdef CONFIG_DEVELOPMENT
  [KJUtils disableLoginItemForBundle:[NSBundle mainBundle]];
#else
  BOOL autoStart = [[KJUtils getSettingForKey:kSettingsAutoStartWithSystem defaultValue:@(YES)] boolValue];
  if (autoStart) {
    [KJUtils enableLoginItemForBundle:[NSBundle mainBundle]];
  } else {
    [KJUtils disableLoginItemForBundle:[NSBundle mainBundle]];
  }
#endif
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}

- (void)requestAccessibilityPermissonWithPrompt:(BOOL)isPrompt {
  if (isPrompt) {
     NSDictionary *options = @{(__bridge NSString *)kAXTrustedCheckOptionPrompt : @(YES)};
    if (!AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options)) {
      [self performSelector:@selector(requestAccessibilityPermissonWithPrompt:) withObject:nil afterDelay:5.0];
    } else {
      [self setupEventsMonitor];
    }
  } else {
    if (!AXIsProcessTrustedWithOptions(NULL)) {
      [self performSelector:@selector(requestAccessibilityPermissonWithPrompt:) withObject:nil afterDelay:5.0];
    } else {
      [self setupEventsMonitor];
    }
  }
}

- (void)setupEventsMonitor {
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

#pragma mark - Menu Status

- (IBAction)menuStatusClicked:(id)sender {
  NSMenuItem *item = (NSMenuItem *)sender;
  if (item.tag == 1) {
    [self moveWindowToHalfLeft];
  } else if (item.tag == 2) {
    [self moveWindowToHalfRight];
  } else if (item.tag == 3) {
    [self showCustomResizeWindow];
  } else if (item.tag == 900) {
    [self showPreferencesWindow];
  } else if (item.tag == 999) {
    [[NSApplication sharedApplication] terminate:self];
  }
}

#pragma mark - Windows Management

- (void)moveWindowToHalfLeft {
  CGRect screen = [NSScreen mainScreen].frame;
  CGRect leftFrame = CGRectMake(screen.origin.x + 0, screen.origin.y + 0, screen.size.width/2, screen.size.height);
  [self moveFrontMostWindowToFrame:leftFrame];
  _lastElement = nil;
}

- (void)moveWindowToHalfRight {
  CGRect screen = [NSScreen mainScreen].frame;
  CGRect rightFrame = CGRectMake(screen.origin.x + screen.size.width/2, screen.origin.y, screen.size.width/2, screen.size.height);
  [self moveFrontMostWindowToFrame:rightFrame];
  _lastElement = nil;
}

- (void)moveFrontMostWindowToFrame:(CGRect)frame {
  
  NSArray *screens = [NSScreen screens];
  NSScreen *zeroScreen = [[NSScreen screens] objectAtIndex:0];
  for (NSScreen *screen in screens) {
    if (screen.frame.origin.x == 0 && screen.frame.origin.y == 0) {
      zeroScreen = screen;
    }
  }
  
  CGFloat x = frame.origin.x;
  CGFloat y = [NSScreen mainScreen].frame.size.height - frame.origin.y - frame.size.height + (zeroScreen.frame.size.height - [NSScreen mainScreen].frame.size.height);
  frame = CGRectMake(x, y, frame.size.width, frame.size.height);
  
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
    CFRelease(origin);
    CFRelease(size);
    [KJAccessibilityElement focusWindow:frontMostWindow.underlyingElement];
  }
}

- (void)showCustomResizeWindow {
  NumberOfCells = [[KJUtils getSettingForKey:kSettingsNumberOfCells defaultValue:@(6)] intValue];
  _lastElement = [KJAccessibilityElement frontMostWindowElement];
  [self.selectSizeWC2 setNumberOfCells:NumberOfCells];
  [self.selectSizeWC2 refreshUI];
  [self.preferencesWC.window center];
  [self.selectSizeWC2 showWindow:nil];
  [self.selectSizeWC2.window setLevel:NSFloatingWindowLevel];
  [NSApp activateIgnoringOtherApps:YES];
}

- (void)showPreferencesWindow {
  [self.preferencesWC reloadData];
  [self.preferencesWC.window center];
  [self.preferencesWC showWindow:nil];
  [self.preferencesWC.window setLevel:NSFloatingWindowLevel];
  [NSApp activateIgnoringOtherApps:YES];
}

#pragma mark - KJSelectSizeWC2 Delegate

- (void)selectSizeWC2:(KJSelectSizeWC2 *)windowController didSelectRect:(CGRect)rect {
  [self.selectSizeWC2 close];
  if (rect.size.width > 0 && rect.size.height > 0) {
    CGRect screen = [NSScreen mainScreen].frame;
    CGFloat cellWidth = [NSScreen mainScreen].frame.size.width / NumberOfCells;
    CGFloat cellHeight = [NSScreen mainScreen].frame.size.height / NumberOfCells;
    CGFloat x = rect.origin.x * cellWidth;
    CGFloat y = rect.origin.y * cellHeight;
    CGFloat width = rect.size.width * cellWidth;
    CGFloat height = rect.size.height * cellHeight;
    [self moveFrontMostWindowToFrame:CGRectMake(screen.origin.x + x, screen.origin.y + y, width, height)];
  }
}

@end
