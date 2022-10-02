//
//  MediaTimelineContainer.h
//  AVFoundationFuncDemo
//
//  Created by Lanht on 2020/6/16.
//  Copyright © 2020 gzfns. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MediaTimelineContainerDelegate <NSObject>

- (void)mediaTimelineContainerDidZoom:(CGFloat)length;
- (void)mediaTimelineContainerEndZoom:(CGFloat)length;

@end

@interface MediaTimelineContainer : UIView

@property (nonatomic, weak) id<MediaTimelineContainerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
