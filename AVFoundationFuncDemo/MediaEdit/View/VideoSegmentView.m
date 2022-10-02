//
//  VideoSegmentView.m
//  AVFoundationFuncDemo
//
//  Created by Lanht on 2020/6/11.
//  Copyright © 2020 gzfns. All rights reserved.
//

#import "VideoSegmentView.h"
#import <Masonry.h>
#import "ThumbnailCell.h"
#import "UIView+Frame.h"

@interface VideoSegmentView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong, readwrite) UICollectionView *videoThumbnailView;
@property (nonatomic, copy) NSMutableArray *imageSources;
@property (nonatomic, assign, readwrite) NSInteger currentItemNum;
@property (nonatomic, assign) CGFloat leftScale;
@property (nonatomic, assign) CGFloat widthScale;
@property (nonatomic, assign, readwrite) CGFloat leftConstraintsValue;

@end

@implementation VideoSegmentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUpData];
        [self setUpView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setUpData];
        [self setUpView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)setUpData {
    _scale = 1;
    _leftScale = 0;
    _widthScale = 1;
}

- (void)setUpView {
    self.clipsToBounds = YES;
    
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor redColor];
    view.clipsToBounds = YES;
    [self addSubview:view];
    _container = view;
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self);
    }];
    
    CGFloat height = CGRectGetHeight(self.frame);
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(height, height);
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:self.frame collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollEnabled = NO;
    collectionView.backgroundColor = [UIColor blueColor];
    [view addSubview:collectionView];
    self.videoThumbnailView = collectionView;
    
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([ThumbnailCell class]) bundle:nil] forCellWithReuseIdentifier:@"ThumbnailCell"];
    
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(view);
        make.width.mas_equalTo(@0);
    }];
}

- (void)setOriginalThumbnails:(NSArray *)originalThumbnails {
    _originalThumbnails = originalThumbnails;
    _currentThumbnails = [originalThumbnails copy];
    _currentItemNum = originalThumbnails.count;
    _imageSources = [NSMutableArray arrayWithArray:originalThumbnails];
    
    [self.videoThumbnailView reloadData];
}

- (CGFloat)thumbnailWidth {
    return self.width * self.widthScale;
}

- (void)resetImagesWhenWidthChange {
    NSInteger nums = ceilf(self.thumbnailWidth / itemWidth);
    //注意dis有可能为负数
    NSInteger dis = nums - _imageSources.count;
    if (dis >= 0) {
        for (int i = 0; i < dis; i++) {
            UIImage *image = self.imageSources.lastObject;

            [self.imageSources addObject:image];
        }
    } else {
        if (self.imageSources.count > 1) {
            [self.imageSources removeObjectsInRange:NSMakeRange(_imageSources.count - labs(dis) - 1, labs(dis))];
        }
    }
    _currentItemNum = self.imageSources.count;
    [self.videoThumbnailView reloadData];
    
    _currentThumbnails = [self.imageSources copy];
}

- (void)reloadViewWithIndex:(NSInteger)index image:(UIImage *)image {
    if (index >= _imageSources.count ) {
        return;
    }
    [self.imageSources replaceObjectAtIndex:index withObject:image];
    _currentThumbnails = [self.imageSources copy];
    
    //刷新
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.videoThumbnailView reloadItemsAtIndexPaths:@[indexPath]];
}

- (void)showDevider {
    [_container mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-2);
    }];
}

- (void)updateThumbnailConstraints {
    CGFloat left = self.width * self.leftScale;
    _leftConstraintsValue = left;
    
    [_videoThumbnailView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.offset(-left);
        make.width.mas_equalTo(@(self.width * self.widthScale));
    }];
}

- (void)setThumbnailLeftConstraint:(CGFloat)left width:(CGFloat)width {
    _leftConstraintsValue = left;
    [_videoThumbnailView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.offset(-left);
        make.width.mas_equalTo(@(width));
    }];
}

/**
 lSale thumbnailView左边距与segmentView宽度比
 wScale thumbnailView宽度与segmentView宽度比
 */
- (void)setLeftScale:(CGFloat)lSale widthScale:(CGFloat)wScale {
    _leftScale = lSale;
    _widthScale = wScale;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageSources.count;
//    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ThumbnailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThumbnailCell" forIndexPath:indexPath];
    
    UIImage *image = self.imageSources[indexPath.row];
    cell.thumbnailView.image = image;
    return cell;
}

@end
