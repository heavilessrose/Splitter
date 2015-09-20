//
//  KJPreferencesWC.m
//  Splitter
//
//  Created by Kenji on 20/9/15.
//  Copyright © 2015 Kenji. All rights reserved.
//

#import "KJPreferencesWC.h"

static int MinNumberOfCells = 4;
static int MaxNumberOfCells = 12;

@interface KJPreferencesWC () <NSTextFieldDelegate> {
  
}

@end

@implementation KJPreferencesWC

- (void)windowDidLoad {
  [super windowDidLoad];
}

- (void)reloadData {
  BOOL autoStart = [[KJUtils getSettingForKey:kSettingsAutoStartWithSystem defaultValue:@(YES)] boolValue];
  int numberOfCells = [[KJUtils getSettingForKey:kSettingsNumberOfCells defaultValue:@(6)] intValue];
  self.cbStartWithSystem.state = autoStart ? NSOnState : NSOffState;
  self.stepRowsAndCols.intValue = numberOfCells;
  self.tfRowsAndCols.stringValue = [NSString stringWithFormat:@"%d", numberOfCells];
  NSNumberFormatter *formatter = (NSNumberFormatter *)self.tfRowsAndCols.formatter;
  if (formatter) {
    formatter.minimum = @(MinNumberOfCells);
    formatter.maximum = @(MaxNumberOfCells);
  }
}

- (IBAction)checkBoxValueChanged:(id)sender {
  // do nothing
}

- (IBAction)stepperClicked:(id)sender {
  [self _setNumberOfCellsValue:self.stepRowsAndCols.intValue];
}

- (IBAction)btnCancelClicked:(id)sender {
  [self close];
}

- (IBAction)btnOkClicked:(id)sender {
  [KJUtils setSetting:@(self.cbStartWithSystem.state == NSOnState ? YES : NO) forKey:kSettingsAutoStartWithSystem];
  [KJUtils setSetting:@(self.stepRowsAndCols.intValue) forKey:kSettingsNumberOfCells];
  [self close];
}

#pragma mark - Methods

- (void)_setNumberOfCellsValue:(int)value {
  if (value < MinNumberOfCells) { value = MinNumberOfCells; }
  if (value > MaxNumberOfCells) { value = MaxNumberOfCells; }
  self.stepRowsAndCols.intValue = value;
  self.tfRowsAndCols.stringValue = [NSString stringWithFormat:@"%d", value];
}



@end
