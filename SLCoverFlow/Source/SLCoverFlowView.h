//
//  SLCoverFlowView.h
//  SLCoverFlow
//
//  Created by SmartCat on 13-6-13.
//  Copyright (c) 2013年 SmartCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLCoverView;
@protocol SLCoverFlowViewDataSource;

@interface SLCoverFlowView : UIView

@property (nonatomic, assign) id<SLCoverFlowViewDataSource> delegate;

// size of cover view
@property (nonatomic, assign) CGSize coverSize;
// space between cover views
@property (nonatomic, assign) CGFloat coverSpace;
// angle of side cover views
@property (nonatomic, assign) CGFloat coverAngle;
// scale of middle cover view
@property (nonatomic, assign) CGFloat coverScale;

@property (nonatomic, assign, readonly) NSInteger numberOfCoverViews;

@property (nonatomic, assign) BOOL showsHorizontalScrollIndicator;

@property (nonatomic, assign) BOOL showsVerticalScrollIndicator;
- (void)reloadData;

- (SLCoverView *)leftMostVisibleCoverView;
- (SLCoverView *)rightMostVisibleCoverView;

- (void)turnToSpecifiedCoverView:(NSInteger)index;
@end


@protocol SLCoverFlowViewDataSource <NSObject>
- (NSInteger)numberOfCovers:(SLCoverFlowView *)coverFlowView;
- (SLCoverView *)coverFlowView:(SLCoverFlowView *)coverFlowView coverViewAtIndex:(NSInteger)index;
@optional
- (void)coverFlowView:(SLCoverFlowView *)coverFlowView slideToIndex:(NSInteger)index;
@end
