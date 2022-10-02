//
//  Editor.h
//  AVFoundationFuncDemo
//
//  Created by Lanht on 2020/6/11.
//  Copyright © 2020 gzfns. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Editor : NSObject

@property (nonatomic, readonly) CGFloat assetSeconds;
@property (nonatomic, readonly) AVAsset *asset;

- (instancetype)initWithAsset:(AVAsset *)asset;

- (CGFloat)getTimeWithAsset:(AVAsset *)asset;

- (void)imageGeneratorForPageNum:(NSInteger)pageNum callback:(void (^)(NSArray *images))callback;

- (void)imageGenerator:(AVAsset *)asset pageNum:(NSInteger)pageNum progress:(void(^)(NSInteger index, UIImage *image))progress end:(void (^)(NSArray *images))end;

- (CMTime)timeFromSeconds:(CGFloat)seconds;

@end

NS_ASSUME_NONNULL_END
