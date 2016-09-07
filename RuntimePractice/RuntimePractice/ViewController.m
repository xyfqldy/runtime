//
//  ViewController.m
//  RuntimePractice
//
//  Created by I_MT on 16/9/6.
//  Copyright © 2016年 I_MT. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tablview;

@end

@implementation ViewController
{
    NSArray *sources;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTableView];
}
-(void)addTableView{
    self.tablview=[[UITableView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.tablview];
}
-(void)initSources{
    sources = @[@"1",@"2",@"3",@"4",@"5"];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return sources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
