//
//  ViewController.m
//  RuntimePractice
//
//  Created by I_MT on 16/9/6.
//  Copyright © 2016年 I_MT. All rights reserved.
//

#import "ViewController.h"
#import "MapTableVC.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tablview;
@property (nonatomic, strong) XHPathCover *pathCover;

@end

@implementation ViewController
{
    NSArray *sources;
}
- (void)viewDidLoad {

    [super viewDidLoad];
    [self addTableView];
    [self addPathCover];
    [self initSources];
    //set NavigationBar 背景颜色&title 颜色
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:20/255.0 green:155/255.0 blue:213/255.0 alpha:1.0]];
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];

}
-(void)addTableView{
    self.tablview=[[UITableView alloc]initWithFrame:self.view.bounds];
    self.tablview.dataSource =self;
    self.tablview.delegate =self;
    [self.view addSubview:self.tablview];
}
#ifndef Scene
#define Scene 1   // 0   1
#endif
-(void)addPathCover{
    CGFloat widht =CGRectGetWidth(self.view.bounds);
#if Scene  == 0
    _pathCover = [[XHPathCover alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UIView *headView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, widht, 250)];
    [headView addSubview:_pathCover];
    self.tablview.tableHeaderView = headView;

#elif Scene == 1
    _pathCover = [[XHPathCover alloc] initWithFrame:CGRectMake(0, 0, widht, 250)];
    self.tablview.tableHeaderView = _pathCover;

#endif
    [_pathCover setBackgroundImage:[UIImage imageNamed:@"MenuBackground"]];
    [_pathCover setAvatarImage:[UIImage imageNamed:@"meicon.png"]];
    
    [_pathCover setInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Jack", XHUserNameKey, @"1990-10-19", XHBirthdayKey, nil]];
    
    
    [_pathCover setHandleRefreshEvent:^{
        // refresh your data sources
    }];
}
-(void)initSources{
    sources = @[@"测试方法替换只影响某个对象",@"NSMapTable",@"3",@"4",@"5"];
    [self.tablview reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return sources.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = sources[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            {
                Test1ViewController *vc =[[Test1ViewController alloc]init];
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        case 1:
            {
               MapTableVC *vc=[[MapTableVC alloc]init];
               [self.navigationController pushViewController:vc animated:YES];
            }
        break;
        default:
            break;
    }
}
#pragma mark - scroll delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_pathCover scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_pathCover scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_pathCover scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_pathCover scrollViewWillBeginDragging:scrollView];
}
@end
