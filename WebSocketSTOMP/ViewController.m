//
//  ViewController.m
//  WebSocketSTOMP
//
//  Created by 冯攀 on 2019/12/20.
//  Copyright © 2019 冯攀. All rights reserved.
//

#import "ViewController.h"
#import "WebSocketManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[WebSocketManager shareInstance] connect];
}


@end
