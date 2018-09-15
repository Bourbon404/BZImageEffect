//
//  EffectManger.h
//  ImageEffect
//
//  Created by 郑伟 on 2018/9/15.
//  Copyright © 2018年 郑伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EffectManger : NSObject

@property (nonatomic, strong) NSMutableArray *allEffectArray;

+ (EffectManger *)sharedManager;

@end
