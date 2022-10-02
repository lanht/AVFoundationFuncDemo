//
//  SegmentClipView.m
//  AVFoundationFuncDemo
//
//  Created by Lanht on 2020/6/28.
//  Copyright © 2020 gzfns. All rights reserved.
//

#import "SegmentClipView.h"
#import <Masonry.h>
#import "UIView+Frame.h"

@interface SegmentClipView ()

@property (nonatomic, strong) UIView *left;
@property (nonatomic, strong) UIView *right;
@property (nonatomic, assign) CGFloat rangeMinX;
@property (nonatomic, assign) CGFloat rangeMaxX;

@end

const static CGFloat clipCardWidth = 21;
@implementation SegmentClipView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (void)setUpView {
    UIView *left = [[UIView alloc]init];
    left.backgroundColor = [UIColor whiteColor];
    [self addSubview:left];
    [left mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.equalTo(self);
        make.width.mas_equalTo(@21);
    }];
    [self addPanForView:left];
    _left = left;
    
    UIView *right = [[UIView alloc]init];
    right.backgroundColor = [UIColor whiteColor];
    [self addSubview:right];
    [right mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self);
        make.width.mas_equalTo(@21);
    }];
    [self addPanForView:right];
    _right = right;
    
    UIView *top = [[UIView alloc]init];
    top.backgroundColor = [UIColor whiteColor];
    [self addSubview:top];
    [top mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo(@1.5);
    }];
    
    UIView *bottom = [[UIView alloc]init];
    bottom.backgroundColor = [UIColor whiteColor];
    [self addSubview:bottom];
    [bottom mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
        make.height.mas_equalTo(@1.5);
    }];

}

- (void)addPanForView:(UIView *)view {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [view addGestureRecognizer:pan];
}

- (void)changeWidth {
    
}

- (CGFloat)rangeMinX {
    if (self.datasource && [self.datasource respondsToSelector:@selector(segmentClipViewMinX:)] ) {
        _rangeMinX = [self.datasource segmentClipViewMinX:self];
        return _rangeMinX - clipCardWidth;
    }
    return 0;
}

- (CGFloat)rangeMaxX {
    if (self.datasource && [self.datasource respondsToSelector:@selector(segmentClipViewMaxX:)] ) {
        _rangeMaxX = [self.datasource segmentClipViewMaxX:self];
        return _rangeMaxX - clipCardWidth;
    }
    return 0;
}

- (void)pan:(UIPanGestureRecognizer *)gesture {
//    NSLog(@"rangMinX -- %f,rangMaxX -- %f", self.rangeMinX, self.rangeMaxX);
    if (self.rangeMaxX <= self.rangeMinX) {
        return;
    }
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        
    } else {
        
    }
    
    UIView *view = gesture.view;
    CGPoint translatePoint = [gesture translationInView:self];
    NSLog(@"translatePoint.x -- %f",translatePoint.x);
//    CGFloat changToX = view.x + translatePoint.x;
    
    CGFloat value = translatePoint.x;
    
    if (view == self.left) {
        CGFloat changToX = self.x + value;
        CGFloat maxX = CGRectGetMaxX(self.frame) - 2 * clipCardWidth;
        if (changToX < self.rangeMinX) {
            value = fabs(self.x - self.rangeMinX);

            self.x = self.rangeMinX;
            
        } else if (changToX > maxX) {
            value = fabs(self.x - maxX);

            self.x =  maxX;
            
        } else {
            self.x = changToX;

        }
        
        if (translatePoint.x >= 0) {
            self.width -= fabs(value);
            
        } else {
            self.width += fabs(value);
            
        }
    }
    
    if (view == self.right) {
        CGFloat maxWidth = self.rangeMaxX - self.rangeMinX;

        CGFloat maxX = CGRectGetMaxX(self.frame);
        CGFloat changToX = maxX + value;

        if (changToX < self.left.maxX) {
//            view.x = self.left.maxX;
            self.width = 2 * clipCardWidth + 1;
            
        } else if (changToX > self.rangeMaxX) {
            self.width = fabs(self.rangeMaxX - self.x);
            
        } else {
            self.width += value;
        }
        if (translatePoint.x >= 0) {
//            self.width = ((self.width + fabs(translatePoint.x)) > (self.rangeMaxX - self.rangeMinX))? (self.rangeMaxX - self.rangeMinX) : (self.width + fabs(translatePoint.x));
//            self.width = value;
        } else {
//            self.width = (self.width - fabs(translatePoint.x) < 0)? 0 : self.width - fabs(translatePoint.x);
//            self.width -= value;
        }
    }
    [gesture setTranslation:CGPointZero inView:self];
}

@end
