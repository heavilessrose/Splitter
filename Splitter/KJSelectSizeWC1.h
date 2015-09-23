//
//  KJSelectSizeWC1.h
//  Splitter
//
//  Created by Kenji on 13/9/15.
//  Copyright (c) 2015 Kenji. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KJSelectSizeWC1 : NSWindowController<NSCollectionViewDelegate>

@property (nonatomic, weak) IBOutlet NSView *vContainer;

- (void)refreshUI;

@end
