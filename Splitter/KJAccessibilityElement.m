//
//  KJAccessibilityElement.m
//  Splitter
//
//  Created by Kenji on 13/9/15.
//  Copyright (c) 2015 Kenji. All rights reserved.
//

#import "KJAccessibilityElement.h"

@implementation KJAccessibilityElement

+ (KJAccessibilityElement *)systemWideElement {
  static KJAccessibilityElement *systemWidgElement = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    AXUIElementRef underlyingElement = AXUIElementCreateSystemWide();
    systemWidgElement = [KJAccessibilityElement new];
    systemWidgElement.underlyingElement = underlyingElement;
    CFRelease(underlyingElement);
  });
  return systemWidgElement;
}

+ (KJAccessibilityElement *)frontMostWindowElement {
  KJAccessibilityElement *systemWideElement = [KJAccessibilityElement systemWideElement];
  KJAccessibilityElement *focusedApplication = [systemWideElement elementWithAttribute:kAXFocusedApplicationAttribute];
  KJAccessibilityElement *frontMostWindow = nil;
  
  if (focusedApplication) {
    frontMostWindow = [focusedApplication elementWithAttribute:kAXFocusedWindowAttribute];
    if (!frontMostWindow) {
      NSLog(@"get focus window failed");
    }
  } else {
    NSLog(@"get focus app failed");
  }
  
  return frontMostWindow;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _underlyingElement = NULL;
  }
  return self;
}

- (void)dealloc {
  if (_underlyingElement != NULL) {
    CFRelease(_underlyingElement);
  }
}

- (void)setUnderlyingElement:(AXUIElementRef)underlyingElement {
  if (_underlyingElement != NULL) {
    CFRelease(_underlyingElement);
  }
  _underlyingElement = CFRetain(underlyingElement);
}

- (KJAccessibilityElement *)elementWithAttribute:(CFStringRef)attribute {
  KJAccessibilityElement *element = nil;
  AXUIElementRef underlyingElement;
  AXError result;
  
  result = AXUIElementCopyAttributeValue(self.underlyingElement, attribute, (CFTypeRef *)&underlyingElement);
  
  if (result == kAXErrorSuccess) {
    element = [KJAccessibilityElement new];
    element.underlyingElement = underlyingElement;
    CFRelease(underlyingElement);
  } else {
    NSLog(@"unable to obtain accessibility element with attribute: %@ error: %d", attribute, result);
  }
  
  return element;
}

- (NSString *)stringValueOfAttribute:(CFStringRef)attribute {
  if (CFGetTypeID(self.underlyingElement) == AXUIElementGetTypeID()) {
    CFTypeRef value;
    AXError result;
    
    result = AXUIElementCopyAttributeValue(self.underlyingElement, attribute, &value);
    
    if (result == kAXErrorSuccess) {
      return CFBridgingRelease(value);
    } else {
      NSLog(@"unable to get string value of attribute: %@ error: %d", attribute, result);
    }
  }
  return nil;
}

- (AXValueRef)valueOfAttribute:(CFStringRef)attribute type:(AXValueType)type {
  if (CFGetTypeID(self.underlyingElement) == AXUIElementGetTypeID()) {
    CFTypeRef value;
    AXError result;
    
    result = AXUIElementCopyAttributeValue(self.underlyingElement, attribute, (CFTypeRef *)&value);
    
    if ((result == kAXErrorSuccess) && (AXValueGetType(value) == type)) {
      return value;
    } else {
      NSLog(@"unable to get value of attribute: %@ error: %d", attribute, result);
    }
  }
  
  return NULL;
}

- (BOOL)setValue:(AXValueRef)value forAttribute:(CFStringRef)attribute {
  AXError result = AXUIElementSetAttributeValue(self.underlyingElement, attribute, (CFTypeRef*)value);
  if (result != kAXErrorSuccess) {
    NSLog(@"unable to set value of attribute: %@ error: %d", attribute, result);
  }
  return (result == kAXErrorSuccess);
}

- (BOOL)isSheet {
  return [[self stringValueOfAttribute:kAXRoleAttribute] isEqualToString:(__bridge NSString *)kAXSheetRole];
}

- (BOOL)isDialog {
  return [[self stringValueOfAttribute:kAXSubroleAttribute] isEqualToString:(__bridge NSString *)kAXSystemDialogSubrole];
}

@end
