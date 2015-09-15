//
//  KJSelectSizeWC2.h
//  Splitter
//
//  Created by Kenji on 14/9/15.
//  Copyright (c) 2015 Kenji. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class KJSelectSizeWC2;

@protocol KJSelectSizeWC2Delegate <NSObject>

- (void)selectSizeWC2:(KJSelectSizeWC2 *)windowController didSelectRect:(CGRect)rect;

@end

@interface KJSelectSizeWC2 : NSWindowController

@property (nonatomic, weak) IBOutlet NSView *vContainer;

@property (nonatomic, weak) id<KJSelectSizeWC2Delegate> delegate;

@property (nonatomic, assign) NSInteger numberOfCells;

- (void)refreshUI;

@end
