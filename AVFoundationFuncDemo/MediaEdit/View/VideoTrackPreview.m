//
//  VideoTrackPreview.m
//  AVFoundationFuncDemo
//
//  Created by Lanht on 2020/6/30.
//  Copyright © 2020 gzfns. All rights reserved.
//

#import "VideoTrackPreview.h"
#import "SegmentClipView.h"

@implementation VideoTrackPreview

//重写该方法后可以让超出父视图范围的子视图响应事件
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            if ([subView isKindOfClass:[SegmentClipView class]]) {
                for (UIView *subsubView in subView.subviews) {
                    CGPoint tp = [subsubView convertPoint:point fromView:self];
                    if (CGRectContainsPoint(subsubView.bounds, tp)) {
                        view = subsubView;
                    }
                }
            }
        }
    }
    return view;
}


@end
