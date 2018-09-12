//
//  CollectionViewCell.m
//  ImageEffect
//
//  Created by 郑伟 on 2018/9/12.
//  Copyright © 2018年 郑伟. All rights reserved.
//

#import "CollectionViewCell.h"
@interface CollectionViewCell ()
@end

@implementation CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageView];
    } return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentImage"]) {
        
        UIImage *image = [change objectForKey:NSKeyValueChangeNewKey];
        self.imageView.image = image;
    }
}
@end
