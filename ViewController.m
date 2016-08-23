//
//  ViewController.m
//  支持多种中文字体
//
//  Created by MrWu on 16/8/22.
//  Copyright © 2016年 TTYL. All rights reserved.
//

#import "ViewController.h"
#import <CoreText/CoreText.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // ---------------   直接拖字体文件的方法  ---------------- //
    // 1.拖入文件 2.修改plist 3.添加build phases bundle文件引用 4.用下面方法查找文件并使用名字
//    NSArray *familyNames =[[NSArray alloc]initWithArray:[UIFont familyNames]];
//    NSArray *fontNames;
//    NSInteger indFamily, indFont;
//    NSLog(@"[familyNames count]===%zd",[familyNames count]);
//    for(indFamily=0;indFamily<[familyNames count];indFamily++)
//        
//    {
//        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
//        fontNames =[[NSArray alloc]initWithArray:[UIFont fontNamesForFamilyName:[familyNames objectAtIndex:indFamily]]];
//        
//        for(indFont=0; indFont<[fontNames count]; ++indFont)
//            
//        {
//            NSLog(@"Font name: %@",[fontNames objectAtIndex:indFont]);
//        }
//    }
    
    // 第二种方法,自己下字体.如下   直接引用字体包很大10M左右
    
    NSString *fontName = @"HannotateSC-W5";
    self.label.text = @"这个是手札体简,还是很有意思的对吧这个是手札体简,还是很有意思的对吧这个是手札体简,还是很有意思的对吧这个是手札体简,还是很有意思的对吧这个是手札体简,还是很有意思的对吧";
    
    if (![self isFontDownloadedFontName:fontName]) {
        [self downloadFont:fontName];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** 检验是否已经下载最新字体 */
- (BOOL)isFontDownloadedFontName:(NSString *)fontName {
    UIFont *afont = [UIFont fontWithName:fontName size:15.];
    if (afont && ([afont.fontName compare:fontName] == NSOrderedSame || [afont.familyName compare:fontName] == NSOrderedSame)) {
        return YES;
    }
    return NO;
}

/** 字体未下载过 */
- (void)downloadFont:(NSString *)fontName  {
    NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:fontName,kCTFontNameAttribute, nil];
    
    //创建一个字体描述对象 CTFontDescriptorRef
    CTFontDescriptorRef descript = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attrs);
    
    //将描述对象放到数组中
    NSMutableArray *descs = [NSMutableArray array];
    [descs addObject:(__bridge id)descript];
    CFRelease(descript);
    
    //下载
    __block BOOL errorInDownload = NO;
    
    CTFontDescriptorMatchFontDescriptorsWithProgressHandler((__bridge CFArrayRef)descs, NULL, ^bool(CTFontDescriptorMatchingState state, CFDictionaryRef  _Nonnull progressParameter) {
        double progressValue =[[(__bridge id)progressParameter objectForKey:(id)kCTFontDescriptorMatchingPercentage] doubleValue];
        
        switch (state) {
            case kCTFontDescriptorMatchingDidBegin:
                NSLog(@"开始匹配!");
                break;
            case kCTFontDescriptorMatchingDidFinish:
                if (!errorInDownload) {
                    NSLog(@"匹配完成!");
                    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef) fontName, 15, NULL);
                    CFStringRef fontURL = CTFontCopyAttribute(fontRef, kCTFontURLAttribute);
                    NSLog(@"%@",fontURL);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.label.font = [UIFont fontWithName:fontName size:15];
                    });
                }
                break;
            case kCTFontDescriptorMatchingWillBeginDownloading:
                NSLog(@"开始下载!");
                break;
            case kCTFontDescriptorMatchingDidFinishDownloading:{
             
                CTFontDescriptorRef ref = (__bridge CTFontDescriptorRef)([(__bridge id)progressParameter objectForKey:(id)kCTFontDescriptorMatchingSourceDescriptor]);
                NSLog(@"下载完成! %@",ref);
                CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef) fontName, 15, NULL);
                CFStringRef fontURL = CTFontCopyAttribute(fontRef, kCTFontURLAttribute);
                NSLog(@"%@",fontURL);
                CFRelease(fontRef);
                CFRelease(fontURL);
                dispatch_async(dispatch_get_main_queue(), ^{
                self.label.font = [UIFont fontWithName:fontName size:15];

                });
            }
                break;
            case kCTFontDescriptorMatchingDidFailWithError:
                errorInDownload = YES;
                NSLog(@"匹配失败!%@",progressParameter);
                break;
            case kCTFontDescriptorMatchingDownloading:
                NSLog(@"下载进度%.2f",progressValue);
                break;
                
            default:
                break;
        }
        return YES;
    });
    
    
    
}

@end
