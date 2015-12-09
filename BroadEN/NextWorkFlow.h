//
//  NextWorkFlow.h
//  BroadEN
//
//  Created by Seven on 15/12/9.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NextWorkFlow : Jastor

@property int StepID;
@property (copy, nonatomic) NSString *StepName;
@property int NextUserNameCode;
@property (copy, nonatomic) NSString *NextUserName;
@property (copy, nonatomic) NSString *NextUserNameEn;

@end
