//
//  KJAccessibilityElement.h
//  Splitter
//
//  Created by Kenji on 13/9/15.
//  Copyright (c) 2015 Kenji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KJAccessibilityElement : NSObject

@property (nonatomic) AXUIElementRef underlyingElement;

+ (KJAccessibilityElement *)systemWideElement;
+ (KJAccessibilityElement *)frontMostWindowElement;

- (KJAccessibilityElement *)elementWithAttribute:(CFStringRef)attribute;

- (NSString *)stringValueOfAttribute:(CFStringRef)attribute;
- (AXValueRef)valueOfAttribute:(CFStringRef)atrribute type:(AXValueType)type;

- (BOOL)setValue:(AXValueRef)value forAttribute:(CFStringRef)attribute;

- (BOOL)isSheet;
- (BOOL)isDialog;

@end
