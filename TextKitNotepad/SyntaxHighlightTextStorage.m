//
//  SyntaxHighlightTextStorage.m
//  TextKitNotepad
//
//  Created by bizopstech on 14-3-21.
//  Copyright (c) 2014年 Colin Eberhardt. All rights reserved.
//

#import "SyntaxHighlightTextStorage.h"

@implementation SyntaxHighlightTextStorage{
    NSMutableAttributedString * _backingStore;
}

-(id)init{

    if(self = [super init]){
        _backingStore = [NSMutableAttributedString new];
        
    }
    return self;
}

-(NSString *)string{
    return [_backingStore string];

}


//根据给定的索引返回字符的属性 NSDictionary 。
-(NSDictionary *) attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range{
    
    return [_backingStore attributesAtIndex:location effectiveRange:range];
}




-(void) replaceCharactersInRange:(NSRange)range withString:(NSString *)str{
    NSLog(@"replaceCharactersInRange:%@ withString: %@",NSStringFromRange(range),str);
    [self beginEditing];
    
    [_backingStore replaceCharactersInRange:range withString:str];
    
    [self edited:NSTextStorageEditedCharacters | NSTextStorageEditedAttributes range:range changeInLength:str.length - range.length];
    
    [self endEditing];
}

-(void)setAttributes:(NSDictionary *)attrs range:(NSRange)range{
    NSLog(@"setAttributes:%@ range:%@",attrs, NSStringFromRange(range));
    
    [self beginEditing];
    [_backingStore setAttributes:attrs range:range];
    
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];

}





-(void) processEditing{
    [self performReplacementsForRange:[self editedRange]];
    [super processEditing];
}

-(void)performReplacementsForRange:(NSRange)changedRange{
    
    NSRange extendedRange = NSUnionRange(changedRange, [[_backingStore string] lineRangeForRange:NSMakeRange(changedRange.location,0)]);
    
    extendedRange = NSUnionRange(changedRange, [[_backingStore string] lineRangeForRange:NSMakeRange(NSMaxRange(changedRange), 0)]);
    NSLog(@"extendedRange.location:%d, extendedRange.length:%d",extendedRange.location, extendedRange.length);
    [self applyStylesToRange:extendedRange];
}

- (void)applyStylesToRange:(NSRange)searchRange
{
    //1.create some fonts
    //创建一个粗体及一个正常字体并使用字体描述器（ font descriptors）来格式化文本
    UIFontDescriptor * fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    
    UIFontDescriptor * boldFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    UIFont * boldFont = [UIFont fontWithDescriptor:boldFontDescriptor size:0.0 ];
    
    UIFont * normalFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    //2. match items surrounded by
    //创建一个正则表达式来定位星号符包围的文本。
    NSString * regexStr = @"(*w+(sw+)**)s";
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive|NSRegularExpressionDotMatchesLineSeparators error:nil];
    
    NSDictionary * boldAttributes = @{NSFontAttributeName:boldFont};
    NSDictionary * normalAttributes = @{NSFontAttributeName:normalFont};
    
    //3 iterate over each match, making the text bold
    //对正则表达式匹配到并返回的文本进行枚举并添加粗体属性
    [regex enumerateMatchesInString:[_backingStore string] options:0 range:searchRange usingBlock:^(NSTextCheckingResult *match,
                                 NSMatchingFlags flags,
                                 BOOL *stop){
        NSRange matchRange = [match rangeAtIndex:1];
        [self addAttributes:boldAttributes range:matchRange];
    
    //4. reset the style to the original
    //   将后一个星号符之后的文本都重置为“常规”样式
        if(NSMaxRange(matchRange) +1 < self.length){
            [self addAttributes:normalAttributes range:NSMakeRange(NSMaxRange(matchRange)+1, 1)];

        }
    }];
    



}




@end
