//
//  VideoAudioWaveTrackView.m
//  AVFoundationFuncDemo
//
//  Created by Lanht on 2020/6/15.
//  Copyright © 2020 gzfns. All rights reserved.
//

#import "VideoAudioWaveTrackView.h"
#import <Masonry.h>

@implementation VideoAudioWaveTrackView

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
    UIView *view = [[UIView alloc]init];
    [self addSubview:view];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self);
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"添加音频" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    [view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(10);
        make.centerY.equalTo(view);
    }];
}

@end
