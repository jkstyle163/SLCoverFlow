//
//  ViewController.m
//  SLCoverFlow
//
//  Created by jiapq on 13-6-13.
//  Copyright (c) 2013年 HNAGroup. All rights reserved.
//

#import "ViewController.h"
#import "SLCoverFlowView.h"
#import "SLCoverView.h"

static const CGFloat SLCoverViewWidth = 200.0;
static const CGFloat SLCoverViewHeight = 150.0;
static const CGFloat SLCoverViewSpace = 100.0;
static const CGFloat SLCoverViewAngle = M_PI_4;
static const CGFloat SLCoverViewScale = 1.0;

@interface ViewController () <SLCoverFlowViewDataSource> {
    SLCoverFlowView *_coverFlowView;
    NSMutableArray *_colors;
    
    UISlider *_widthSlider;
    UISlider *_heightSlider;
    UISlider *_spaceSlider;
    UISlider *_angleSlider;
    UISlider *_scaleSlider;
}

@end

@implementation ViewController

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];

    CGRect frame = self.view.bounds;
    frame.size.height /= 2.0;
    _coverFlowView = [[SLCoverFlowView alloc] initWithFrame:frame];
    _coverFlowView.backgroundColor = [UIColor lightGrayColor];
    _coverFlowView.delegate = self;
    _coverFlowView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _coverFlowView.coverSize = CGSizeMake(SLCoverViewWidth, SLCoverViewHeight);
    _coverFlowView.coverSpace = 0.0;
    _coverFlowView.coverAngle = 0.0;
    _coverFlowView.coverScale = 1.0;
    [self.view addSubview:_coverFlowView];
    
    // width
    frame = CGRectMake(10.0, CGRectGetMaxY(frame) + 10.0, 200.0, 20.0);
    _widthSlider = [self createSliderWithFrame:frame];
    [self.view addSubview:_widthSlider];
    _coverFlowView.coverSize = CGSizeMake(SLCoverViewWidth * _widthSlider.value,
                                              _coverFlowView.coverSize.height);
    
    // height
    frame = CGRectMake(10.0, CGRectGetMaxY(frame) + 10.0, 200.0, 20.0);
    _heightSlider = [self createSliderWithFrame:frame];
    [self.view addSubview:_heightSlider];
    _coverFlowView.coverSize = CGSizeMake(_coverFlowView.coverSize.width,
                                              SLCoverViewHeight * _heightSlider.value);
    
    // space
    frame = CGRectMake(10.0, CGRectGetMaxY(frame) + 10.0, 200.0, 20.0);
    _spaceSlider = [self createSliderWithFrame:frame];
    _spaceSlider.minimumValue = -2.0;
    _spaceSlider.maximumValue = 2.0;
    _spaceSlider.value = 0.0;
    [self.view addSubview:_spaceSlider];
    _coverFlowView.coverSpace = _spaceSlider.value * SLCoverViewSpace;
    
    // angle
    frame = CGRectMake(10.0, CGRectGetMaxY(frame) + 10.0, 200.0, 20.0);
    _angleSlider = [self createSliderWithFrame:frame];
    [self.view addSubview:_angleSlider];
    _coverFlowView.coverAngle = _angleSlider.value * SLCoverViewAngle;
    
    // scale
    frame = CGRectMake(10.0, CGRectGetMaxY(frame) + 10.0, 200.0, 20.0);
    _scaleSlider = [self createSliderWithFrame:frame];
    [self.view addSubview:_scaleSlider];
    _coverFlowView.coverScale = _scaleSlider.value * SLCoverViewScale;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _colors = [NSMutableArray arrayWithCapacity:50];
    for (NSInteger i = 0; i < 50; ++i) {
        float red = rand() % 255;
        float green = rand() % 255;
        float blue = rand() % 255;
        UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
        [_colors addObject:color];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_coverFlowView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)valueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    if ([slider isEqual:_widthSlider]) {
        _coverFlowView.coverSize = CGSizeMake(SLCoverViewWidth * _widthSlider.value,
                                                  _coverFlowView.coverSize.height);
    } else if ([slider isEqual:_heightSlider]) {
        _coverFlowView.coverSize = CGSizeMake(_coverFlowView.coverSize.width,
                                                  SLCoverViewHeight * _heightSlider.value);
    } else if ([slider isEqual:_spaceSlider]) {
        _coverFlowView.coverSpace = _spaceSlider.value * SLCoverViewSpace;
    } else if ([slider isEqual:_angleSlider]) {
        _coverFlowView.coverAngle = _angleSlider.value * SLCoverViewAngle;
    } else if ([slider isEqual:_scaleSlider]) {
        _coverFlowView.coverScale = _scaleSlider.value * SLCoverViewScale;
    }
}

#pragma mark - SLCoverFlowViewDataSource 

- (NSInteger)numberOfCovers:(SLCoverFlowView *)coverFlowView {
    return _colors.count;
}

- (SLCoverView *)coverFlowView:(SLCoverFlowView *)coverFlowView coverViewAtIndex:(NSInteger)index {
    SLCoverView *view = [[SLCoverView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)];
    view.backgroundColor = [_colors objectAtIndex:index];
    return view;
}

#pragma mark - Private methods

- (UISlider *)createSliderWithFrame:(CGRect)frame {
    UILabel *static 
    UISlider *slider = [[UISlider alloc] initWithFrame:frame];
    slider.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    slider.minimumValue = 0.0;
    slider.maximumValue = 2.0;
    slider.value = 1.0;
    [slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    return slider;
}

@end
