//
//  SZDatePicker.h
//  SZDatePicker
//
//  Created by songzhou on 2019/7/16.
//  Copyright © 2019 Song Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SZDatePickerMode) {
    /// 2019|07|16
    SZDatePickerModeDate,
    /// 2019|07|16|16|43
    SZDatePickerModeDateAndTime,
    /// 2019|07
    SZDatePickerModeYearAndMonth,
    /// November
    SZDatePickerModeMonth,
};

@interface SZDatePicker : UIControl

@property (nonatomic) SZDatePickerMode datePickerMode;

/// default is [NSCalendar currentCalendar]. setting nil returns to default
@property (null_resettable, nonatomic, copy) NSCalendar *calendar;

/// default is current date when picker created.
@property (nonatomic) NSDate *date;

/// specify min/max date range. default is nil. When min > max, the values are ignored.
@property (nullable, nonatomic) NSDate *minimumDate;

/// default is nil
@property (nullable, nonatomic) NSDate *maximumDate;

/// date is stored in dateComponents
@property (nonatomic) NSDateComponents *dateComponents;



- (void)setDate:(NSDate *)date animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
