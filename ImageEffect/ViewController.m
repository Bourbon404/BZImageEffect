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
#import "CollectionViewCell.h"

static NSString * kCellID = @"kCellID";

@interface ViewController () <UICollectionViewDataSource, AVCaptureVideoDataOutputSampleBufferDelegate> {
    NSMutableArray *allItem;
}
@property (nonatomic, strong) UIStepper *stepper;
@property (nonatomic, strong) UIImage *currentImage;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) AVCaptureSession *captureSession;
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
    [self.view addSubview:self.collectionView];
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

- (UICollectionView *)collectionView {
    
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(100, 100);
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                             collectionViewLayout:layout];
        [_collectionView registerClass:[CollectionViewCell class]
            forCellWithReuseIdentifier:kCellID];
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
    } return _collectionView;
}

#pragma mark Action
- (void)stepperDidChange:(UIStepper *)stepper {
    
    NSInteger currentValue = stepper.value;
    if (allItem.count < currentValue) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:allItem.count inSection:0];
        [allItem addObject:@""];
        [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        CollectionViewCell *cell = (CollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [self addObserver:cell forKeyPath:@"currentImage" options:(NSKeyValueObservingOptionNew) context:NULL];
    } else {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(allItem.count - 1) inSection:0];
        
        CollectionViewCell *cell = (CollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [self removeObserver:cell forKeyPath:@"currentImage"];
        [allItem removeLastObject];
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    }
}

#pragma mark Datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return allItem.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor blackColor];
    return cell;
}

#pragma mark Delegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];

    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    // 释放Quartz image对象
    CGImageRelease(quartzImage);

    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentImage = image;
    });
}

@end
