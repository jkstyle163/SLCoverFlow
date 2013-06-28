//
//  SLCoverView.m
//  SLCoverFlow
//
//  Created by jiapq on 13-6-19.
//  Copyright (c) 2013年 HNAGroup. All rights reserved.
//

#import "SLCoverView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SLCoverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_imageView];
    }
    return self;
}

@end
