//
//  HYSegmentedControl.m
//  CustomSegControlView
//
//  Created by sxzw on 14-6-12.
//  Copyright (c) 2014年 sxzw. All rights reserved.
//

#import "HYSegmentedControl.h"

#define HYSegmentedControl_Height 42.0
#define HYSegmentedControl_Width ([UIScreen mainScreen].bounds.size.width)
#define Min_Width_4_Button ([UIScreen mainScreen].bounds.size.width / 4)

#define Define_Tag_add 1000

#define UIColorFromRGBValue(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface HYSegmentedControl()

@property (strong, nonatomic)UIScrollView *scrollView;
@property (strong, nonatomic)NSMutableArray *array4Btn;
@property (strong, nonatomic)UIView *bottomLineView;

@end

@implementation HYSegmentedControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithOriginY:(CGFloat)y Titles:(NSArray *)titles delegate:(id)delegate drop:(BOOL)drop
{
    self.drop = drop;
    return [self initWithOriginY:y Titles:titles delegate:delegate];
}


- (id)initWithOriginY:(CGFloat)y Titles:(NSArray *)titles delegate:(id)delegate
{
    CGRect rect4View = CGRectMake(0, y, HYSegmentedControl_Width , HYSegmentedControl_Height);
    if (self = [super initWithFrame:rect4View]) {
        
//        self.backgroundColor = UIColorFromRGBValue(0xf3f3f3);
        self.backgroundColor = [UIColor whiteColor];
        [self setUserInteractionEnabled:YES];
        
        self.delegate = delegate;
        
        //
        //  array4btn
        //
        _array4Btn = [[NSMutableArray alloc] initWithCapacity:[titles count]];
        
        //
        //  set button
        //
        CGFloat width4btn = rect4View.size.width/[titles count];
        if (width4btn < Min_Width_4_Button) {
            width4btn = Min_Width_4_Button;
        }
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.backgroundColor = self.backgroundColor;
        _scrollView.userInteractionEnabled = YES;
        _scrollView.contentSize = CGSizeMake([titles count]*width4btn, HYSegmentedControl_Height);
        _scrollView.showsHorizontalScrollIndicator = NO;
        
        for (int i = 0; i<[titles count]; i++) {
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(i*width4btn, .0f, width4btn, HYSegmentedControl_Height);
            [btn setTitleColor:UIColorFromRGBValue(0x999999) forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            [btn setTitleColor:UIColorFromRGBValue(0x1D7AF8) forState:UIControlStateSelected];
            [btn setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(segmentedControlChange:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = Define_Tag_add+i;
            [_scrollView addSubview:btn];
            [_array4Btn addObject:btn];
            
            if (self.drop) {
                [btn setImage:[UIImage imageNamed:@"tiku-tra2-down"] forState:UIControlStateNormal];
                btn.titleEdgeInsets = UIEdgeInsetsMake(0, -btn.imageView.hd_width * 1.5 + 6, 0, 0);
                btn.imageEdgeInsets = UIEdgeInsetsMake(0, 110, 0, 0);
            }
            
            if (i == 0) {
                btn.selected = YES;
            }
        }
        
        
        CGFloat height4Line = HYSegmentedControl_Height - 10;
        CGFloat originY = (HYSegmentedControl_Height - height4Line)/2;
        for (int i = 1; i<[titles count]; i++) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(i*width4btn-1.0f, originY, 1.0f, height4Line)];
            lineView.backgroundColor = UIColorFromRGBValue(0xE6E6E6);
            [_scrollView addSubview:lineView];
        }
        
        //
        //  bottom lineView
        //
        
        UIView * bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, HYSegmentedControl_Height-1, HYSegmentedControl_Width, 1.0f)];
        bottomView.backgroundColor = UIColorFromRGBValue(0xC5C5C5);
        [_scrollView addSubview:bottomView];
        
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(.0f, HYSegmentedControl_Height-1, width4btn-0.0f, 1.0f)];
        _bottomLineView.backgroundColor = UIColorFromRGBValue(0x1D7AF8);
        [_scrollView addSubview:_bottomLineView];
        
        [self addSubview:_scrollView];
    }
    return self;
}

- (void)segmentedControlChange:(UIButton *)btn
{
    
    [UIView animateWithDuration:0.3 animations:^{
        btn.imageView.transform = CGAffineTransformRotate(btn.imageView.transform, M_PI);
    }];
    
    btn.selected = YES;
    for (UIButton *subBtn in self.array4Btn) {
        if (subBtn != btn) {
            subBtn.selected = NO;
            [UIView animateWithDuration:0.3 animations:^{
                subBtn.imageView.transform = CGAffineTransformMakeRotation(0);
            }];
        }
    }
    
    CGRect rect4boottomLine = self.bottomLineView.frame;
    rect4boottomLine.origin.x = btn.frame.origin.x;
    
    CGPoint pt = CGPointZero;
    BOOL canScrolle = NO;
    if ((btn.tag - Define_Tag_add) >= 2 && [_array4Btn count] > 4 && [_array4Btn count] > (btn.tag - Define_Tag_add + 2)) {
        pt.x = btn.frame.origin.x - Min_Width_4_Button*1.5f;
        canScrolle = YES;
    }else if ([_array4Btn count] > 4 && (btn.tag - Define_Tag_add + 2) >= [_array4Btn count]){
        pt.x = (_array4Btn.count - 4) * Min_Width_4_Button;
        canScrolle = YES;
    }else if (_array4Btn.count > 4 && (btn.tag - Define_Tag_add) < 2){
        pt.x = 0;
        canScrolle = YES;
    }
    
    if (canScrolle) {
        [UIView animateWithDuration:0.003 animations:^{
            _scrollView.contentOffset = pt;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.002 animations:^{
                self.bottomLineView.frame = rect4boottomLine;
            }];
        }];
    }else{
        [UIView animateWithDuration:0.002 animations:^{
            self.bottomLineView.frame = rect4boottomLine;
        }];
    }
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(hySegmentedControlSelectAtIndex:)]) {
        [self.delegate hySegmentedControlSelectAtIndex:btn.tag - 1000];
    }
}


#warning ////// index 从 0 开始
// delegete method
- (void)changeSegmentedControlWithIndex:(NSInteger)index
{
    if (index > [_array4Btn count]-1) {
        NSLog(@"index 超出范围");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"index 超出范围" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
        [alertView show];
        return;
    }
    
    UIButton *btn = [_array4Btn objectAtIndex:index];
    [self segmentedControlChange:btn];
}

- (void)clickBT:(NSInteger)index
{
    UIButton * bt = [_array4Btn   objectAtIndex:index];
    [self segmentedControlChange:bt];
}

- (void)changeTitle:(NSString *)title withIndex:(NSInteger)index
{
    UIButton * bt = [_array4Btn   objectAtIndex:index];
    [bt setTitle:title forState:UIControlStateNormal];
    
    if (self.drop) {
        bt.titleEdgeInsets = UIEdgeInsetsMake(0, -bt.imageView.hd_width * 1.5 + 6, 0, 0);
        bt.imageEdgeInsets = UIEdgeInsetsMake(0, 110, 0, 0);
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end