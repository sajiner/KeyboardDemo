//
//  BYInputCodeView.m
//  KeyboardDemo
//
//  Created by 张鑫 on 2017/8/21.
//  Copyright © 2017年 张鑫. All rights reserved.
//

#import "BYInputCodeView.h"

#define TITLE_HEIGHT 46
#define PAYMENT_WIDTH [UIScreen mainScreen].bounds.size.width-80
#define PWD_COUNT 6
#define DOT_WIDTH 10
#define KEYBOARD_HEIGHT 216
#define KEY_VIEW_DISTANCE 100
#define ALERT_HEIGHT 200

@interface BYInputCodeView ()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *paymentView;
@property (nonatomic, strong) UIView *inputView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) NSMutableArray *pwdIndicatorArr;

@end

@implementation BYInputCodeView {
    CGRect _endFrame;
    CGFloat _duration;
    UIViewAnimationCurve _animationCurve;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3f];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}


- (void)keyboardWillChangeFrame: (NSNotification *)note {
    _endFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    _animationCurve = [note.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
    [UIView animateWithDuration:_duration animations:^{
        [UIView setAnimationCurve:_animationCurve];
        CGFloat paymentViewY = [UIScreen mainScreen].bounds.size.height - _endFrame.size.height - 80;
        self.paymentView.frame = CGRectMake(0, paymentViewY, [UIScreen mainScreen].bounds.size.width, _endFrame.size.height + 80);
    } completion:nil];
}

- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    [self addSubview:self.paymentView];
    [_pwdTextField becomeFirstResponder];
}

- (void)dismiss {
    [_pwdTextField resignFirstResponder];
    [UIView animateWithDuration:_duration animations:^{
        [UIView setAnimationCurve:_animationCurve];
        _paymentView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, _endFrame.size.height + 80);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.text.length >= PWD_COUNT && string.length) {
        //输入的字符个数大于6，则无法继续输入，返回NO表示禁止输入
        return NO;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]*$"];
    if (![predicate evaluateWithObject:string]) {
        return NO;
    }
    NSString *totalString;
    if (string.length <= 0) {
        totalString = [textField.text substringToIndex:textField.text.length-1];
    }
    else {
        totalString = [NSString stringWithFormat:@"%@%@",textField.text,string];
    }
    [self setDotWithCount:totalString.length];
    
    NSLog(@"_____total %@",totalString);
    if (totalString.length == 6) {
        if (_completeHandle) {
            _completeHandle(totalString);
        }
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:.3f];
        NSLog(@"complete");
    }
    
    return YES;
}

- (void)setDotWithCount:(NSInteger)count {
    for (UILabel *dot in _pwdIndicatorArr) {
        dot.hidden = YES;
    }
    
    for (int i = 0; i< count; i++) {
        ((UILabel*)[_pwdIndicatorArr objectAtIndex:i]).hidden = NO;
    }
}

- (UIView *)paymentView {
    if (!_paymentView) {
        _paymentView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height , [UIScreen mainScreen].bounds.size.width, 80)];
         [self addSubview:_paymentView];
//        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, PAYMENT_WIDTH, TITLE_HEIGHT)];
//        _titleLabel.textAlignment = NSTextAlignmentCenter;
//        _titleLabel.textColor = [UIColor darkGrayColor];
//        _titleLabel.font = [UIFont systemFontOfSize:17];
//        [_paymentView addSubview:_titleLabel];
//        
//        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_closeBtn setFrame:CGRectMake(0, 0, TITLE_HEIGHT, TITLE_HEIGHT)];
//        [_closeBtn setTitle:@"╳" forState:UIControlStateNormal];
//        [_closeBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//        [_closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
//        _closeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
//        [_paymentView addSubview:_closeBtn];
        
        _inputView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _paymentView.bounds.size.width, 80)];
        _inputView.backgroundColor = [UIColor whiteColor];
        _inputView.layer.borderWidth = 1.f;
        _inputView.layer.borderColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.].CGColor;
        [_paymentView addSubview:_inputView];
        
        _pwdIndicatorArr = [[NSMutableArray alloc]init];
        _pwdTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 80)];
        _pwdTextField.hidden = YES;
        _pwdTextField.delegate = self;
        _pwdTextField.keyboardType = UIKeyboardTypeNumberPad;
        [_inputView addSubview:_pwdTextField];
        
        CGFloat width = _inputView.bounds.size.width/PWD_COUNT;
        for (int i = 0; i < PWD_COUNT; i ++) {
            UILabel *dot = [[UILabel alloc]initWithFrame:CGRectMake((width-DOT_WIDTH)/2.f + i*width, (_inputView.bounds.size.height-DOT_WIDTH)/2.f, DOT_WIDTH, DOT_WIDTH)];
            dot.backgroundColor = [UIColor blackColor];
            dot.layer.cornerRadius = DOT_WIDTH/2.;
            dot.clipsToBounds = YES;
            dot.hidden = YES;
            [_inputView addSubview:dot];
            [_pwdIndicatorArr addObject:dot];
            
            if (i == PWD_COUNT-1) {
                continue;
            }
            UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake((i+1)*width, 0, .5f, _inputView.bounds.size.height)];
            line.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.];
            [_inputView addSubview:line];
        }
    }
    return _paymentView;
}

@end
