//
//  ViewController.m
//  KeyboardDemo
//
//  Created by 张鑫 on 2017/8/21.
//  Copyright © 2017年 张鑫. All rights reserved.
//

#import "ViewController.h"
#import "BYInputCodeView.h"

@interface ViewController ()

@property (nonatomic, strong) UITextField *te;
@property (nonatomic, strong) BYInputCodeView *inve;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
   
}
- (IBAction)click:(UIButton *)sender {
    _inve = [[BYInputCodeView alloc] init];
    _inve.completeHandle = ^(NSString *inputPwd) {
        NSLog(@"%@", inputPwd);
    };
    [_inve show];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_inve dismiss];
}

@end
