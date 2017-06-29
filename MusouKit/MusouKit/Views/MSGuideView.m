//
//  MSGuideView.m
//  Pods
//
//  Created by DANAL LUO on 29/06/2017.
//
//

#import "MSGuideView.h"
#import "DLAutoLayout.h"

@interface MSGuideView ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    __weak UICollectionView *_collection;
}
@end

@implementation MSGuideView

- (id)init{
    self = [super init];
    if (self){
        if (!_collection){
            
            UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout.minimumInteritemSpacing = 0;
            layout.minimumLineSpacing = 0;
            
            UICollectionView *collection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
            [self addSubview:collection];
            _collection = collection;
            _collection.dl_begin(self).edge(0).dl_end();
            
            [_collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
            _collection.dataSource = self;
            _collection.delegate = self;
            _collection.pagingEnabled = YES;
            _collection.showsHorizontalScrollIndicator = NO;
            self.backgroundColor = _collection.backgroundColor = [UIColor whiteColor];
            
            UIPageControl *pageControl = [[UIPageControl alloc] init];
            pageControl.userInteractionEnabled = NO;
            [self addSubview:pageControl];
            _pageControl = pageControl;
            _pageControl.dl_begin(self).dl_relativeTo(self).width(0).dl_end();
            _pageControl.dl_begin(self).bottom(-10).dl_end();
        }

    }
    return self;
}

- (void)show{
    UIView *parent = [UIApplication sharedApplication].delegate.window;
    [parent addSubview:self];
    self.frame = parent.bounds;
    _pageControl.numberOfPages = self.images.count;
    
    _enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _enterButton.frame = CGRectMake(0, 0, 90, 30);
    _enterButton.layer.borderWidth = 1.0;
    _enterButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _enterButton.layer.cornerRadius = 15;
    _enterButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _enterButton.userInteractionEnabled = NO;
    [_enterButton setTitle:NSLocalizedString(@"开始体验", nil) forState:UIControlStateNormal];
    
}

- (void)dismiss{
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _images.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UIImageView *imgv = (id)[cell viewWithTag:100];
    if (!imgv){
        imgv = [[UIImageView alloc] initWithFrame:cell.bounds];
        imgv.tag = 100;
        imgv.clipsToBounds = YES;
        imgv.contentMode = UIViewContentModeScaleAspectFill;
        [cell addSubview:imgv];
    }
    imgv.image = self.images[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.item == self.images.count-1){
        [cell addSubview:_enterButton];
        _enterButton.dl_begin(cell).bottom(-60).dl_end();
        _enterButton.dl_begin(cell).alignCenterX(0).dl_end();
        _enterButton.dl_begin(cell).width(_enterButton.bounds.size.width).height(_enterButton.bounds.size.height).dl_end();
        
    } else {
        [_enterButton removeFromSuperview];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item == self.images.count-1){
        [self dismiss];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.bounds.size.width, self.bounds.size.height);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _pageControl.currentPage = scrollView.contentOffset.x/scrollView.bounds.size.width;
}

@end
