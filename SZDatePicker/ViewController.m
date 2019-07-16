//
//  ViewController.m
//  SZDatePicker
//
//  Created by songzhou on 2019/7/16.
//  Copyright © 2019 Song Zhou. All rights reserved.
//

#import "ViewController.h"
#import "SZDatePicker.h"

@interface ViewController ()

@property (nonatomic) SZDatePicker *picker;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    _picker = [SZDatePicker new];
    [self.view addSubview:_picker];
    
    _picker.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
                                              [_picker.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
                                              [_picker.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
                                              [_picker.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
                                              ]];
}


@end
