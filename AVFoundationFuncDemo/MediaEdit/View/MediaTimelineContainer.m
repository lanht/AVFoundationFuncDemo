//
//  MediaTimelineContainer.m
//  AVFoundationFuncDemo
//
//  Created by Lanht on 2020/6/16.
//  Copyright © 2020 gzfns. All rights reserved.
//

#import "MediaTimelineContainer.h"

@interface MediaTimelineContainer ()

@property (nonatomic, assign) CGPoint firstZoomPoint;
@property (nonatomic, assign) CGPoint secondZoomPoint;
@property (nonatomic, assign) CGFloat lastLength;

@end

@implementation MediaTimelineContainer

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self setUpView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        
        [self setUpView];
    }
    return self;
}

- (void)setUpView {
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinch:)];
    [self addGestureRecognizer:pinchGesture];
}

- (void)pinch:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan ) {
        CGPoint point1 = [recognizer locationOfTouch:0 inView:self.window];
        CGPoint point2 = [recognizer locationOfTouch:1 inView:self.window];
    
        _firstZoomPoint = point1;
        _secondZoomPoint = point2;
        _lastLength = [self getLength:point1 another:point2];
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (recognizer.numberOfTouches < 2) {
            return;
        }
        CGPoint point1 = [recognizer locationOfTouch:0 inView:self.window];
        CGPoint point2 = [recognizer locationOfTouch:1 inView:self.window];

        CGFloat length = [self getLength:point1 another:point2];
        
        CGFloat l1 = [self getLength:_firstZoomPoint another:point1];
        CGFloat l2 = [self getLength:_secondZoomPoint another:point2];
//        NSLog(@"l1 - %f,l2 - %f",l1,l2);
        
        CGFloat l = (length > _lastLength) ? (l1 + l2) : (-l1 -l2);
        _lastLength = length;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(mediaTimelineContainerDidZoom:)]) {
            [self.delegate mediaTimelineContainerDidZoom:l];
        }
        
        _firstZoomPoint = point1;
        _secondZoomPoint = point2;
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mediaTimelineContainerEndZoom:)]) {
            [self.delegate mediaTimelineContainerEndZoom:recognizer.scale];
        }
        
        _firstZoomPoint = CGPointZero;
        _secondZoomPoint = CGPointZero;
    }
    
}

- (CGFloat)getLength:(CGPoint)point1 another:(CGPoint)point2 {
    return hypotf(fabs(point1.x - point2.x), fabs(point1.y - point2.y));
}

@end
