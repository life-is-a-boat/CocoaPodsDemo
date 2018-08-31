//
//  ViewController.m
//  NSScanner
//
//  Created by tingting on 2018/8/30.
//  Copyright © 2018年 tingting. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"ts123test12Demotest");

    NSScanner *scanner = [NSScanner localizedScannerWithString:@"ts123test12Demotest"];
//    scanner.caseSensitive = true;
    NSString *newStr;
    [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"8"] intoString:&newStr];
    
    float afloat;
    NSScanner *theScanner = [NSScanner scannerWithString:@"丑八怪2.345h14.5+13.14"];
    [theScanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
    while ([theScanner isAtEnd] == NO) {

        [theScanner scanFloat:&afloat];
        
//        //做操作
        if (theScanner.scanLocation<theScanner.string.length) {
            theScanner.scanLocation ++;
        }

    }
    
    [self scanString];
    //
    [self scanCharactersFromSet];
    //
    [self scanUpToCharactersFromSet];
    //
    [self scanUpToString];

    
    [self test1];
//
    [self test2];

    
}
//从当前位置开始扫描 若扫描到该字符串 则返回yes 和该字符串
- (void)scanString
{
    NSString *valueString = @"ts123tes12Demotest";//@"12354,liusan,iloveu!";
    NSScanner *scanner = [NSScanner scannerWithString:valueString];
    scanner.scanLocation = 5;
    NSString *buf;
    if ([scanner scanString:@"te" intoString:&buf]) {
        NSLog(@"yes");
    }
    else {
        NSLog(@"no");
    }
    NSLog(@"1---字符:%@ 扫描位置：%ld",buf,scanner.scanLocation);
}

//反模式  按照字符扫描 当扫描到第一个不包含在忽略字符集中的字符时即停止
-(void)scanCharactersFromSet
{
    NSString *valueString = @"ts123test12Demotest";
    NSScanner *scanner = [NSScanner scannerWithString:valueString];
    NSString *buf;
    if ([scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"123est"] intoString:&buf]) {
        NSLog(@"yes");
    }
    else {
        NSLog(@"no");
    }
    NSLog(@"2---字符:%@ 扫描位置：%ld",buf,scanner.scanLocation);
}
//按照字符扫描  注意当字符串第一个字符就包含在内时返回no
-(void)scanUpToCharactersFromSet
{
    NSString *valueString = @"ts123test12Demotest";
    NSScanner *scanner = [NSScanner scannerWithString:valueString];
    NSString *buf;
    if ([scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"12"] intoString:&buf]) {
        NSLog(@"yes");
    }
    else {
        NSLog(@"no");
    }
    NSLog(@"3---字符:%@ 扫描位置：%ld",buf,scanner.scanLocation);
}
//扫描按照字符串 扫描到即停止
-(void)scanUpToString
{
    NSString *valueString = @"ts123test12Demotest";
    NSScanner *scanner = [NSScanner scannerWithString:valueString];
    scanner.scanLocation = 6;
    NSString *buf;
    if ([scanner scanUpToString:@"test" intoString:&buf]) {
        NSLog(@"yes");
    }
    else {
        NSLog(@"no");
    }
    NSLog(@"4---字符:%@ 扫描位置：%ld",buf,scanner.scanLocation);
}

-(void)test1
{
//    NSScanner *scanner = [NSScanner localizedScannerWithString:@" 3.1415926💗💖❤lovean1234567890~!@#$%^&*()_+"];
    NSScanner *scanner = [NSScanner scannerWithString:@"你好12.345世界0"];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
    
    int number_int;//初始值为 1071318992
    [scanner scanInt:&number_int];

//    scanner.scanLocation = 0;
    NSInteger number_integer;
    [scanner scanInteger:&number_integer];
    
//    scanner.scanLocation = 0;
    long long number_longlong;
    [scanner scanLongLong:&number_longlong];
    
//    scanner.scanLocation = 0;
    unsigned long long number_unsigned;
    [scanner scanUnsignedLongLong:&number_unsigned];
    
//    scanner.scanLocation = 0;
    float number_float;
    [scanner scanFloat:&number_float];
    
//    scanner.scanLocation = 0;
    double number_double;
    [scanner scanDouble:&number_double];
    
//    scanner.scanLocation = 0;
    unsigned number_hexInt;
    [scanner scanHexInt:&number_hexInt];

//    scanner.scanLocation = 0;
    unsigned long long number_hexLong;
    [scanner scanHexLongLong:&number_hexLong];
    
//    scanner.scanLocation = 0;
    float number_hexFloat;
    [scanner scanHexFloat:&number_hexFloat];
    
//    scanner.scanLocation = 0;
    double number_hexDouble;
    [scanner scanHexDouble:&number_hexDouble];

}

-(void)test2
{
    /*
     A character set containing the characters in Unicode General Category Cc and Cf.
     These characters include, for example, the soft hyphen (U+00AD), control characters to support bi-directional text, and IETF language tag characters.
     Returns
     A character set containing all the control characters.
     */
    NSCharacterSet *controlCharacterSet                 = [NSCharacterSet controlCharacterSet];
    [self charactorSetTest:@"controlCharacterSet:   不懂这个咋办adffDJHGFdsda9083hudsfu^&*(*&^%$测试" withCharactorSet:controlCharacterSet];
    /*
     A character set containing the characters in Unicode General Category Zs and CHARACTER TABULATION (U+0009).
     This set doesn’t contain the newline or carriage return characters.
     Returns
     A character set containing all the whitespace characters.
     */
    NSCharacterSet *whitespaceCharacterSet              = [NSCharacterSet whitespaceCharacterSet];
    [self charactorSetTest:@"whitespaceCharacterSet: ss\ns ,234测试" withCharactorSet:whitespaceCharacterSet];

    /*
     A character set containing characters in Unicode General Category Z*, U+000A ~ U+000D, and U+0085.
     Returns
     A character set containing all the whitespace and newline characters.
     */
    NSCharacterSet *whitespaceAndNewlineCharacterSet    = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    [self charactorSetTest:@"whitespaceAndNewlineCharacterSet:ss\ns ,234测试" withCharactorSet:whitespaceAndNewlineCharacterSet];
    /*
     A character set containing the characters in the category of Decimal Numbers.
     Informally, this set is the set of all characters used to represent the decimal values 0 through 9. These characters include, for example, the decimal digits of the Indic scripts and Arabic.
     Returns
     A character set containing all the decimal digit characters.
     */
    NSCharacterSet *decimalDigitCharacterSet            = [NSCharacterSet decimalDigitCharacterSet];
    [self charactorSetTest:@"decimalDigitCharacterSet:数字怎么了123就是不想要你0但是没版本了！@#￥%……098测试" withCharactorSet:decimalDigitCharacterSet];
    /*
     文字
     A character set containing the characters in Unicode General Category L* & M*.
     Informally, this set is the set of all characters used as letters of alphabets and ideographs.
     Returns
     A character set containing all the letter characters.
     */
    NSCharacterSet *letterCharacterSet                  = [NSCharacterSet letterCharacterSet];
    [self charactorSetTest:@"👌他说是文字/8*letterCharacterSet:DFGHrerw1345(*&^FRI测试" withCharactorSet:letterCharacterSet];

    /*
     小写字符
     A character set containing the characters in Unicode General Category Ll.
     Informally, this set is the set of all characters used as lowercase letters in alphabets that make case distinctions.
     Returns
     A character set containing all the lowercase letter characters.
     */
    NSCharacterSet *lowercaseLetterCharacterSet         = [NSCharacterSet lowercaseLetterCharacterSet];
    [self charactorSetTest:@"TFF测试lowercaseLetterCharacterSet:DFGHrerw1345(*&^FRI测试" withCharactorSet:lowercaseLetterCharacterSet];
    /*
     大写的字符
     A character set containing the characters in Unicode General Category Lu and Lt.
     Informally, this set is the set of all characters used as uppercase letters in alphabets that make case distinctions.
     Returns
     A character set containing all the uppercase letter characters.
     */
    NSCharacterSet *uppercaseLetterCharacterSet         = [NSCharacterSet uppercaseLetterCharacterSet];
    [self charactorSetTest:@"uppercaseLetterCharacterSet:DFGHrerw1345(*&^FRI测试" withCharactorSet:uppercaseLetterCharacterSet];

    /*
     A character set containing the characters in Unicode General Category M*.
     This set is also defined as all legal Unicode characters with a non-spacing priority greater than 0. Informally, this set is the set of all characters used as modifiers of base characters.
     Returns
     A character set containing all the non-base characters.
     */
    NSCharacterSet *nonBaseCharacterSet                 = [NSCharacterSet nonBaseCharacterSet];
    /*
     A character set containing the characters in Unicode General Categories L*, M*, and N*.
     Informally, this set is the set of all characters used as basic units of alphabets, syllabaries, ideographs, and digits.
     Returns
     A character set containing all the alphanumeric characters.
     */
    NSCharacterSet *alphanumericCharacterSet            = [NSCharacterSet alphanumericCharacterSet];
    /*
     A character set containing individual Unicode characters that can also be represented as composed character sequences (such as for letters with accents), by the definition of “standard decomposition” in version 3.2 of the Unicode character encoding standard.
     These characters include compatibility characters as well as pre-composed characters.
     Note
     This character set doesn’t currently include the Hangul characters defined in version 2.0 of the Unicode standard.
     Returns
     A character set containing all the decomposable characters.
     */
    NSCharacterSet *decomposableCharacterSet            = [NSCharacterSet decomposableCharacterSet];
    /*
     A character set containing values in the category of Non-Characters or that have not yet been defined in version 3.2 of the Unicode standard.
     Returns
     A character set containing all the illegal characters.
     */
    NSCharacterSet *illegalCharacterSet                 = [NSCharacterSet illegalCharacterSet];
    /*
     A character set containing the characters in Unicode General Category P*.
     Informally, this set is the set of all non-whitespace characters used to separate linguistic units in scripts, such as periods, dashes, parentheses, and so on.
     Returns
     A character set containing all the punctuation characters.
     */
    NSCharacterSet *punctuationCharacterSet             = [NSCharacterSet punctuationCharacterSet];
    /*
     A character set containing the characters in Unicode General Category Lt.
     Returns
     A character set containing all the capitalized letter characters.
     */
    NSCharacterSet *capitalizedLetterCharacterSet       = [NSCharacterSet capitalizedLetterCharacterSet];
    [self charactorSetTest:@"capitalizedLetterCharacterSet：*fenwkjgiw12455huhib fn!@#$~!@#$%^&测试" withCharactorSet:capitalizedLetterCharacterSet];

    /*
     数学运算符、货币、图像符号 表情
     A character set containing the characters in Unicode General Category S*.
     These characters include, for example, the dollar sign ($) and the plus (+) sign.
     Returns
     A character set containing all the symbol characters.
     */
    
    NSCharacterSet *symbolCharacterSet                  = [NSCharacterSet symbolCharacterSet];
    [self charactorSetTest:@"symbolCharacterSet：23快来👌帮你们，+wr()$5&*(*´▽｀)ノノ测试" withCharactorSet:symbolCharacterSet];

    /*
     换行符
     A character set containing the newline characters (U+000A ~ U+000D, U+0085, U+2028, and U+2029).
     Returns
     A character set containing all the newline characters.
     */
    NSCharacterSet *newlineCharacterSet                 = [NSCharacterSet newlineCharacterSet];
    [self charactorSetTest:@"newlineCharacterSet：\n \t/测试" withCharactorSet:newlineCharacterSet];
}

-(void)charactorSetTest:(NSString *)testString withCharactorSet:(NSCharacterSet *)characterSet
{
    NSScanner *scanner = [NSScanner scannerWithString:testString];
    NSString *newString;
    [scanner scanUpToCharactersFromSet:characterSet intoString:&newString];
//    NSLog(@"测试NSCharacterSet：%@，原字符串：%@；新字符串：%@",characterSet.class,testString,newString);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
