//
//  KJSelectSizeWC1.m
//  Splitter
//
//  Created by Kenji on 13/9/15.
//  Copyright (c) 2015 Kenji. All rights reserved.
//

#import "KJSelectSizeWC1.h"

@interface KJSelectSizeWC1 ()

@property (nonatomic, strong) NSArray *cellsList;

@end

@implementation KJSelectSizeWC1

- (void)windowDidLoad {
  [super windowDidLoad];
  
  self.window.alphaValue = 0.9;
  self.window.backgroundColor = [NSColor colorWithCalibratedRed:0.2 green:0.2 blue:0.2 alpha:0.5];
}

- (BOOL)becomeFirstResponder {
  return YES;
}

- (void)refreshUI {
  if (self.cellsList.count == 0) {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    float itemWidth = (self.vContainer.frame.size.width - 5*4) / 6;
    float itemHeight = (self.vContainer.frame.size.height - 5*4) / 6;
    for (int i = 0; i < 36; i++) {
      float xOffset = (i%6 > 0 ? (i%6) * 4 : 0);
      float yOffset = (i/6 > 0 ? (i/6) * 4 : 0);
      NSView *view = [[NSView alloc] initWithFrame:CGRectMake(i%6 * itemWidth + xOffset, i/6 * itemHeight + yOffset, itemWidth, itemHeight)];
      view.layer = [[CALayer alloc] init];
      view.wantsLayer = YES;
      view.layer.backgroundColor = CGColorCreateGenericRGB(0.8, 0.8, 0.0, 1.0);
      [self.vContainer addSubview:view];
      [list addObject:view];
    }
    self.cellsList = list;
  }
}

- (void)mouseDown:(NSEvent *)theEvent {
  NSLog(@"1");
}

- (void)mouseUp:(NSEvent *)theEvent {
  NSLog(@"2");
}

- (void)mouseDragged:(NSEvent *)theEvent {
  NSLog(@"3");
}


@end
