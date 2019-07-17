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

@property (nonatomic) NSDateComponents *dateComponents;

@end

NS_ASSUME_NONNULL_END
