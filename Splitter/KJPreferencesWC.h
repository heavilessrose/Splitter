//
//  KJPreferencesWC.h
//  Splitter
//
//  Created by Kenji on 20/9/15.
//  Copyright © 2015 Kenji. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KJPreferencesWC : NSWindowController

@property (weak) IBOutlet NSButton *cbStartWithSystem;
@property (weak) IBOutlet NSStepper *stepRowsAndCols;
@property (weak) IBOutlet NSTextField *tfRowsAndCols;

- (void)reloadData;

@end
