//
//  Editor.m
//  AVFoundationFuncDemo
//
//  Created by Lanht on 2020/6/11.
//  Copyright © 2020 gzfns. All rights reserved.
//

#import "Editor.h"

@interface Editor ()

@property (nonatomic, readwrite) CGFloat assetSeconds;
@property (nonatomic, readwrite) AVAsset *asset;

@end

@implementation Editor

- (instancetype)initWithAsset:(AVAsset *)asset {
    if (self = [super init]) {
        _asset = asset;
    }
    return self;
}

- (void)setUpAssetMedata {
    
}

- (CGFloat)assetSeconds {
    return [self getTimeWithAsset:_asset];
}

- (CMTime)timeFromSeconds:(CGFloat)seconds {
    AVAssetTrack *track = [[self.asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    if (!track) {
        return kCMTimeZero;
    }
    CGFloat fps = [track nominalFrameRate];
    
    CMTime time = CMTimeMakeWithSeconds(seconds, fps);
    return time;
}

- (CGFloat)getTimeWithAsset:(AVAsset *)asset {
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    if (!track) {
        return 0;
    }

    return CMTimeGetSeconds(asset.duration);;
}

- (void)imageGeneratorForPageNum:(NSInteger)pageNum callback:(void (^)(NSArray *images))callback {
    [self imageGenerator:self.asset pageNum:pageNum progress:nil end:callback];
}

// 生成一系列图像
- (void)imageGenerator:(AVAsset *)asset pageNum:(NSInteger)pageNum progress:( void(^)(NSInteger index, UIImage *image))progress end:(void (^)(NSArray *images))end {
    AVAssetTrack *track = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    if (!track) {
        return;
    }
    
    CMTimeScale timeScale = asset.duration.timescale;
    CMTimeValue value = asset.duration.value;
    
    NSMutableArray *times = [NSMutableArray array];
    for (int i = 0; i < pageNum; i++) {
        CMTimeValue itemValue = i * 1.0 / pageNum * value;
        CMTime time = CMTimeMake(itemValue, timeScale);
        CMTimeShow(time);
        NSValue *value = [NSValue valueWithCMTime:time];
        [times addObject:value];
    }
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    imageGenerator.maximumSize = CGSizeMake(100, 100);
    imageGenerator.appliesPreferredTrackTransform =YES;
    
    dispatch_async(dispatch_queue_create(0, 0), ^{
        NSMutableArray *images = [NSMutableArray array];
        [imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
            switch (result) {
                case AVAssetImageGeneratorSucceeded: {
                    NSValue *value = [NSValue valueWithCMTime:requestedTime];
                    NSInteger index = [times indexOfObject:value];
#warning 缩略图生成需要改
                    UIImage *img = [UIImage imageWithCGImage:image];
                    [images addObject:img];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (progress) {
                            progress(index, img);
                        }
                    });
                    
                    if (times.count == images.count) {
                        [imageGenerator cancelAllCGImageGeneration];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (end) {
                                end(images);
                            }
                        });
                    }
                }
                    break;
                case AVAssetImageGeneratorFailed:
                case AVAssetImageGeneratorCancelled:
                    NSLog(@"err -- %@",error.localizedDescription);
                default:
                    break;
            }
        }];
    });
    
}

@end
