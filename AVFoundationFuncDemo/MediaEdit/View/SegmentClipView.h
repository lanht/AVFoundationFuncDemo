//
//  SegmentClipView.h
//  AVFoundationFuncDemo
//
//  Created by Lanht on 2020/6/28.
//  Copyright © 2020 gzfns. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SegmentClipView;
@protocol SegmentClipViewDataSource <NSObject>

@required
- (CGFloat)segmentClipViewMinX:(SegmentClipView *)segmentClipView;
- (CGFloat)segmentClipViewMaxX:(SegmentClipView *)segmentClipView;

@end

@protocol SegmentClipViewDataDelegate <NSObject>

@end

@interface SegmentClipView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<SegmentClipViewDataSource> datasource;
@property (nonatomic, weak) id<SegmentClipViewDataDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
