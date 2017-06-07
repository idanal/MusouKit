//
//  MSSegmentController.m
//  
//
//  Created by DANAL LUO on 2017/6/7.
//
//

#import "MSSegmentController.h"
#import "MSAdditions.h"

@interface MSSegmentController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    IBOutlet __weak UICollectionView *_titleView;
    IBOutlet __weak UICollectionView *_controllerView;
    __weak UIView *_indicator;
    CGFloat _scaleX;
}
@end

@implementation MSSegmentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self _setupTitleView];
    [self _setupControllerView];
    
    //Indicator
    UIView *indicator = [[UIView alloc] initWithFrame:CGRectZero];
    indicator.backgroundColor = [UIColor redColor];
    [_titleView addSubview:indicator];
    _indicator = indicator;
    
    //Default values
    _segmentWidth = 80.0;
    _animatedSelectController = YES;
    _normalTitleFont = [UIFont systemFontOfSize:14];
    _selectedTitleFont = [UIFont systemFontOfSize:15];
    _normalTitleColor = [UIColor darkGrayColor];
    _selectedTitleColor = [UIColor redColor];
}

- (void)_setupTitleView{
    if (!_titleView){
        CGRect rect = CGRectMake(0, 0, self.view.bounds.size.width, 40);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        UICollectionView *cv = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        cv.backgroundColor = self.view.backgroundColor;
        cv.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:cv];
        _titleView = cv;
    }
    _titleView.showsHorizontalScrollIndicator = NO;
    [_titleView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

- (void)_setupControllerView{
    if (!_controllerView){
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        UICollectionView *cv = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        cv.backgroundColor = self.view.backgroundColor;
        cv.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:cv];
        _controllerView = cv;
    }
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_controllerView.collectionViewLayout;
    layout.itemSize = _controllerView.bounds.size;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsZero;
    layout.headerReferenceSize = CGSizeZero;
    layout.footerReferenceSize = CGSizeZero;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    [_controllerView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    _controllerView.pagingEnabled = YES;
    _controllerView.showsHorizontalScrollIndicator = NO;
    _controllerView.dataSource = self;
    _controllerView.delegate = self;
}

- (void)_selectTitleAtIndexPath:(NSIndexPath *)indexPath{
    _selectedIndex = indexPath.item;
    [_titleView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData{
    [self.view layoutIfNeeded];
    
    CGFloat w = _segmentWidth;
    if (self.controllers.count < 4){
        w = _titleView.bounds.size.width/self.controllers.count;
    }
  
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_titleView.collectionViewLayout;
    layout.itemSize = CGSizeMake(w, _titleView.bounds.size.height);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsZero;
    layout.headerReferenceSize = CGSizeZero;
    layout.footerReferenceSize = CGSizeZero;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [layout invalidateLayout];
    
    _titleView.dataSource = self;
    _titleView.delegate = self;
    
    [_titleView reloadData];
    [_controllerView reloadData];
    
    _indicator.frame = CGRectMake(0, _titleView.bounds.size.height-2, w, 2);
    _scaleX = _indicatorWidth > 0.0 ? _indicatorWidth/w : 1.0;
    _indicator.transform = CGAffineTransformMakeScale(_scaleX, 1.0);
}

- (UIView *)indicatorView{
    return _indicator;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.controllers.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView == _titleView){
        
        return [self titleView:collectionView cellForItemAtIndexPath:indexPath];
        
    } else {
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        UIViewController *vc = [self.controllers objectAtIndex:indexPath.item];
        if (!vc.parentViewController){
            [self addChildViewController:vc];
        }
        [cell addSubview:vc.view];
        [vc.view fitParent];
        return cell;
        
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView == _titleView){
        [self _selectTitleAtIndexPath:indexPath];
        [_titleView selectItemAtIndexPath:indexPath
                                      animated:YES
                                scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        [_controllerView selectItemAtIndexPath:indexPath
                                      animated:_animatedSelectController
                                scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView == _titleView){
        return [(UICollectionViewFlowLayout *)collectionViewLayout itemSize];
    } else {
        return collectionView.bounds.size;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _controllerView){
        //Move the indicator
        CGFloat ratio = scrollView.contentOffset.x/scrollView.contentSize.width;
        CGFloat x = _titleView.contentSize.width*ratio;
        CGAffineTransform t = CGAffineTransformMakeTranslation(x, 0);
        _indicator.transform = CGAffineTransformScale(t, _scaleX, 1);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == _controllerView){
        //Move title segment to the selected index path
        NSIndexPath *indexPath = [_controllerView indexPathForItemAtPoint:_controllerView.contentOffset];
        [self _selectTitleAtIndexPath:indexPath];
        [_titleView selectItemAtIndexPath:indexPath
                                 animated:YES
                           scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
}

- (UICollectionViewCell *)titleView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UILabel *lbl = (UILabel *)[cell viewWithTag:100];
    if (!lbl){
        lbl = [[UILabel alloc] initWithFrame:cell.bounds];
        lbl.tag = 100;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.minimumScaleFactor = 0.5;
        [cell addSubview:lbl];
        [lbl fitParent];
    }
    if (indexPath.item < self.titles.count){
        lbl.text = self.titles[indexPath.item];
    }
    if (_selectedIndex == indexPath.item) {
        lbl.font = _selectedTitleFont;
        lbl.textColor = _selectedTitleColor;
    } else {
        lbl.font = _normalTitleFont;
        lbl.textColor = _normalTitleColor;
    }
    return cell;

}

@end
