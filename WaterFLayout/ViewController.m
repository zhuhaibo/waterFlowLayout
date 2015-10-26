//
//  ViewController.m
//  WaterFLayout
//
//  Created by qingqing on 15/4/27.
//  Copyright (c) 2015年 qingqing. All rights reserved.
//

#import "ViewController.h"

#import "WaterFLayout.h"

@interface ViewController ()<UICollectionViewDataSource,WaterFLayoutDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *waterFlow;
@property(nonatomic, strong) NSMutableArray *lst;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"WaterFLayout";
    
    self.lst = [NSMutableArray array];
    for(int i = 0; i < 35; i++)
    {
        [self.lst addObject:[NSString stringWithFormat:@"%d", i + 1]];
    }
    
    
    
    
    WaterFLayout *flowLayout = [[WaterFLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(9, 9, 9, 9);
    self.waterFlow.collectionViewLayout = flowLayout;
    self.waterFlow.dataSource = self;
    self.waterFlow.delegate = self;
    [self.waterFlow registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor redColor];
    [self.waterFlow addSubview:refresh];
    [refresh addTarget:self action:@selector(pulledToRefresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)pulledToRefresh:(UIRefreshControl *)refreshControl
{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
    });
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.lst.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    for (UIView *view in cell.contentView.subviews) {
        if (view.tag == 4505) {
            [view removeFromSuperview];
            break;
        }
        else {
            UILabel *label = [UILabel new];
            [label setTag:4505];
            [label setTextColor:[UIColor blackColor]];
            [label setText:[@(indexPath.row) stringValue]];
            [label sizeToFit];
            [label setBounds:CGRectMake(0, 0, [label intrinsicContentSize].width, [label intrinsicContentSize].height)];
            [cell.contentView addSubview:label];
        }
    }
    
    if (cell.contentView.subviews.count == 0) {
        UILabel *label = [UILabel new];
        [label setTag:4505];
        [label setTextColor:[UIColor blackColor]];
        [label setText:[@(indexPath.row) stringValue]];
        [label sizeToFit];
        [label setBounds:CGRectMake(0, 0, [label intrinsicContentSize].width, [label intrinsicContentSize].height)];
        [cell.contentView addSubview:label];
    }
    
    int r = arc4random() % 255;
    int g = arc4random() % 255;
    int b = arc4random() % 255;
    cell.backgroundColor = [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 6.0f;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    int height = 50 + (arc4random() % 220);
    return CGSizeMake(CGRectGetMidX(self.view.bounds), height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@">>>>>>>>>>didSelectItemAtIndexPath %@", indexPath);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
