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
    _picker.datePickerMode = SZDatePickerModeDateAndTime;
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = 2018;
    components.month = 6;
    components.day = 10;
    components.hour = 13;
    components.minute = 10;
    
    NSDateComponents *maxComponents = [[NSDateComponents alloc] init];
    maxComponents.year = 2021;
    maxComponents.month = 8;
    maxComponents.day = 20;
    maxComponents.hour = 14;
    maxComponents.minute = 20;
    
    _picker.minimumDate = [_picker.calendar dateFromComponents:components];
    _picker.maximumDate = [_picker.calendar dateFromComponents:maxComponents];
    
    [self.view addSubview:_picker];
    
    _picker.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
                                              [_picker.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
                                              [_picker.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
                                              [_picker.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
                                              ]];
    
    NSLog(@"SZDatePickerModeMonth initail month: %ld", _picker.dateComponents.month);
    NSLog(@"SZDatePickerModeMonth initail date: %@", _picker.date);

    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem *selectMode = [[UIBarButtonItem alloc] initWithTitle:@"select" style:UIBarButtonItemStylePlain target:self action:@selector(selectMode)];
    
    UIBarButtonItem *changeDate = [[UIBarButtonItem alloc] initWithTitle:@"change" style:UIBarButtonItemStylePlain target:self action:@selector(change)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"date" style:UIBarButtonItemStylePlain target:self action:@selector(getDate)];
    self.navigationItem.leftBarButtonItems = @[selectMode, changeDate];
}

- (void)getDate {
    NSLog(@"%@", self.picker.dateComponents);
    NSLog(@"%@", self.picker.date);
}

- (void)selectMode {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray<NSString *> *mode = @[
                                  @"SZDatePickerModeDate",
                                  @"SZDatePickerModeDateAndTime",
                                  @"SZDatePickerModeYearAndMonth",
                                  @"SZDatePickerModeMonth",
                                  ];
    
    for (NSString *m in mode) {
        [alert addAction:[UIAlertAction actionWithTitle:m
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    self.picker.datePickerMode = [self modelForString:action.title];
                                                }]];
    }
   
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)change {
    [self.picker setDate:[self.picker.date dateByAddingTimeInterval:3600*4] animated:YES];
}

- (SZDatePickerMode)modelForString:(NSString *)mode {
    if ([mode isEqualToString:@"SZDatePickerModeDate"]) {
        return SZDatePickerModeDate;
    }
    
    if ([mode isEqualToString:@"SZDatePickerModeDateAndTime"]) {
        return SZDatePickerModeDateAndTime;
    }
    
    if ([mode isEqualToString:@"SZDatePickerModeYearAndMonth"]) {
        return SZDatePickerModeYearAndMonth;
    }
    
    if ([mode isEqualToString:@"SZDatePickerModeMonth"]) {
        return SZDatePickerModeMonth;
    }
    
    return SZDatePickerModeMonth;
}
@end
