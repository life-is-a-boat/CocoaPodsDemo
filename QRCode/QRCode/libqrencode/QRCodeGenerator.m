//
// QR Code Generator - generates UIImage from NSString
//
// Copyright (C) 2012 http://moqod.com Andrew Kopanev <andrew@moqod.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
// of the Software, and to permit persons to whom the Software is furnished to do so, 
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all 
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.
//

#import "QRCodeGenerator.h"
#import "qrencode.h"

enum {
	qr_margin = 1
};

@implementation QRCodeGenerator

+ (void)drawQRCode:(QRcode *)code context:(CGContextRef)ctx size:(CGFloat)size color:(UIColor *)color {
    unsigned char *data = 0;
    int width;
    data = code->data;
    width = code->width;
    float zoom = (double)size / (code->width + 2.0 * qr_margin);
    CGRect rectDraw = CGRectMake(0, 0, zoom, zoom);
    
    // draw
    //CGContextSetFillColor(ctx, CGColorGetComponents(color.CGColor));
    CGContextSetFillColorWithColor(ctx, color.CGColor) ;
    for(int i = 0; i < width; ++i) {
        for(int j = 0; j < width; ++j) {
            if(*data & 1) {
                rectDraw.origin = CGPointMake((j + qr_margin) * zoom,(i + qr_margin) * zoom);
                CGContextAddRect(ctx, rectDraw);
            }
            ++data;
        }
    }
    CGContextFillPath(ctx);
}

+ (void)drawQRCode:(QRcode *)code context:(CGContextRef)ctx size:(CGFloat)size {
    return[self drawQRCode:code context:ctx size:size color:[UIColor blackColor]] ;
}

+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)size {
    return [self qrImageForString:string imageSize:size color:[UIColor blackColor]] ;
}

+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)size color:(UIColor *)color {
    
	if (![string length]) {
		return nil;
	}
	
	QRcode *code = QRcode_encodeString([string UTF8String], 0, QR_ECLEVEL_L, QR_MODE_8, 1);
	if (!code) {
		return nil;
	}
	
	// create context
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(0, size, size, 8, size * 4, colorSpace, kCGImageAlphaPremultipliedLast);
	
	CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0, -size);
	CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1, -1);
	CGContextConcatCTM(ctx, CGAffineTransformConcat(translateTransform, scaleTransform));
	
	// draw QR on this context	
	[QRCodeGenerator drawQRCode:code context:ctx size:size color:color];
	
	// get image
	CGImageRef qrCGImage = CGBitmapContextCreateImage(ctx);
	UIImage * qrImage = [UIImage imageWithCGImage:qrCGImage];
	
	// some releases
	CGContextRelease(ctx);
	CGImageRelease(qrCGImage);
	CGColorSpaceRelease(colorSpace);
	QRcode_free(code);
	
	return qrImage;
}

+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)size color:(UIColor *)color binaryQRCode:(NSString *)binaryQRCode {
    if ([binaryQRCode isEqualToString:@"1"]) {
        if (!string.length) {
            return nil;
        }

        NSMutableData *hexData = [NSMutableData data];
        NSRange range;
        if (string.length %2 == 0) {
            range = NSMakeRange(0,2);
        } else {
            range = NSMakeRange(0,1);
        }
        
        for (NSUInteger i = range.location; i < string.length; i += 2) {
            unsigned int anInt;
            NSString *hexCharStr = [string substringWithRange:range];
            NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
            [scanner scanHexInt:&anInt];
            NSData * entity = [[NSData alloc] initWithBytes:&anInt length:1];
            [hexData appendData:entity];
            range.location += range.length;
            range.length = 2;
        }

        //  画图片
        UIImage *codeImage = nil;
        CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [qrFilter setValue:hexData forKey:@"inputMessage"];
        [qrFilter setValue:@"L" forKey:@"inputCorrectionLevel"];
        UIColor *onColor = color;
        UIColor *offColor = [UIColor whiteColor];
        CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor" keysAndValues:@"inputImage", qrFilter.outputImage, @"inputColor0", [CIColor colorWithCGColor:onColor.CGColor], @"inputColor1", [CIColor colorWithCGColor:offColor.CGColor], nil];
        CIImage *qrImage = colorFilter.outputImage;
        CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), YES, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(context, kCGInterpolationNone); CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
        codeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGImageRelease(cgImage);
        return codeImage;

    } else {
        return [self qrImageForString:string imageSize:size color:color];
    }
}


@end
