//
//  EffectManger.m
//  ImageEffect
//
//  Created by 郑伟 on 2018/9/15.
//  Copyright © 2018年 郑伟. All rights reserved.
//

#import "EffectManger.h"
#import <CoreImage/CoreImage.h>
@implementation EffectManger

+ (EffectManger *)sharedManager {
    static EffectManger *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[EffectManger alloc] init];
        [manager loadAllEffect];
    }); return manager;
}

- (void)loadAllEffect {
 
    NSArray *array1 = [CIFilter filterNamesInCategory:kCICategoryBlur];
//    NSArray *array2 = [CIFilter filterNamesInCategory:kCICategoryColorEffect];


    self.allEffectArray = [NSMutableArray array];
    [array1 enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CIFilter *filter = [CIFilter filterWithName:obj];
        [self.allEffectArray addObject:filter];
    }];
//
//    [array2 enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        CIFilter *filter = [CIFilter filterWithName:obj];
//        [self.allEffectArray addObject:filter];
//    }];

}

@end
