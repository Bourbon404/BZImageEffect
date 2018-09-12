//
//  ImageEffectView.h
//  ImageEffect
//
//  Created by 郑伟 on 2018/9/12.
//  Copyright © 2018年 郑伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>

@interface ImageEffectView : UIView

- (void)changeImage:(CMSampleBufferRef )ref;

@end
