//
//  VideoSegmentView.h
//  AVFoundationFuncDemo
//
//  Created by Lanht on 2020/6/11.
//  Copyright © 2020 gzfns. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern const CGFloat itemWidth;
@interface VideoSegmentView : UIView

@property (nonatomic, strong, readonly) UICollectionView *videoThumbnailView;
@property (nonatomic, copy) NSArray *originalThumbnails;
@property (nonatomic, copy, readonly) NSArray *currentThumbnails;
@property (nonatomic, assign, readonly) NSInteger currentItemNum;
@property (nonatomic, assign) CGFloat scale; // container.width / thumbnail.width;
@property (nonatomic, assign, readonly) CGFloat thumbnailWidth;
@property (nonatomic, assign, readonly) CGFloat leftConstraintsValue;

- (void)reloadViewWithIndex:(NSInteger)index image:(UIImage *)image;
- (void)showDevider;
- (void)updateThumbnailConstraints;
- (void)setThumbnailLeftConstraint:(CGFloat)left width:(CGFloat)width;
- (void)setLeftScale:(CGFloat)lSale widthScale:(CGFloat)wScale;
- (void)resetImagesWhenWidthChange;

@end

NS_ASSUME_NONNULL_END
