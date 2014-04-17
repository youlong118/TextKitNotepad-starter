//
//  CENoteEditorControllerViewController.m
//  TextKitNotepad
//
//  Created by Colin Eberhardt on 19/06/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "NoteEditorViewController.h"
#import "Note.h"
#import "TimeIndicatorView.h"
#import "SyntaxHighlightTextStorage.h"

@interface NoteEditorViewController () <UITextViewDelegate>



@end

@implementation NoteEditorViewController
{
    TimeIndicatorView* _timeView;
    SyntaxHighlightTextStorage* _textStorage;
    UITextView * _textView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createTextView];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    _timeView = [[TimeIndicatorView alloc] init:_note.timestamp];
    [self.view addSubview:_timeView];
    
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    _textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [self updateTimeIndicatorFrame];
}

-(void)viewDidLayoutSubviews{
    
    _textView.frame = self.view.bounds;
    [self updateTimeIndicatorFrame];
}

-(void)updateTimeIndicatorFrame{
    [_timeView updateSize];
    
    //当修改了系统设定的字体大小后，_timeView 的frame,需要更新
    _timeView.frame = CGRectOffset(_timeView.frame, self.view.frame.size.width - _timeView.frame.size.width, 0.0);
    UIBezierPath * exclusionPath = [_timeView curvePathWithOrigin:_timeView.center];
    
    //让 _textView 的 container 将exclusionPath 排除在外
    _textView.textContainer.exclusionPaths = @[exclusionPath];
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    // copy the updated note text to the underlying model.
    NSLog(@"txtview is EndEdit...");
    _note.contents = textView.text;
}


-(void) createTextView{
    //1.Create the text storage the backs the editor
    //创建一个你自定义的text storage的实例以及一个用来承载便笺内容的attributed string
    NSDictionary * attrs = @{ NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]};
    NSAttributedString* attrString = [[NSAttributedString alloc] initWithString:_note.contents attributes:attrs];
    _textStorage = [SyntaxHighlightTextStorage new];
    [_textStorage appendAttributedString:attrString];
    
    CGRect newTextViewRect = self.view.bounds;
    
    //2. Create the layout manager
    //创建一个布局管理器
    NSLayoutManager * layoutManager = [[NSLayoutManager alloc]init];
    
    //3. Create a text container
    //创建一个文本容器，把它和布局管理器联系起来。然后把布局管理器和文本存储器联系起来。
    CGSize containerSize = CGSizeMake(newTextViewRect.size.width, CGFLOAT_MAX);
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:containerSize];
    
    
    container.widthTracksTextView = YES;
    [layoutManager addTextContainer:container];
    
    [_textStorage addLayoutManager:layoutManager];
    
    
    //4. Create a UITextView
    //你自定义的文本容器和代理组创建实际的文本视图，  并把文本视图添加为子视图
    _textView = [[UITextView alloc] initWithFrame:newTextViewRect textContainer:container];
    _textView.delegate = self;
    
    [self.view addSubview:_textView];
    
    
    
    





}




@end
