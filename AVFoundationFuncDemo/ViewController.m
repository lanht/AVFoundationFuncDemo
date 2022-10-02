//
//  ViewController.m
//  AVFoundationFuncDemo
//
//  Created by Lanht on 2020/6/5.
//  Copyright © 2020 gzfns. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MJRefresh/MJRefresh.h>

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableview;

@end

/**
 AVAsset功能：
 
 
 */
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    MJRefreshHeader *header = [MJRefreshHeader headerWithRefreshingBlock:^{
        
    }];
    self.tableview.mj_header = header;

}


- (void)avURLAsset {
    /**
     AVURLAsset对象的初始化方式是用url与字典作为参数.

     字典中的key是AVURLAssetPreferPreciseDurationAndTimingKey枚举中的值
     
     AVURLAssetPreferPreciseDurationAndTimingKey是一个Bool类型的值,他决定了是否应准备好指示精确的持续时间并按时间提供精确的随机访问。
     
     获取精确的时间需要大量的处理开销. 使用近似时间开销较小且可以满足播放功能.
        如果仅仅想播放asset,可以设置nil,它将默认为NO
        如果想要用asset做一个合成操作,我们需要一个精确的访问.则需要设置为true.
     */
    
    NSURL *url = [NSURL URLWithString:@""];
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:options];
    
}

- (void)avMutableComposition {
    AVMutableComposition *mComposition = [AVMutableComposition composition];
    
    //kCMPersistentTrackID_Invalid: 将自动为您生成唯一标识符并与轨道关联。
    AVMutableCompositionTrack *mcVideoTrack = [mComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *mcAudioTrack = [mComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];

    AVAsset *videoAsset = [[AVAsset alloc]init];
    AVAsset *anotherAsset = [[AVAsset alloc]init];
    
    AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    AVAssetTrack *anotherTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    
    [mcVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoTrack.timeRange.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    [mcVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, anotherTrack.timeRange.duration) ofTrack:anotherTrack atTime:kCMTimeZero error:nil];
    
    [mComposition mutableTrackCompatibleWithTrack:nil];
}

- (IBAction)paly:(id)sender {
    
}

@end
