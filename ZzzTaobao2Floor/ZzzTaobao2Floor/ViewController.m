//
//  ViewController.m
//  ZzzTaobao2Floor
//
//  Created by zhouzezhou on 2018/4/17.
//  Copyright © 2018年 zhouzezhou. All rights reserved.
//



#import "ViewController.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width      // 屏幕的宽度
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height    // 屏幕的高度
#define kStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height // 系统状态栏高度

#define floor1Height kScreenHeight  // 一楼的高度
#define floor2Height kScreenHeight  // 二楼的高度
#define animationInterval   0.8       // 动画速度/完成时间(s)
#define enter2FloorOffset   100      // 进入二楼时一楼视图的偏移量

@interface ViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView * homeScrollView;
@property (nonatomic, strong) UIView *upstairsView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configView];
}



#pragma mark - Private Mothed

-(void)configView
{
    [self.view setBackgroundColor: [UIColor whiteColor]];
    
    //1楼
    _homeScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, floor1Height)];
    [_homeScrollView setBackgroundColor:[UIColor whiteColor]];
    [_homeScrollView setContentSize:CGSizeMake(kScreenWidth, floor1Height + 1.f )];
    [_homeScrollView setScrollEnabled:YES];
    _homeScrollView.userInteractionEnabled = YES;
    _homeScrollView.delegate = self;
    _homeScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:_homeScrollView];
    
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50.f)];
    [testLabel setTextAlignment:NSTextAlignmentCenter];
    [testLabel setText:@"向下滑动试试"];
    [_homeScrollView addSubview:testLabel];
    
    
    //2楼
    _upstairsView = [[UIView alloc] initWithFrame:CGRectMake(0, -kScreenHeight , kScreenWidth, floor2Height)];
    [_upstairsView setBackgroundColor:[UIColor orangeColor]];
    [self.view addSubview:_upstairsView];
    
    UILabel *secondFloorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, floor2Height - enter2FloorOffset, kScreenWidth, 75)];
    [secondFloorLabel setText:@"滑过这里进入二楼"];
    secondFloorLabel.backgroundColor=[UIColor lightGrayColor];
    [secondFloorLabel setTextAlignment:NSTextAlignmentCenter];
    [_upstairsView addSubview:secondFloorLabel];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10 + kStatusBarHeight, 50, 50)];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setBackgroundColor:[UIColor lightGrayColor]];
    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_upstairsView addSubview:backBtn];

}




#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //test
    NSLog(@"scrollView.contentOffset.y: %f", scrollView.contentOffset.y);

    if([scrollView isScrollEnabled])
    {
        float newPointY2FloorView = - floor2Height - scrollView.contentOffset.y;
        CGRect newRect2Floor = CGRectMake(0, newPointY2FloorView,  kScreenWidth, floor2Height);
        _upstairsView.frame = newRect2Floor;
    }


    //达到临界调节，自动进入二楼
    if(scrollView.contentOffset.y < - enter2FloorOffset && [scrollView isScrollEnabled])
    {
        NSLog(@"进入二楼");

        // 停用滑动，但已被滑动的视图会瞬间回到原点
        [scrollView setScrollEnabled:NO];

        // 让所有视图定位到结束滑动时的位置，为了和下面的下滑动画产生顺滑的视觉
        // 2楼
        float newPointY2FloorView = - floor2Height + enter2FloorOffset;
        CGRect newRect2Floor = CGRectMake(0, newPointY2FloorView, kScreenWidth, floor2Height);
        _upstairsView.frame = newRect2Floor;

        // 1楼
        float newPointY1FloorView = 0 + enter2FloorOffset;
        CGRect newRect1Floor = CGRectMake(0, newPointY1FloorView, kScreenWidth, floor1Height);
        scrollView.frame = newRect1Floor;

        // 下滑动画
        [UIView animateWithDuration:animationInterval animations:^{
            // 二楼滑下来
            float endPointY2FloorView = 0;
            CGRect endRect2Floor = CGRectMake(0, endPointY2FloorView,  kScreenWidth, floor2Height);
            self.upstairsView.frame = endRect2Floor;

            // 一楼继续向下滑,滑出屏幕
            float endPointY1FloorView = kScreenHeight;
            CGRect endRect1Floor = CGRectMake(0, endPointY1FloorView, kScreenWidth, floor1Height);
            scrollView.frame = endRect1Floor;
        }];
    }
}

// 以下方法可以监听更多ScrollView的事件
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSLog(@"scrollViewWillEndDragging");
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewWillBeginDragging");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"scrollViewDidEndDragging");
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewWillBeginDecelerating");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndDecelerating");
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewShouldScrollToTop");
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidScrollToTop");
}

#pragma mark - Button Respond
-(void)backBtnClick:(UIButton *) sender
{
    // 返回一楼
    [self startBack1FloorAnimation];
}

-(void)startBack1FloorAnimation
{
    [self.homeScrollView setScrollEnabled:YES];
    
    [UIView animateWithDuration:animationInterval animations:^{
        // 二楼滑上去,滑出屏幕
        float endPointY2FloorView = -floor2Height;
        CGRect endRect2Floor = CGRectMake(0, endPointY2FloorView,  kScreenWidth, floor2Height);
        self.upstairsView.frame = endRect2Floor;
        
        // 一楼向上滑,回到原始位置
        float endPointY1FloorView = 0;
        CGRect endRect1Floor = CGRectMake(0, endPointY1FloorView, kScreenWidth, floor1Height);
        self.homeScrollView.frame = endRect1Floor;
    }];
}


@end
