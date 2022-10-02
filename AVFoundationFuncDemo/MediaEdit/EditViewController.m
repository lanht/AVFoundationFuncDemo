//
//  EditViewController.m
//  AVFoundationFuncDemo
//
//  Created by Lanht on 2020/6/8.
//  Copyright © 2020 gzfns. All rights reserved.
//

#import "EditViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Editor.h"
#import "VideoSegmentView.h"
#import "MediaTimeline.h"
#import "MediaTimelineContainer.h"
#import <Masonry.h>
#import "UIView+Frame.h"
#import "SegmentClipView.h"
#import "VideoTrackPreview.h"

@interface EditViewController ()<UIScrollViewDelegate, MediaTimelineContainerDelegate, SegmentClipViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *editBgView;

@property (weak, nonatomic) IBOutlet UIView *preview;
@property (weak, nonatomic) IBOutlet MediaTimeline *mediaTimeline;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoTrackPreviewLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoTrackPreviewTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoTrackPreviewWidth;
@property (weak, nonatomic) IBOutlet UIView *timelineContainer;
@property (weak, nonatomic) IBOutlet VideoTrackPreview *videoTrackPreview;
@property (weak, nonatomic) IBOutlet UIView *videoTrackPreviewContainer;
@property (weak, nonatomic) IBOutlet MediaTimelineContainer *mediaTimelineContainer;
@property (weak, nonatomic) IBOutlet UIView *pointerView;

@property (nonatomic, strong) Editor *editor;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, assign) BOOL isSeeking;
@property (nonatomic, assign) CGFloat offsetScale;
@property (nonatomic, assign) BOOL isZoom;
@property (nonatomic, strong) VideoSegmentView *selectedSegmentView;
@property (nonatomic, copy) NSMutableArray *segmentViews;
@property (nonatomic, assign) CGFloat zoomScale;
@property (nonatomic, strong) SegmentClipView *segmentClipView;


@end
/**
 剪映操作：先将多个视频合成，再进行编辑
 
 视频处理：
    分割，（添加转场）
    变速，
    动画：入场，出场，综合
    编辑：镜像，旋转，裁剪
    画中画：
    特效：
    滤镜：新增滤镜，新增调节
    调节：亮度，对比度，饱和度，锐化，高光，阴影，色温，色调，褪色

 音频处理：
    音乐
    音效
    提取音乐
    录音
 */

/**
  实现的难点：
    1，水平缩放：利用手势
    2.根据宽度生成指定个数缩略图：计算总宽/每个cell宽
    3.滚动位置转换成视频播放时间位置
    4.视图分割
 */

// segment的宽度是某一个倍数

const CGFloat itemWidth = 50;

@implementation EditViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _zoomScale = 1;
    [self setupView];
    [self setUpMedia];
}

//预览
- (void)display:(AVAsset *)asset {
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    AVPlayer *player = [[AVPlayer alloc]initWithPlayerItem:item];
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
    layer.frame = self.preview.bounds;
    [self.preview.layer addSublayer:layer];
    _player = player;
    
    [player seekToTime:kCMTimeZero];
//    [player play];
    [player pause];
}

- (void)dealVideoTrack {
    AVAssetWriter *wt;
}

- (void)dealAudioTrack {
    
}

- (void)setupView {
    self.mediaTimeline.showsVerticalScrollIndicator = NO;
    self.mediaTimeline.showsHorizontalScrollIndicator = NO;
    
    self.mediaTimelineContainer.delegate = self;
    
    UITapGestureRecognizer *videoTrackPreviewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(videoTrackPreviewTap:)];
    [self.videoTrackPreview addGestureRecognizer:videoTrackPreviewTap];
}

- (void)setUpMedia {
    NSURL *path = [[NSBundle mainBundle] URLForResource:@"IMG" withExtension:@"mov"];
//    AVURLAssetPreferPreciseDurationAndTimingKey 获取精确时间 通常不会再播放时使用
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
    AVURLAsset *assert = [AVURLAsset URLAssetWithURL:path options:nil];
    AVAssetTrack *videoTrack = [[assert tracksWithMediaType:AVMediaTypeVideo] firstObject];
    AVAssetTrack *audioTrack = [[assert tracksWithMediaType:AVMediaTypeAudio] firstObject];
    
    NSLog(@"videoTrack.nominalFrameRate -- %f",videoTrack.nominalFrameRate);
    NSLog(@"v --- %f ",CMTimeGetSeconds(videoTrack.asset.duration) * videoTrack.nominalFrameRate);
    AVMutableComposition *avMcp = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoMcpTrack = [avMcp addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioMcpTrack = [avMcp addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    if (videoMcpTrack) {
        [videoMcpTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    }
    
    if (audioTrack) {
        [audioMcpTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioTrack.timeRange.duration) ofTrack:audioTrack atTime:kCMTimeZero error:nil];
    }
    
    self.editor = [[Editor alloc]initWithAsset:avMcp];
    
    [self display:avMcp];
    
    CGFloat videoPreviewWidth = [self.editor getTimeWithAsset:assert] * 50.;

    NSInteger num = ceilf(CMTimeGetSeconds(avMcp.duration));
    [self.editor imageGeneratorForPageNum:num callback:^(NSArray * _Nonnull images) {
        VideoSegmentView *newSegment = [self insertNewSegmentWithIndex:0 thumbnails:images width:videoPreviewWidth];
        [newSegment setThumbnailLeftConstraint:0 width:newSegment.width];

    }];
    // 宽度 时间
    //133.9  27  1339.3
    //27.19  6   271.9  8157
    self.videoTrackPreviewWidth.constant = videoPreviewWidth;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat interval =  CGRectGetWidth(self.view.bounds) / 2.0;
    self.videoTrackPreviewLeading.constant = interval;
    self.videoTrackPreviewTrailing.constant = interval;

}

- (NSMutableArray *)segmentViews {
    if (!_segmentViews) {
        _segmentViews = [NSMutableArray array];
    }
    return _segmentViews;
}

- (SegmentClipView *)segmentClipView {
    if (!_segmentClipView) {
        _segmentClipView = [[SegmentClipView alloc]initWithFrame:CGRectZero];
        _segmentClipView.hidden = YES;
        _segmentClipView.datasource = self;
        [self.videoTrackPreview addSubview:_segmentClipView];
    }
    return _segmentClipView;
}

- (void)videoTrackPreviewTap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self.videoTrackPreview];
    
    __block VideoSegmentView *selectSegment;
    [self.segmentViews enumerateObjectsUsingBlock:^(VideoSegmentView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(obj.frame, CGPointMake(point.x, obj.y + 1))) {
            selectSegment = obj;
            *stop = YES;
        }
    }];
    
    if (selectSegment && self.selectedSegmentView != selectSegment) {
        self.segmentClipView.frame = CGRectMake(selectSegment.x - 21, selectSegment.y - 1.5, selectSegment.width + 40, selectSegment.height + 3);
        self.segmentClipView.hidden = NO;
        [tap.view bringSubviewToFront:self.segmentClipView];
        
        self.selectedSegmentView = selectSegment;
        
    } else {
        self.selectedSegmentView = nil;
        self.segmentClipView.hidden = YES;
    }
}

- (IBAction)play:(id)sender {

}

- (IBAction)clip:(id)sender {
    if (!self.selectedSegmentView) {
        return;
    }
    self.segmentClipView.hidden = YES;
    
    CGPoint point = [self.editBgView convertPoint:CGPointMake(self.pointerView.x, self.pointerView.y) toView:self.selectedSegmentView];
    
    CGFloat totalWidth = self.selectedSegmentView.width;
    CGFloat thumbnailLength = self.selectedSegmentView.thumbnailWidth;

    CGFloat newSegmentWidth = totalWidth - point.x;
    CGRect rect = CGRectMake(self.selectedSegmentView.x + point.x, CGRectGetMinY(self.selectedSegmentView.frame), newSegmentWidth, CGRectGetHeight(self.selectedSegmentView.frame));
    
    NSInteger index = [self.segmentViews indexOfObject:self.selectedSegmentView];
    VideoSegmentView *newSegment = [self insertNewSegmentWithIndex:index + 1 thumbnails:self.selectedSegmentView.currentThumbnails width:newSegmentWidth];
    newSegment.frame = rect;
    [newSegment showDevider];
    
    [newSegment setThumbnailLeftConstraint:self.selectedSegmentView.leftConstraintsValue +  point.x width:thumbnailLength];
    [newSegment setLeftScale:(self.selectedSegmentView.leftConstraintsValue +  point.x) / newSegmentWidth widthScale:thumbnailLength / newSegmentWidth];
    
    self.selectedSegmentView.width = point.x;
    [self.selectedSegmentView showDevider];
    [self.selectedSegmentView setLeftScale:self.selectedSegmentView.leftConstraintsValue / point.x widthScale:thumbnailLength / point.x];
    self.selectedSegmentView = nil;
}

- (VideoSegmentView *)insertNewSegmentWithIndex:(NSInteger)index thumbnails:(NSArray *)thumbnails width:(CGFloat)width {
    VideoSegmentView *newSegment = [[VideoSegmentView alloc]initWithFrame:CGRectMake(0, 0, width, self.videoTrackPreviewContainer.bounds.size.height)];
    newSegment.originalThumbnails = thumbnails;
    [self.videoTrackPreview addSubview:newSegment];
    [self.segmentViews insertObject:newSegment atIndex:index];
    return newSegment;
}

- (IBAction)delete:(id)sender {
    if (!self.selectedSegmentView || self.segmentViews.count < 2) {
        return;
    }
    NSInteger index = [self.segmentViews indexOfObject:self.selectedSegmentView];
    [self deletSegmentWithIndex:index];
}

- (void)deletSegmentWithIndex:(NSInteger)index {
    VideoSegmentView *segment = self.segmentViews[index];
    [segment removeFromSuperview];
    [self.segmentViews removeObject:segment];
    [self resetSegmentsLayoutWhenDelete];
    [self resetVideoTrackPreviewWidth];
    
    self.segmentClipView.hidden = YES;
    self.selectedSegmentView = nil;
}

- (void)resetSegmentsLayoutWhenZoom {
    __block VideoSegmentView *last;
    [self.segmentViews enumerateObjectsUsingBlock:^(VideoSegmentView *  _Nonnull segmentView, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat changeLength = segmentView.width * _zoomScale;
        segmentView.width += changeLength;
        segmentView.x = last.x + last.width;
        [segmentView updateThumbnailConstraints];
        [segmentView resetImagesWhenWidthChange];
        last = segmentView;
    }];
}

- (void)resetSegmentsLayoutWhenDelete {
    __block VideoSegmentView *last;
    [self.segmentViews enumerateObjectsUsingBlock:^(VideoSegmentView *  _Nonnull segmentView, NSUInteger idx, BOOL * _Nonnull stop) {
        segmentView.x = last.x + last.width;
        last = segmentView;
    }];
}

- (void)resetVideoTrackPreviewWidth {
    VideoSegmentView *lastSegment = self.segmentViews.lastObject;
    CGFloat width = CGRectGetMaxX(lastSegment.frame);
    self.videoTrackPreviewWidth.constant = width;
}

- (void)resetClipViewLayout {
    self.segmentClipView.x = self.selectedSegmentView.x - 21;
    self.segmentClipView.width = self.selectedSegmentView.width + 40;
}

#pragma mark - 导出
// 导出合成视频

//两个问题
//presetName 的作用
//AVFileType 各个类型的含义

- (void)exportCompsition:(AVAsset *)asset {
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    session.outputFileType = AVFileTypeMPEG4;
    session.outputURL = [NSURL URLWithString:@""];
    session.shouldOptimizeForNetworkUse = YES;
//    session.videoComposition =
    [session exportAsynchronouslyWithCompletionHandler:^{
        
    }];
    
}

- (void)exportVideo:(AVAsset *)video {
    // presetNames 本视频支持导出的格式   AVAssetExportPresetPassthrough 为模拟器支持格式
    NSArray *presetNames = [AVAssetExportSession exportPresetsCompatibleWithAsset:video];
    
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:video presetName:(presetNames.firstObject ?: AVAssetExportPresetPassthrough)];
    session.outputFileType = AVFileTypeMPEG4;
    session.outputURL = [NSURL URLWithString:@""];
    [session exportAsynchronouslyWithCompletionHandler:^{
        
    }];
}

- (void)expotAudio:(AVAsset *)audio {
    NSArray *presetNames = [AVAssetExportSession exportPresetsCompatibleWithAsset:audio];
    
    AVAssetExportSession *session;
    if ([presetNames containsObject:AVAssetExportPresetAppleM4A]) {
        session = [[AVAssetExportSession alloc]initWithAsset:audio presetName:AVAssetExportPresetAppleM4A];
        
    } else {
        session = [[AVAssetExportSession alloc]initWithAsset:audio presetName:AVAssetExportPresetPassthrough];

    }
    
    session.outputFileType = AVFileTypeAppleM4A;
    session.outputURL = [NSURL URLWithString:@""];
    [session exportAsynchronouslyWithCompletionHandler:^{
        
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_isZoom) {
        return;
    }
    _offsetScale = scrollView.contentOffset.x / self.videoTrackPreviewWidth.constant;
    CMTime time = [self.editor timeFromSeconds:self.editor.assetSeconds * _offsetScale];

    if (!_isSeeking) {
        _isSeeking = YES;
        __weak typeof(self) weakSelf = self;
        [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            weakSelf.isSeeking = NO;
        }];
    }
}

#pragma mark - MediaTimelineContainerDelegate
- (void)mediaTimelineContainerDidZoom:(CGFloat)length {
    _isZoom = YES;
    
    if (length < 0 && (self.videoTrackPreviewWidth.constant + length < 50)) {
        return;
    }
    
    CGFloat width = self.videoTrackPreviewWidth.constant + length;
    
    _zoomScale = length / self.videoTrackPreviewWidth.constant;
    [self resetSegmentsLayoutWhenZoom];
    [self resetClipViewLayout];
    
    CGFloat offsetX = width * _offsetScale;

    self.videoTrackPreviewWidth.constant = width;
    [_mediaTimeline setContentOffset:CGPointMake(offsetX, 0) animated:NO];

}

- (void)mediaTimelineContainerEndZoom:(CGFloat)length {
    _isZoom = NO;
    _zoomScale = 1;
    
    [self.segmentViews enumerateObjectsUsingBlock:^(VideoSegmentView *  _Nonnull segment, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger num = segment.currentItemNum;
        [self.editor imageGenerator:self.editor.asset pageNum:num progress:^(NSInteger index, UIImage * _Nonnull image) {
            [segment reloadViewWithIndex:index image:image];
            
        } end:^(NSArray * _Nonnull images) {
            
        }];
    }];
}

#pragma mark - SegmentClipViewDataSource
- (CGFloat)segmentClipViewMinX:(SegmentClipView *)segmentClipView {
    UIView *thumbnailView = [self.selectedSegmentView videoThumbnailView];
    CGPoint point = [self.selectedSegmentView convertPoint:thumbnailView.frame.origin toView:self.videoTrackPreview];
    return point.x;
}

- (CGFloat)segmentClipViewMaxX:(SegmentClipView *)segmentClipView {
    UIView *thumbnailView = [self.selectedSegmentView videoThumbnailView];
    CGRect rect = [self.selectedSegmentView convertRect:thumbnailView.frame toView:self.videoTrackPreview];
    return CGRectGetMaxX(rect);
}

@end
