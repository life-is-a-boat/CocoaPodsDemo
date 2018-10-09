//
//  ATView.m
//  bluetooth
//
//  Created by tingting on 2018/9/30.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ATView.h"

@interface ATView ()
{
    UIView  *_bgView;
}

@end

@implementation ATView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _bgView = [[UIView alloc] init];
    [self addSubview:_bgView];
}
- (id)init {
    return [self initWithFrame:CGRectZero];
}

-(void)layoutSubviews {
    NSLog(@"%s-%s",__FILE__,__func__);
}

- (void)hhd {
    NSLog(@"%s-%s",__FILE__,__func__);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
