//
//  ViewController.m
//  SLCoverFlow
//
//  Created by SmartCat on 13-6-13.
//  Copyright (c) 2013年 SmartCat. All rights reserved.
//

#import "ViewController.h"
#import "SLCoverFlowView.h"
#import "SLCoverView.h"

static const CGFloat SLCoverViewWidth = 150.0;
static const CGFloat SLCoverViewHeight = 100.0;
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
    frame.size.height /= 3.0;
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
    _widthSlider = [self addSliderWithMinY:(CGRectGetMaxY(_coverFlowView.frame) + 20.0) labelText:@"Width:"];
    _coverFlowView.coverSize = CGSizeMake(SLCoverViewWidth * _widthSlider.value,
                                              _coverFlowView.coverSize.height);
    
    // height
    _heightSlider = [self addSliderWithMinY:(CGRectGetMaxY(_widthSlider.frame) + 20.0) labelText:@"Height:"];
    [self.view addSubview:_heightSlider];
    _coverFlowView.coverSize = CGSizeMake(_coverFlowView.coverSize.width,
                                              SLCoverViewHeight * _heightSlider.value);
    
    // space
    _spaceSlider = [self addSliderWithMinY:(CGRectGetMaxY(_heightSlider.frame) + 20.0) labelText:@"Space:"];
    _coverFlowView.coverSpace = _spaceSlider.value * SLCoverViewSpace;
    
    // angle
    _angleSlider = [self addSliderWithMinY:(CGRectGetMaxY(_spaceSlider.frame) + 20.0) labelText:@"Angle:"];
    _coverFlowView.coverAngle = _angleSlider.value * SLCoverViewAngle;
    
    // scale
    _scaleSlider = [self addSliderWithMinY:(CGRectGetMaxY(_angleSlider.frame) + 20.0) labelText:@"Scale:"];
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

- (UISlider *)addSliderWithMinY:(CGFloat)minY labelText:(NSString *)labelText {
    CGRect labelFrame = CGRectMake(20.0, minY, 80.0, 30.0);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:22.0];
    label.text = labelText;
    label.textColor = [UIColor darkTextColor];
    [self.view addSubview:label];
    
    CGRect sliderFrame = CGRectMake(CGRectGetMaxX(labelFrame) + 20.0, minY, 200.0, 30.0);
    sliderFrame.size.width = CGRectGetWidth(self.view.bounds) - CGRectGetMaxX(labelFrame) - 40.0;
    UISlider *slider = [[UISlider alloc] initWithFrame:sliderFrame];
    slider.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    slider.minimumValue = 0.0;
    slider.maximumValue = 2.0;
    slider.value = 1.0;
    [slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    return slider;
}

@end
