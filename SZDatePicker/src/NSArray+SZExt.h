//
//  NSArray+SZExt.h
//  PersonalCustom
//
//  Created by songzhou on 2019/7/16.
//  Copyright © 2019 Song Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray<ObjectType> (SZExt)

- (void)sz_each:(void(^)(ObjectType obj))block;
- (void)sz_each_with_index:(void(^)(ObjectType obj, NSInteger index))block;

- (NSArray *)sz_map:(id(^)(ObjectType obj))block;
- (NSArray<ObjectType> *)sz_filter:(BOOL(^)(ObjectType obj))block;

- (ObjectType)sz_find:(BOOL(^)(ObjectType obj))block;

+ (NSArray<NSNumber *> *)sz_make:(NSInteger)numbers;

@end
