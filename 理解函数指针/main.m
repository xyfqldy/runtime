//
//  main.m
//  test_commandLine
//
//  Created by I_MT on 16/8/26.
//  Copyright © 2016年 I_MT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef int (* func_pt)(int);
int test1(int a)
{
    printf("1\n");

    return  1;
}
int test2(int b){
printf("2\n");
    return 2;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
    
    func_pt a ,b;
    a = &test1;
    b = &test2;
    
    test1(0);
    test2(0);
    a(1);
    b(1);

    }
    return 0;
}



