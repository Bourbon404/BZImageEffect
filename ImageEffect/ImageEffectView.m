//
//  ImageEffectView.m
//  ImageEffect
//
//  Created by 郑伟 on 2018/9/12.
//  Copyright © 2018年 郑伟. All rights reserved.
//

#import "ImageEffectView.h"
#import "EffectManger.h"
@interface ImageEffectView ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation ImageEffectView

- (void)dealloc {

}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [_imageView setContentMode:(UIViewContentModeScaleAspectFit)];
    } return _imageView;
}


- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imageView];
        self.backgroundColor = [UIColor blackColor];
    } return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

//通过CIImage的方式，进行图片转换
- (UIImage *)changeBufferToImageByCIImage:(CMSampleBufferRef _Nonnull)sampleBuffer {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [CIImage imageWithCVImageBuffer:imageBuffer];
    
    CIFilter*fiter = [[EffectManger sharedManager].allEffectArray objectAtIndex:self.tag];
    
    [fiter setValue:ciImage forKey:kCIInputImageKey];
    
    ciImage = fiter.outputImage;
    
    CIContext *ctx = [CIContext contextWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:kCIContextUseSoftwareRenderer]];
    
    CGImageRef imgRef = [ctx createCGImage:ciImage fromRect:ciImage.extent];
    
    UIImage *image = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);

    return image;
}

- (void)changeImage:(CMSampleBufferRef )ref {
    
    UIImage *image = [self changeBufferToImageByCIImage:ref];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = image;
    });
}

@end
