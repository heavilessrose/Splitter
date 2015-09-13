//
//  AppDelegate.h
//  Splitter
//
//  Created by Kenji on 12/9/15.
//  Copyright (c) 2015 Kenji. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, weak) IBOutlet NSMenu *menuStatus;

@property (nonatomic, strong) NSStatusItem *statusItem;

@end

