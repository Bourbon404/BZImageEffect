//
//  ViewController.m
//  ImageEffect
//
//  Created by 郑伟 on 2018/9/12.
//  Copyright © 2018年 郑伟. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>

#import "ImageEffectView.h"

@interface ViewController () <AVCaptureVideoDataOutputSampleBufferDelegate> {
    NSMutableArray *allItem;
}
@property (nonatomic, strong) UIStepper *stepper;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        allItem = [NSMutableArray array];
    } return self;
}

- (void)loadView {
    
    [super loadView];
    [self.navigationController.navigationBar addSubview:self.stepper];
    [self.view addSubview:self.scrollView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [AVCaptureDevice requestAccessForMediaType:(AVMediaTypeVideo) completionHandler:^(BOOL granted) {
        if (!granted) {
            NSLog(@"相机不可用");
        } else {
            [self configSession];
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Method
- (void)configSession {

    //控制管理设备
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession setSessionPreset:(AVCaptureSessionPresetLow)];
    [self.captureSession startRunning];

    //设备
    NSError *error = nil;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //设置输入
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        NSLog(@"error %@",error);
    }
    
    if ([self.captureSession canAddInput:videoInput]) {
        [self.captureSession addInput:videoInput];
    }
    
    //设置输出
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    videoOutput.videoSettings = @{
                                  (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                  
                                  };
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_SERIAL);
    [videoOutput setSampleBufferDelegate:self queue:queue];
    
    if ([self.captureSession canAddOutput:videoOutput]) {
        [self.captureSession addOutput:videoOutput];
    }
}
////通过CGImage的方式，进行图片转换
//- (void)changeBufferToImageByCGImage:(CMSampleBufferRef _Nonnull)sampleBuffer {
//    
//    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
//    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    // 锁定pixel buffer的基地址
//    CVPixelBufferLockBaseAddress(imageBuffer, 0);
//    // 得到pixel buffer的基地址
//    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
//    // 得到pixel buffer的行字节数
//    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
//    // 得到pixel buffer的宽和高
//    size_t width = CVPixelBufferGetWidth(imageBuffer);
//    size_t height = CVPixelBufferGetHeight(imageBuffer);
//    // 创建一个依赖于设备的RGB颜色空间
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
//    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
//    // 根据这个位图context中的像素数据创建一个Quartz image对象
//    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
//    // 解锁pixel buffer
//    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
//    // 释放context和颜色空间
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
//    
//    
//    // 用Quartz image创建一个UIImage对象image
//    UIImage *image = [UIImage imageWithCGImage:quartzImage];
//    // 释放Quartz image对象
//    CGImageRelease(quartzImage);
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.currentImage = image;
//    });
//}


#pragma mark Property
- (UIStepper *)stepper {
    
    if (!_stepper) {
        _stepper = [[UIStepper alloc] initWithFrame:CGRectMake(CGRectGetMidX([UIScreen mainScreen].bounds) - 50, 10, 100, 40)];
        _stepper.minimumValue = 1;
        _stepper.maximumValue = 64;
        _stepper.value = 1;
        _stepper.stepValue = 1;
        [_stepper addTarget:self action:@selector(stepperDidChange:) forControlEvents:(UIControlEventValueChanged)];
    } return _stepper;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) * 3);
    } return _scrollView;
}

#pragma mark Action
- (void)stepperDidChange:(UIStepper *)stepper {
    
    NSInteger currentValue = stepper.value;
    if (allItem.count < currentValue) {
        
        ImageEffectView *effectView = [[ImageEffectView alloc] initWithFrame:CGRectMake(0, 60 * allItem.count, 50, 50)];
        [self.scrollView addSubview:effectView];
        [allItem addObject:effectView];

        [self addObserver:effectView forKeyPath:@"currentBuffer" options:(NSKeyValueObservingOptionNew) context:NULL];
    } else {
        
        ImageEffectView *effectView = [allItem lastObject];
        [self removeObserver:effectView forKeyPath:@"currentBuffer"];
        [allItem removeLastObject];
    }
}

#pragma mark Delegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

    //修正图像上下颠倒的问题
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    [allItem enumerateObjectsUsingBlock:^(ImageEffectView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj changeImage:sampleBuffer];
    }];

}

@end
