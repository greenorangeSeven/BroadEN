//
//  MaintainingAddView.m
//  BroadEN
//
//  Created by Seven on 15/11/28.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import "MaintainingAddView.h"
#import "ImageCollectionCell.h"

@interface MaintainingAddView ()
{
    NSMutableArray *otherPicArray;
    int selectOtherPicIndex;
}

@end

@implementation MaintainingAddView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Maintaining Add";
    
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.view.frame.size.height);
    
    otherPicArray = [[NSMutableArray alloc] initWithCapacity:9];
    UIImage *addPicImage = [UIImage imageNamed:@"addPic"];
    [otherPicArray addObject:addPicImage];
    
    self.otherCollectionView.delegate = self;
    self.otherCollectionView.dataSource = self;
    [self.otherCollectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:ImageCollectionCellIdentifier];
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [otherPicArray count];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ImageCollectionCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ImageCollectionCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[ImageCollectionCell class]]) {
                cell = (ImageCollectionCell *)o;
                break;
            }
        }
    }
    NSUInteger row = [indexPath row];
    UIImage *picImage = [otherPicArray objectAtIndex:row];
    cell.picIV.image = picImage;
    
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(90, 90);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
//    if (row == [topicImageArray count] -1) {
//        UIActionSheet *cameraSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                                 delegate:self
//                                                        cancelButtonTitle:@"取消"
//                                                   destructiveButtonTitle:nil
//                                                        otherButtonTitles:@"拍照", @"从相册中选取", nil];
//        cameraSheet.tag = 0;
//        [cameraSheet showInView:self.view];
//    }
//    else
//    {
//        UIActionSheet *delSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                              delegate:self
//                                                     cancelButtonTitle:@"取消"
//                                                destructiveButtonTitle:nil
//                                                     otherButtonTitles:@"删除", nil];
//        delSheet.tag = 2;
//        selectCaremaIndex = row;
//        [delSheet showInView:self.view];
//    }
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
