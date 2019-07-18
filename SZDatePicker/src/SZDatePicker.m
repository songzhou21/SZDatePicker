//
//  SZDatePicker.m
//  SZDatePicker
//
//  Created by songzhou on 2019/7/16.
//  Copyright © 2019 Song Zhou. All rights reserved.
//

#import "SZDatePicker.h"
#import "NSArray+SZExt.h"

@interface SZDatePicker () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic) UIPickerView *pickerView;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSTimeZone *timeZone;


@property (nonatomic, copy) NSArray<NSNumber *> *yearList;
@property (nonatomic, copy) NSArray<NSNumber *> *monthList;
@property (nonatomic, copy) NSArray<NSNumber *> *hourList;
@property (nonatomic, copy) NSArray<NSNumber *> *minuteList;

@property (nonatomic) NSDateComponents *minimumDateComponents;
@property (nonatomic) NSDateComponents *maxmumDateComponents;

@end

@implementation SZDatePicker

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _pickerView = [[UIPickerView alloc] initWithFrame:frame];
        [self addSubview:_pickerView];
        
        _pickerView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:
         @[
           [_pickerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
           [_pickerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
           [_pickerView.topAnchor constraintEqualToAnchor:self.topAnchor],
           [_pickerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
           ]];
        
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
    }
    
    return self;
}

- (void)setDate:(NSDate *)date animated:(BOOL)animated {
    self.dateComponents = [self.calendar componentsInTimeZone:self.calendar.timeZone fromDate:date];
    
    [self _reloadAnimated:animated];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (self.datePickerMode == SZDatePickerModeMonth) {
        return 1;
    } else if (self.datePickerMode == SZDatePickerModeYearAndMonth) {
        return 2;
    } else if (self.datePickerMode == SZDatePickerModeDate) {
        return 3;
    } else if (self.datePickerMode == SZDatePickerModeDateAndTime) {
        return 5;
    }

    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.datePickerMode == SZDatePickerModeMonth) {
        return self.monthList.count;
    } else if (self.datePickerMode == SZDatePickerModeYearAndMonth) {
        if (component == 0) {
            return self.yearList.count;
        } else {
            return self.monthList.count;
        }
    } else if (self.datePickerMode == SZDatePickerModeDate) {
        if (component == 0) {
            return self.yearList.count;
        } else if (component == 1){
            return self.monthList.count;
        } else {
            return [self dayListForDate:self.date].count;
        }
    } else if (self.datePickerMode == SZDatePickerModeDateAndTime) {
        if (component == 0) {
            return self.yearList.count;
        } else if (component == 1){
            return self.monthList.count;
        } else if (component == 2) {
            return [self dayListForDate:self.date].count;
        } else if (component == 3) {
            return self.hourList.count;
        } else if (component == 4) {
            return self.minuteList.count;
        }
    }
    
    return 0;
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDateComponents *components = [self displayDateComponents];
    NSString *format;
    
    if (self.datePickerMode == SZDatePickerModeMonth) {
        components.month = self.monthList[row].integerValue;
        self.dateFormatter.dateFormat = @"LLL";
        return [self.dateFormatter stringFromDate:components.date];
    }
    
    
    if (component == 0) { // year
        components.year = self.yearList[row].integerValue;
        components.yearForWeekOfYear = components.year;
        format = @"y";
        if (self.datePickerMode == SZDatePickerModeDateAndTime) {
            self.dateFormatter.dateFormat = format;
        } else {
            self.dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:format options:0 locale:self.calendar.locale];
        }
    } else if (component == 1){ // month
        components.month = self.monthList[row].integerValue;
        format = @"LLL";
        self.dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:format options:0 locale:self.calendar.locale];
    } else if (component == 2) { // day
        NSArray<NSNumber *> *ret = [self dayListForDate:self.date];
        components.day = ret[row].integerValue;
        format = @"d";
        self.dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:format options:0 locale:self.calendar.locale];
    } else if (component == 3) {
        components.hour = self.hourList[row].integerValue;
        self.dateFormatter.dateFormat = @"H";
    } else if (component == 4) {
        components.minute = self.minuteList[row].integerValue;
        self.dateFormatter.dateFormat = @"m";
    }

   
    return [self.dateFormatter stringFromDate:components.date];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self _updateForRow:row inComponent:component mode:self.datePickerMode];
}

#pragma mark - Getter
- (NSTimeZone *)timeZone {
    if (!_timeZone) {
        _timeZone = [NSTimeZone systemTimeZone];
    }
    
    return _timeZone;
}

@synthesize calendar = _calendar;
- (NSCalendar *)calendar {
    if (!_calendar) {
        _calendar = [self _makeCalendar];
    }
    
    return _calendar;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [NSDateFormatter new];
        _dateFormatter.calendar = self.calendar;
        _dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:[NSLocale preferredLanguages].firstObject];
    }
    
    return _dateFormatter;
}

@synthesize dateComponents = _dateComponents;
- (NSDateComponents *)dateComponents {
    if (!_dateComponents) {
        _dateComponents = [self.calendar components:
                           NSCalendarUnitYear|
                           NSCalendarUnitYearForWeekOfYear|
                           NSCalendarUnitMonth|
                           NSCalendarUnitDay|
                           NSCalendarUnitHour|
                           NSCalendarUnitMinute
                                           fromDate:[NSDate date]];
        _dateComponents.calendar = [self calendar];
    }
    
    return _dateComponents;
}

- (NSDate *)date {
    return self.dateComponents.date;
}

#pragma mark - Component
- (NSArray<NSNumber *> *)yearList {
    if (!_yearList) {
        NSInteger pastYear = [self.calendar componentsInTimeZone:self.timeZone fromDate:[NSDate distantPast]].year;
        NSInteger futureYear = [self.calendar componentsInTimeZone:self.timeZone fromDate:[NSDate distantFuture]].year;
        NSInteger capacity = futureYear-pastYear+1;
        
        NSMutableArray *ret = [NSMutableArray arrayWithCapacity:capacity];
        for (NSInteger i = 0; i < capacity; i++) {
            ret[i] = @(pastYear++);
        }
        
        _yearList = ret;
    }

    return _yearList;
}

- (NSArray<NSNumber *> *)monthList {
    _monthList = [self _makeRangeOfUnit:NSCalendarUnitMonth inUnit:NSCalendarUnitYear forDate:self.date];

    if (_datePickerMode == SZDatePickerModeMonth) {
        return _monthList;
    }
    
    if (_minimumDateComponents) {
        NSInteger year = _dateComponents.year;
        if (year == _minimumDateComponents.year) {
            NSInteger month = _minimumDateComponents.month;
            _monthList = [_monthList sz_filter:^BOOL(NSNumber *obj) {
                return obj.integerValue >= month;
            }];
        }
    }
    
    if (_maxmumDateComponents) {
        NSInteger year = _dateComponents.year;
        if (year == _maxmumDateComponents.year) {
            NSInteger month = _maxmumDateComponents.month;
            _monthList = [_monthList sz_filter:^BOOL(NSNumber *obj) {
                return obj.integerValue <= month;
            }];
        }
    }
    
    return _monthList;
}


- (NSArray<NSNumber *> *)dayListForDate:(NSDate *)date {
    __auto_type list = [self _makeRangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    
    if (_minimumDateComponents) {
        if (_dateComponents.year == _minimumDateComponents.year &&
            _dateComponents.month == _minimumDateComponents.month) {
            
            list = [list sz_filter:^BOOL(NSNumber *obj) {
                return obj.integerValue >= self.minimumDateComponents.day;
            }];
        }
    }
    
    if (_maxmumDateComponents) {
        if (_dateComponents.year == _maxmumDateComponents.year &&
            _dateComponents.month == _maxmumDateComponents.month) {
            list = [list sz_filter:^BOOL(NSNumber *obj) {
                return obj.integerValue <= self.maxmumDateComponents.day;
            }];
        }
    }
    
    return list;
}


- (NSArray<NSNumber *> *)hourList {
    _hourList = [self _makeRangeOfUnit:NSCalendarUnitHour inUnit:NSCalendarUnitDay forDate:self.date];
    
    if (_minimumDateComponents) {
        if (_dateComponents.year == _minimumDateComponents.year &&
            _dateComponents.month == _minimumDateComponents.month &&
            _dateComponents.day == _minimumDateComponents.day) {
            _hourList = [_hourList sz_filter:^BOOL(NSNumber *obj) {
                return obj.integerValue >= self.minimumDateComponents.hour;
            }];
        }
    }
    
    if (_maxmumDateComponents) {
        if (_dateComponents.year == _maxmumDateComponents.year &&
            _dateComponents.month == _maxmumDateComponents.month &&
            _dateComponents.day == _maxmumDateComponents.day) {
            _hourList = [_hourList sz_filter:^BOOL(NSNumber *obj) {
                return obj.integerValue <= self.maxmumDateComponents.hour;
            }];
        }
    }
    
    
    return _hourList;
}

- (NSArray<NSNumber *> *)minuteList {
    _minuteList = [self _makeRangeOfUnit:NSCalendarUnitMinute inUnit:NSCalendarUnitHour forDate:self.date];
    
    if (_minimumDateComponents) {
        if (_dateComponents.year == _minimumDateComponents.year &&
            _dateComponents.month == _minimumDateComponents.month &&
            _dateComponents.day == _minimumDateComponents.day &&
            _dateComponents.hour == _minimumDateComponents.hour) {
            _minuteList = [_minuteList sz_filter:^BOOL(NSNumber *obj) {
                return obj.integerValue >= self.minimumDateComponents.minute;
            }];
        }
    }
    
    if (_maxmumDateComponents) {
        if (_dateComponents.year == _maxmumDateComponents.year &&
            _dateComponents.month == _maxmumDateComponents.month &&
            _dateComponents.day == _maxmumDateComponents.day &&
            _dateComponents.hour == _maxmumDateComponents.hour) {
            _minuteList = [_minuteList sz_filter:^BOOL(NSNumber *obj) {
                return obj.integerValue <= self.maxmumDateComponents.minute;
            }];
        }
    }
    
    return _minuteList;
}

- (NSDateComponents *)displayDateComponents {
    NSDateComponents *components = [self.dateComponents copy];
    
    components.day = 1; // prevent overflow when changed month
    
    return components;
}

- (void)updateDateRangeWithMinimumDate:(nullable NSDate *)minimumDate maximumDate:(nullable NSDate *)maximumDate {
    // update year list
    NSInteger smallYear = [self.calendar component:NSCalendarUnitYear fromDate:minimumDate ?: [NSDate distantPast]];
    NSInteger largeYear = [self.calendar  component:NSCalendarUnitYear fromDate:maximumDate ?: [NSDate distantFuture]];
    NSInteger capacity = largeYear-smallYear+1;
    
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:capacity];
    for (NSInteger i = 0; i < capacity; i++) {
        ret[i] = @(smallYear++);
    }
    
    _yearList = ret;
    
    
}
#pragma mark - Setter
- (void)setCalendar:(NSCalendar *)calendar {
    if (calendar == nil) {
        _calendar = [self _makeCalendar];
    } else {
        _calendar = calendar;
    }
    
    self.dateComponents.calendar = _calendar;
}

- (void)setDatePickerMode:(SZDatePickerMode)datePickerMode {
    _datePickerMode = datePickerMode;
    
    [self _reloadAnimated:NO];
}

- (void)setDateComponents:(NSDateComponents *)dateComponents {
    _dateComponents = dateComponents;
}

- (void)setMinimumDate:(NSDate *)minimumDate {
    if (_maximumDate && [minimumDate compare:_maximumDate] == NSOrderedDescending) {
        return;
    }
    
    _minimumDate = minimumDate;
    _minimumDateComponents = [self.calendar componentsInTimeZone:self.timeZone fromDate:_minimumDate];
    
    [self updateDateRangeWithMinimumDate:_minimumDate maximumDate:_maximumDate];
    [self _reloadAnimated:NO];
}

- (void)setMaximumDate:(NSDate *)maximumDate {
    if (_minimumDate && [maximumDate compare:_minimumDate] == NSOrderedAscending) {
        return;
    }
    
    _maximumDate = maximumDate;
    _maxmumDateComponents = [self.calendar componentsInTimeZone:self.timeZone fromDate:_maximumDate];
    
    [self updateDateRangeWithMinimumDate:_minimumDate maximumDate:_maximumDate];
    [self _reloadAnimated:NO];
}

#pragma mark - Private
- (NSCalendar *)_makeCalendar {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.locale = [NSLocale localeWithLocaleIdentifier:[NSLocale preferredLanguages].firstObject];
    
    return calendar;
}

- (void)_updateComponents:(NSDateComponents *)components
                     year:(NSInteger)year
                    month:(NSInteger)month
                      day:(NSInteger)day{
    [self _updateComponents:components year:year month:month day:day hour:-1 minute:-1];
}

- (void)_updateComponents:(NSDateComponents *)components
                     year:(NSInteger)year
                    month:(NSInteger)month
                      day:(NSInteger)day
                     hour:(NSInteger)hour
                   minute:(NSInteger)minute {
    NSDateComponents *c = components;
    if (year > 0) {
        c.year = year;
        c.yearForWeekOfYear = year;
        
        [self _updateDateComponentsUnitDayIfNeeded:c];
    }
    
    if (month > 0) {
        c.month = month;
        
        [self _updateDateComponentsUnitDayIfNeeded:c];
    }
    
    if (day > 0) {
        c.day = day;
    }
    
    if (hour > -1) {
        c.hour = hour;
    }

    if (minute > -1) {
        c.minute = minute;
    }

    [self _reloadAnimated:YES];
}

- (NSArray<NSNumber *> *)_makeRangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date {
    NSRange range = [self.calendar rangeOfUnit:smaller
                                        inUnit:larger
                                       forDate:date];
    NSMutableArray<NSNumber *> *ret = [NSMutableArray arrayWithCapacity:range.length];
    for (NSInteger i = 0; i < range.length; i++) {
        ret[i] = @(range.location + i);
    }
    
    return ret;
}

- (NSArray<NSNumber *> *)_makeDaysInDate:(NSDate *)date {
    return [self _makeRangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
}

- (NSArray<NSNumber *> *)_makeHoursInDate:(NSDate *)date {
    return [self _makeRangeOfUnit:NSCalendarUnitHour inUnit:NSCalendarUnitDay forDate:date];
}

- (void)_updateDateComponentsUnitDayIfNeeded:(NSDateComponents *)components {
    NSDateComponents *c = [components copy];
    c.day = 1; // make the date valid
    
    NSRange range = [self.calendar rangeOfUnit:NSCalendarUnitDay
                                        inUnit:NSCalendarUnitMonth
                                       forDate:c.date];
    
    if (NSLocationInRange(components.day, range)) {
        return;
    }
    
    components.day = range.length;
}

- (void)_updateForRow:(NSInteger)row inComponent:(NSInteger)component mode:(SZDatePickerMode)mode {
    if (self.datePickerMode == SZDatePickerModeMonth) {
        if (component == 0) {
            [self _updateComponents:self.dateComponents year:-1 month:row+1 day:-1];
        }
        return;
    }
    
    
    if (component == 0) {
        NSInteger year = self.yearList[row].integerValue;
        [self _updateComponents:self.dateComponents year:year month:-1 day:-1];
    } else if (component == 1){
        [self _updateComponents:self.dateComponents year:-1 month:self.monthList[row].integerValue day:-1];
    } else if (component == 2) {
        [self _updateComponents:self.dateComponents year:-1 month:-1 day:[self dayListForDate:self.date][row].integerValue];
    } else if (component == 3) {
        NSInteger hour = self.hourList[row].integerValue;
        [self _updateComponents:self.dateComponents year:-1 month:-1 day:-1 hour:hour minute:-1];
    } else if (component == 4) {
        NSInteger minute = self.minuteList[row].integerValue;
        [self _updateComponents:self.dateComponents year:-1 month:-1 day:-1 hour:-1 minute:minute];
    }
}

- (void)_selectedRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated {
    if (row == NSNotFound) {
        return;
    }
    
    [_pickerView selectRow:row inComponent:component animated:animated];
}

- (void)_reloadAnimated:(BOOL)animated {
    [_pickerView reloadAllComponents];
    if (_datePickerMode == SZDatePickerModeMonth) {
        [self _selectedRow:[self.monthList indexOfObject:@(self.dateComponents.month)] inComponent:0 animated:animated];
    } else if (_datePickerMode == SZDatePickerModeYearAndMonth) {
        NSInteger yearIndex = [self.yearList indexOfObject:@(self.dateComponents.year)];
        NSInteger monthIndex = [self.monthList indexOfObject:@(self.dateComponents.month)];
        
        [self _selectedRow:yearIndex inComponent:0 animated:animated];
        [self _selectedRow:monthIndex inComponent:1 animated:animated];
    } else if (_datePickerMode == SZDatePickerModeDate) {
        NSArray<NSNumber *> *days = [self dayListForDate:self.date];
        
        NSInteger yearIndex = [self.yearList indexOfObject:@(self.dateComponents.year)];
        NSInteger monthIndex = [self.monthList indexOfObject:@(self.dateComponents.month)];
        
        [self _selectedRow:yearIndex inComponent:0 animated:animated];
        [self _selectedRow:monthIndex inComponent:1 animated:animated];
        [self _selectedRow:[days indexOfObject:@(self.dateComponents.day)] inComponent:2 animated:animated];
    } else if (_datePickerMode == SZDatePickerModeDateAndTime) {
        NSDate *date = self.date;
        NSArray<NSNumber *> *days = [self dayListForDate:date];
        __auto_type hours = self.hourList;
        __auto_type miniuts = self.minuteList;
        
        NSInteger yearIndex = [self.yearList indexOfObject:@(self.dateComponents.year)];
        NSInteger monthIndex = [self.monthList indexOfObject:@(self.dateComponents.month)];
        
        [self _selectedRow:yearIndex inComponent:0 animated:animated];
        [self _selectedRow:monthIndex inComponent:1 animated:animated];
        [self _selectedRow:[days indexOfObject:@(self.dateComponents.day)] inComponent:2 animated:animated];
        
        [self _selectedRow:[hours indexOfObject:@(self.dateComponents.hour)] inComponent:3 animated:animated];
        [self _selectedRow:[miniuts indexOfObject:@(self.dateComponents.minute)] inComponent:4 animated:animated];
    }
}
@end
