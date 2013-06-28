//
//  SLCoverFlowView.m
//  SLCoverFlow
//
//  Created by jiapq on 13-6-13.
//  Copyright (c) 2013年 HNAGroup. All rights reserved.
//

#import "SLCoverFlowView.h"
#import <QuartzCore/QuartzCore.h>

#import "SLCoverView.h"

static const CGFloat SLCoverWidth = 100.0;
static const CGFloat SLCoverHeight = 100.0;

////////////////////////////////////////////////////////////
// SLCoverView wrapper
@interface SLCoverViewWrapper : NSObject

@property (nonatomic, strong) SLCoverView *coverView;
@property (nonatomic, assign) NSInteger index;

@end

@implementation SLCoverViewWrapper
@end

////////////////////////////////////////////////////////////
// Internal scroll view
@interface SLCoverFlowScrollView : UIScrollView {
    UIView *_coverContainerView;

    CGFloat _horzMargin;
    CGFloat _vertMargin;
    
    NSMutableArray *_coverViewWrappers;
}

@property (nonatomic, assign) SLCoverFlowView *parentView;

- (SLCoverView *)leftMostVisibleCoverView;
- (SLCoverView *)rightMostVisibleCoverView;

- (void)reloadData;
- (void)removeAllCoverViews;
- (void)repositionVisibleCoverViews;

@end

@implementation SLCoverFlowScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _coverContainerView = [[UIView alloc] initWithFrame:self.bounds];
        _coverContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _coverContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:_coverContainerView];
        
        _horzMargin = 0.0;
        _vertMargin = 0.0;
        _coverViewWrappers = [NSMutableArray array];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.parentView.numberOfCoverViews > 0) {
        // tile cover view in visible bounds
        CGRect visibleBounds = [self convertRect:[self bounds] toView:_coverContainerView];
        [self tileCoverViewsFromMinX:CGRectGetMinX(visibleBounds) toMaxX:CGRectGetMaxX(visibleBounds)];
        
        // adjust the (3D)attributes of the visible cover views
        [self adjustCoverViewsTransformWithVisibleBounds:visibleBounds];
    }
}

#pragma mark - Instance methods

- (void)reloadData {
    [self removeAllCoverViews];
    [self resetContentSize];
    self.contentOffset = CGPointMake(0.0, 0.0);
}

- (void)removeAllCoverViews {
    for (SLCoverViewWrapper *wrapper in _coverViewWrappers) {
        [wrapper.coverView removeFromSuperview];
    }
    [_coverViewWrappers removeAllObjects];
}

- (SLCoverView *)leftMostVisibleCoverView {
    if (_coverViewWrappers.count) {
        return [[_coverViewWrappers objectAtIndex:0] coverView];
    } else {
        return nil;
    }
}

- (SLCoverView *)rightMostVisibleCoverView {
    return [[_coverViewWrappers lastObject] coverView];
}

- (void)repositionVisibleCoverViews {
    // reset the top, left, right, bottom margin
    CGFloat oldHorzMargin = _horzMargin;
    CGFloat oldVertMargin = _vertMargin;
    [self resetContentSize];
    
    // adjust the position 
    for (int i = 0; i < _coverViewWrappers.count; ++i) {
        SLCoverView *view = [[_coverViewWrappers objectAtIndex:i] coverView];
        view.center = CGPointMake(view.center.x + _horzMargin - oldHorzMargin,
                                  view.center.y + _vertMargin - oldVertMargin);
    }
}

#pragma mark - Private methods

- (void)resetContentSize {
    // reset the top, left, right, bottom margin
    _horzMargin = (CGRectGetWidth(self.frame) - self.parentView.coverSize.width)/2.0;
    _vertMargin = (CGRectGetHeight(self.frame) - self.parentView.coverSize.height)/2.0;
    
    // reset content size
    if (self.parentView.numberOfCoverViews > 0) {
        self.contentSize = CGSizeMake(_horzMargin*2.0 + self.parentView.numberOfCoverViews*self.parentView.coverSize.width + (self.parentView.numberOfCoverViews-1)*self.parentView.coverSpace, self.frame.size.height);
    } else {
        self.contentSize = self.frame.size;
    }
    
    // reset frame of _coverContainerView 
    _coverContainerView.frame = CGRectMake(0.0, 0.0, self.contentSize.width, self.contentSize.height);
}

- (SLCoverView *)insertCoverViewAtIndex:(NSInteger)index frame:(CGRect)frame {
    SLCoverView *coverView = [self.parentView.delegate coverFlowView:self.parentView coverViewAtIndex:index];
    coverView.frame = frame;
    [_coverContainerView addSubview:coverView];
    return coverView;
}

- (SLCoverViewWrapper *)addNewCoverViewOnRight:(CGFloat)rightEdge index:(NSInteger)index {
    SLCoverViewWrapper *wrapper = nil;
    if (index >= 0 && index < self.parentView.numberOfCoverViews) {
        CGRect frame = CGRectMake(rightEdge, _vertMargin, 0.0, 0.0);
        frame.size = self.parentView.coverSize;
        SLCoverView *coverView = [self insertCoverViewAtIndex:index frame:frame];
        
        wrapper = [[SLCoverViewWrapper alloc] init];
        wrapper.index = index;
        wrapper.coverView = coverView;
        [_coverViewWrappers addObject:wrapper];
    }
    return wrapper;
}

- (SLCoverViewWrapper *)addNewCoverViewOnLeft:(CGFloat)leftEdge index:(NSInteger)index {
    SLCoverViewWrapper *wrapper = nil;
    if (index >= 0 && index < self.parentView.numberOfCoverViews) {
        CGRect frame = CGRectMake(leftEdge - self.parentView.coverSize.width, _vertMargin, 0.0, 0.0);
        frame.size = self.parentView.coverSize;
        SLCoverView *coverView = [self insertCoverViewAtIndex:index frame:frame];

        wrapper = [[SLCoverViewWrapper alloc] init];
        wrapper.index = index;
        wrapper.coverView = coverView;
        [_coverViewWrappers insertObject:wrapper atIndex:0];
    }
    return wrapper;
}

- (CGFloat)leftEdgeOfCoverViewAtIndex:(NSInteger)index {
    // left edge of the cover view at index, space between cover views must be considered
    return (_horzMargin + (self.parentView.coverSize.width + self.parentView.coverSpace)*index - self.parentView.coverSpace);
}

- (CGFloat)rightEdgeOfCoverViewAtIndex:(NSInteger)index {
    // right edge of the cover view at index, space between cover views must be considered
    return (_horzMargin + (self.parentView.coverSize.width + self.parentView.coverSpace)*(index + 1));
}

- (void)tileCoverViewsFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX {
    // add the first cover view
    if (0 == _coverViewWrappers.count) {
        // calculate the nearby middle cover view index in the visible bounds
        NSInteger index = ceilf((minimumVisibleX - _horzMargin) / (self.parentView.coverSize.width + self.parentView.coverSpace));
        index = MIN(MAX(0, index), self.parentView.numberOfCoverViews-1);
        // add cover view at middle
        CGFloat rightEdge = _horzMargin + (self.parentView.coverSize.width + self.parentView.coverSpace)*index;
        [self addNewCoverViewOnRight:rightEdge index:index];
    }
    
    // add cover views missing at right
    SLCoverViewWrapper *lastCoverViewWrapper = (SLCoverViewWrapper *)[_coverViewWrappers lastObject];
    CGFloat rightEdge = [self rightEdgeOfCoverViewAtIndex:lastCoverViewWrapper.index];
    while (rightEdge < maximumVisibleX) {
        lastCoverViewWrapper = [self addNewCoverViewOnRight:rightEdge index:(lastCoverViewWrapper.index+1)];
        if (lastCoverViewWrapper) {
            rightEdge = [self rightEdgeOfCoverViewAtIndex:lastCoverViewWrapper.index];
        } else {
            break;
        }
    }
    
    // add cover views missing at left
    SLCoverViewWrapper *firstCoverViewWrapper = (SLCoverViewWrapper *)[_coverViewWrappers objectAtIndex:0];
    CGFloat leftEdge = [self leftEdgeOfCoverViewAtIndex:firstCoverViewWrapper.index];
    while (leftEdge > minimumVisibleX) {
        firstCoverViewWrapper = [self addNewCoverViewOnLeft:leftEdge index:(firstCoverViewWrapper.index - 1)];
        if (firstCoverViewWrapper) {
            leftEdge = [self leftEdgeOfCoverViewAtIndex:firstCoverViewWrapper.index];
        } else {
            break;
        }
    }
    
    // remove cover views out of left bounds
    firstCoverViewWrapper = (SLCoverViewWrapper *)[_coverViewWrappers objectAtIndex:0];
    while (firstCoverViewWrapper &&
           CGRectGetMaxX(firstCoverViewWrapper.coverView.frame) < minimumVisibleX) {
        [firstCoverViewWrapper.coverView removeFromSuperview];
        [_coverViewWrappers removeObjectAtIndex:0];
        firstCoverViewWrapper = [_coverViewWrappers objectAtIndex:0];
    }
    
    // remove cover views out of right bounds
    lastCoverViewWrapper = (SLCoverViewWrapper *)[_coverViewWrappers lastObject];
    while (lastCoverViewWrapper &&
           CGRectGetMinX(lastCoverViewWrapper.coverView.frame) > maximumVisibleX) {
        [lastCoverViewWrapper.coverView removeFromSuperview];
        [_coverViewWrappers removeLastObject];
        lastCoverViewWrapper = [_coverViewWrappers lastObject];
    }
}

- (void)adjustCoverViewsTransformWithVisibleBounds:(CGRect)visibleBounds {
    // adjust scale and transform of all the visible views
    CGFloat visibleBoundsCenterX = CGRectGetMidX(visibleBounds);
    for (NSInteger i = 0; i < _coverViewWrappers.count; ++i) {
        UIView *coverView = [[_coverViewWrappers objectAtIndex:i] coverView];
        
        CGFloat distance = coverView.center.x - visibleBoundsCenterX;
        CGFloat distanceThreshold = self.parentView.coverSize.width + self.parentView.coverSpace;
        if (distance <= -distanceThreshold) {
            coverView.layer.transform = [self transform3DWithRotation:self.parentView.coverAngle scale:1.0 perspective:(-1.0/500.0)];
            coverView.layer.zPosition = -10000.0;
        } else if (distance < 0.0 && distance > -distanceThreshold) {
            CGFloat percentage = fabsf(distance)/distanceThreshold;
            CGFloat scale = 1.0 + (self.parentView.coverScale - 1.0) * (1.0 - percentage);
            coverView.layer.transform = [self transform3DWithRotation:self.parentView.coverAngle*percentage scale:scale perspective:(-1.0/500.0)];
            coverView.layer.zPosition = -10000.0;
        } else if (distance == 0.0) {
            coverView.layer.transform = [self transform3DWithRotation:0.0 scale:self.parentView.coverScale perspective:(1.0/500.0)];
            coverView.layer.zPosition = 10000.0;
        } else if (distance > 0.0 && distance < distanceThreshold) {
            CGFloat percentage = fabsf(distance)/distanceThreshold;
            CGFloat scale = 1.0 + (self.parentView.coverScale - 1.0) * (1.0 - percentage);
            coverView.layer.transform = [self transform3DWithRotation:-self.parentView.coverAngle*percentage scale:scale perspective:(-1.0/500.0)];
            coverView.layer.zPosition = -10000.0;
        } else if (distance >= distanceThreshold) {
            coverView.layer.transform = [self transform3DWithRotation:-self.parentView.coverAngle scale:1.0 perspective:(-1.0/500.0)];
            coverView.layer.zPosition = -10000.0;
        }
    }
}

- (CATransform3D)transform3DWithRotation:(CGFloat)angle
                                   scale:(CGFloat)scale
                             perspective:(CGFloat)perspective {
    CATransform3D rotateTransform = CATransform3DIdentity;
    rotateTransform.m34 = perspective;
    rotateTransform = CATransform3DRotate(rotateTransform, angle, 0.0, 1.0, 0.0);
    
    CATransform3D scaleTransform = CATransform3DIdentity;
    scaleTransform = CATransform3DScale(scaleTransform, scale, scale, 1.0);
    
    return CATransform3DConcat(rotateTransform, scaleTransform);
}

//- (CATransform3D)transform3DWithRotation:(CGFloat)angle scale:(CGFloat)scale {
//    CATransform3D rotateTransform = CATransform3DIdentity;
//    rotateTransform.m34 = -1.0 / 500.0;
//    rotateTransform = CATransform3DRotate(rotateTransform, angle, 0.0, 1.0, 0.0);
//    
//    CATransform3D scaleTransform = CATransform3DIdentity;
//    scaleTransform = CATransform3DScale(scaleTransform, scale, scale, 1.0);
//    
//    return CATransform3DConcat(rotateTransform, scaleTransform);
//}

@end

////////////////////////////////////////////////////////////
// 
@interface SLCoverFlowView () <UIScrollViewDelegate> {
    SLCoverFlowScrollView *_scrollView;
    CGPoint _endDraggingVelocity;
}

@end


@implementation SLCoverFlowView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[SLCoverFlowScrollView alloc] initWithFrame:self.bounds];
        _scrollView.parentView = self;
        _scrollView.delegate = self;
        _scrollView.bounces = NO;
        _scrollView.decelerationRate = 0.98;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_scrollView];
        
        _numberOfCoverViews = 0;
        _coverSize = CGSizeMake(SLCoverWidth, SLCoverHeight);
        _coverSpace = 0.0;
        _coverAngle = M_PI_4;
        _coverScale = 1.1;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    if (!CGRectEqualToRect(self.frame, frame)) {
        [super setFrame:frame];
        
        [_scrollView repositionVisibleCoverViews];
    }
}

- (void)setCoverSize:(CGSize)coverSize {
    if (!CGSizeEqualToSize(_coverSize, coverSize)) {
        // keep the current middle cover view's position
        NSInteger centerIndex = [self nearByIndexOfScrollViewContentOffset:_scrollView.contentOffset];
        _coverSize = coverSize;
        
        [_scrollView removeAllCoverViews];
        [_scrollView resetContentSize];
        _scrollView.contentOffset = [self offsetWithCenterCoverViewIndex:centerIndex];
        [_scrollView setNeedsLayout];
    }
}

- (void)setCoverSpace:(CGFloat)coverSpace {
    if (_coverSpace != coverSpace) {
        // keep the current middle cover view's position
        NSInteger centerIndex = [self nearByIndexOfScrollViewContentOffset:_scrollView.contentOffset];
        _coverSpace = coverSpace;
        
        [_scrollView removeAllCoverViews];
        [_scrollView resetContentSize];
        _scrollView.contentOffset = [self offsetWithCenterCoverViewIndex:centerIndex];
        [_scrollView setNeedsLayout];
    }
}

- (void)setCoverAngle:(CGFloat)coverAngle {
    if (_coverAngle != coverAngle) {
        _coverAngle = coverAngle;
        
        [_scrollView setNeedsLayout];
    }
}

- (void)setCoverScale:(CGFloat)coverScale {
    if (_coverScale != coverScale) {
        _coverScale = coverScale;
        
        [_scrollView setNeedsLayout];
    }
}

#pragma mark - Instance methods

- (void)reloadData {
    _numberOfCoverViews = [self.delegate numberOfCovers:self];
    [_scrollView reloadData];
}
    
- (SLCoverView *)leftMostVisibleCoverView {
    return [_scrollView leftMostVisibleCoverView];
}

- (SLCoverView *)rightMostVisibleCoverView {
    return [_scrollView rightMostVisibleCoverView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    _endDraggingVelocity = velocity;
 
    if (_endDraggingVelocity.x == 0) {
        // find the nearby content offset
        *targetContentOffset = [self nearByOffsetOfScrollViewContentOffset:_scrollView.contentOffset];
    } else {
        // calculate the slide distance and end scrollview content offset
        CGFloat startVelocityX = fabsf(_endDraggingVelocity.x);
        CGFloat decelerationRate = 1.0 - _scrollView.decelerationRate;

        CGFloat decelerationSeconds = startVelocityX / decelerationRate;
        CGFloat distance = startVelocityX * decelerationSeconds - 0.5 * decelerationRate * decelerationSeconds * decelerationSeconds;
        
        CGFloat endOffsetX = _endDraggingVelocity.x > 0 ? (_scrollView.contentOffset.x + distance) : (_scrollView.contentOffset.x - distance);
        
        // calculate the nearby content offset of the middle cover view
        *targetContentOffset = [self nearByOffsetOfScrollViewContentOffset:CGPointMake(endOffsetX, _scrollView.contentOffset.y)];
    }
}

#pragma mark - Private methods
    
- (NSUInteger)nearByIndexOfScrollViewContentOffset:(CGPoint)contentOffset {
    NSInteger index = nearbyintf(contentOffset.x / (self.coverSize.width + self.coverSpace));
    return MIN(MAX(0, index), self.numberOfCoverViews-1);
}

- (CGPoint)nearByOffsetOfScrollViewContentOffset:(CGPoint)contentOffset {
    NSInteger index = [self nearByIndexOfScrollViewContentOffset:contentOffset];
    return CGPointMake(index*(self.coverSize.width + self.coverSpace), contentOffset.y);
}

- (CGPoint)offsetWithCenterCoverViewIndex:(NSInteger)index {
    return CGPointMake(index*(self.coverSize.width + self.coverSpace), _scrollView.contentOffset.y);
}

@end
