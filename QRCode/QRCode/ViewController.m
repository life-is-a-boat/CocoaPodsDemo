//
//  ViewController.m
//  QRCode
//
//  Created by ting on 2019/3/1.
//  Copyright © 2019 tingting. All rights reserved.
//

#import "ViewController.h"
#import "libqrencode/QRCodeGenerator.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.imageView.image = [QRCodeGenerator qrImageForString:@"你是谁？" imageSize:100];
    
}


@end
