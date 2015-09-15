//
//  KJSelectSizeWC2.m
//  Splitter
//
//  Created by Kenji on 14/9/15.
//  Copyright (c) 2015 Kenji. All rights reserved.
//

#import "KJSelectSizeWC2.h"

static int CellPadding  = 4;

@interface KJSelectSizeWC2 ()

@property (nonatomic, strong) NSArray *cellsList;
@property (nonatomic, assign) NSPoint firstPoint;
@property (nonatomic, assign) NSPoint lastPoint;

@end

@implementation KJSelectSizeWC2

- (void)setNumberOfCells:(NSInteger)numberOfCells {
  _numberOfCells = numberOfCells;
  _cellsList = nil;
}

- (BOOL)becomeFirstResponder {
  return YES;
}

- (void)windowDidLoad {
  [super windowDidLoad];
  
  self.window.alphaValue = 0.9;
  self.window.backgroundColor = [NSColor colorWithCalibratedRed:0.2 green:0.2 blue:0.2 alpha:0.5];
}

- (void)refreshUI {
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_refreshUI) object:nil];
  [self performSelector:@selector(_refreshUI) withObject:nil afterDelay:0.005];
}

- (void)_refreshUI {
  if (self.cellsList.count == 0) {
    
    CGRect screen = [NSScreen mainScreen].frame;
    CGFloat width = 480;
    CGFloat height = 440 * screen.size.height / screen.size.width + 40;
    [self.window setFrame:NSMakeRect(screen.origin.x + (screen.size.width - width)/2, screen.origin.y + (screen.size.height - height)/2, width, height) display:YES];
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    float itemWidth = (self.vContainer.frame.size.width - (self.numberOfCells-1)*CellPadding) / self.numberOfCells;
    float itemHeight = (self.vContainer.frame.size.height - (self.numberOfCells-1)*CellPadding) / self.numberOfCells;
    int n = (int)(self.numberOfCells * self.numberOfCells);
    for (int i = 0; i < n; i++) {
      float xOffset = (i%self.numberOfCells > 0 ? (i%self.numberOfCells) * CellPadding : 0);
      float yOffset = (i/self.numberOfCells > 0 ? (i/self.numberOfCells) * CellPadding : 0);
      NSView *view = [[NSView alloc] initWithFrame:CGRectMake(i%self.numberOfCells * itemWidth + xOffset,
                                                              i/self.numberOfCells * itemHeight + yOffset,
                                                              itemWidth, itemHeight)];
      view.layer = [[CALayer alloc] init];
      view.wantsLayer = YES;
      view.layer.backgroundColor = CGColorCreateGenericRGB(50.0/255, 50.0/255, 153.0/255, 1.0);
      [self.vContainer addSubview:view];
      [list addObject:view];
    }
    self.cellsList = list;
  }
  else {
    CGRect selectRect = [self getRectangleFromPoint1:self.firstPoint andPoint2:self.lastPoint];
    for (NSView *view in self.cellsList) {
      if (CGRectIntersectsRect(selectRect, view.frame)) {
        view.layer.backgroundColor = CGColorCreateGenericRGB(20.0/255, 20.0/255, 61.0/255, 1.0);
      } else {
        view.layer.backgroundColor = CGColorCreateGenericRGB(50.0/255, 50.0/255, 153.0/255, 1.0);
      }
    }
  }
}

- (void)mouseDown:(NSEvent *)theEvent {
  NSPoint point = [theEvent locationInWindow];
  self.firstPoint = [self.vContainer convertPoint:point fromView:self.window.contentView];
}

- (void)mouseDragged:(NSEvent *)theEvent {
  NSPoint point = [theEvent locationInWindow];
  self.lastPoint = [self.vContainer convertPoint:point fromView:self.window.contentView];
  [self refreshUI];
}

- (void)mouseUp:(NSEvent *)theEvent {
  NSPoint point = [theEvent locationInWindow];
  self.lastPoint = [self.vContainer convertPoint:point fromView:self.window.contentView];
  CGRect rect = [self getLogicalRectangleFromPoint:self.firstPoint andPoint:self.lastPoint];
  if (self.delegate && [self.delegate respondsToSelector:@selector(selectSizeWC2:didSelectRect:)]) {
    [self.delegate selectSizeWC2:self didSelectRect:rect];
  }
}

- (CGRect)getRectangleFromPoint1:(NSPoint)p1 andPoint2:(NSPoint)p2 {
  
  CGFloat width = fabs(p2.x - p1.x);
  CGFloat height = fabs(p2.y - p1.y);
  
  NSPoint p3 = NSMakePoint(p1.x, p2.y);
  NSPoint p4 = NSMakePoint(p2.x, p1.y);
  NSPoint smallest = p1;
  if (smallest.x > p2.x || smallest.y > p2.y) {
    smallest = p2;
  }
  if (smallest.x > p3.x || smallest.y > p3.y) {
    smallest = p3;
  }
  if (smallest.x > p4.x || smallest.y > p4.y) {
    smallest = p4;
  }
  
  return CGRectMake(smallest.x, smallest.y, width, height);
}

- (CGRect)getLogicalRectangleFromPoint:(NSPoint)p1 andPoint:(NSPoint)p2 {
  NSPoint smallest = NSMakePoint(999999, 999999);
  NSPoint largest = NSMakePoint(0, 0);
  
  CGRect selectRect = [self getRectangleFromPoint1:p1 andPoint2:p2];
  
  for (NSView *view in self.cellsList) {
    if (CGRectIntersectsRect(selectRect, view.frame)) {
      if (smallest.x > view.frame.origin.x || smallest.y > view.frame.origin.y) {
        smallest = view.frame.origin;
      }
      if (largest.x < view.frame.origin.x || largest.y < view.frame.origin.y) {
        largest = view.frame.origin;
      }
    }
  }
  
  if (smallest.x > largest.x || smallest.y > largest.y) {
    return CGRectZero;
  }
  
  float itemWidth = (self.vContainer.frame.size.width - (self.numberOfCells-1)*CellPadding) / self.numberOfCells;
  float itemHeight = (self.vContainer.frame.size.height - (self.numberOfCells-1)*CellPadding) / self.numberOfCells;
  int x = ((int)smallest.x) / itemWidth;
  int y = ((int)smallest.y) / itemHeight;
  int width = ((int)(largest.x - smallest.x)) / itemWidth + 1;
  int height = ((int)(largest.y - smallest.y)) / itemHeight + 1;
  
  return CGRectMake(x, y, width, height);
}

@end
