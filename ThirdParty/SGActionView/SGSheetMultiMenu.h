//
//  SGSheetMenu.h
//  SGActionView
//
//  Created by Sagi on 13-9-6.
//  Copyright (c) 2013年 AzureLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGBaseMenu.h"

@interface SGSheetMultiMenu : SGBaseMenu

- (id)initWithTitle:(NSString *)title itemTitles:(NSArray *)itemTitles;

- (id)initWithTitle:(NSString *)title itemTitles:(NSArray *)itemTitles subTitles:(NSArray *)subTitles;

@property (nonatomic, strong) NSMutableDictionary *selectedItemIndexs;
@property (nonatomic, strong) void(^actionHandle)(NSMutableDictionary *);

- (void)triggerSelectedAction:(void(^)(NSMutableDictionary *))actionHandle;

@end
