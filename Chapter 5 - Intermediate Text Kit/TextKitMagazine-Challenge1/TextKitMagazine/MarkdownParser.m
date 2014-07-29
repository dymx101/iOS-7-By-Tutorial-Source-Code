//
//  MarkdownParser.m
//  TextKitMagazine
//
//  Created by Colin Eberhardt on 24/06/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "MarkdownParser.h"

@implementation MarkdownParser {
    NSDictionary* _bodyTextAttributes;
    NSDictionary* _headingOneAttributes;
    NSDictionary* _headingTwoAttributes;
    NSDictionary* _headingThreeAttributes;
}

- (id) init {
    if (self = [super init]) {
        [self createTextAttributes];
    }
    return self;
}

- (void)createTextAttributes {
    // 1. Create the font descriptors
    UIFontDescriptor* baskerville = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                     @{UIFontDescriptorFamilyAttribute: @"Baskerville"}];
    
    UIFontDescriptor* baskervilleBold = [baskerville fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    
    // 2. determine the current text size preference
    UIFontDescriptor* bodyFont = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    NSNumber* bodyFontSize = bodyFont.fontAttributes[UIFontDescriptorSizeAttribute];
    float bodyFontSizeValue = [bodyFontSize floatValue];
    
    // 3. create the attributes for the various formatting styles
    _bodyTextAttributes = [self attributesWithDescriptor:baskerville
                                                    size:bodyFontSizeValue];
    _headingOneAttributes = [self attributesWithDescriptor:baskervilleBold
                                                      size:bodyFontSizeValue * 2.0f];
    _headingTwoAttributes = [self attributesWithDescriptor:baskervilleBold
                                                      size:bodyFontSizeValue * 1.8f];
    _headingThreeAttributes = [self attributesWithDescriptor:baskervilleBold
                                                        size:bodyFontSizeValue * 1.4f];
}

- (NSDictionary*)attributesWithDescriptor:(UIFontDescriptor*)descriptor size:(float)size {
    UIFont* font = [UIFont fontWithDescriptor:descriptor
                                         size:size];
    return @{NSFontAttributeName: font};
}

- (NSAttributedString*)parseMarkdownFile:(NSString *)path {
    NSMutableAttributedString* parsedOutput = [[NSMutableAttributedString alloc] init];
    
    // break the file into lines and iterate over each line
    NSString* text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray* lines = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for(NSUInteger lineIndex=0; lineIndex<lines.count; lineIndex++){
        NSString *line = lines[lineIndex];
        
        // remove empty lines
        if ([line isEqualToString:@""])
            continue;
        
        // match the various 'heading' styles
        NSDictionary* textAttributes = _bodyTextAttributes;
        if (line.length > 3){
            if ([[line substringToIndex:3] isEqualToString:@"###"]) {
                textAttributes = _headingThreeAttributes;
                line = [line substringFromIndex:3];
            } else if ([[line substringToIndex:2] isEqualToString:@"##"]) {
                textAttributes = _headingTwoAttributes;
                line = [line substringFromIndex:2];
            } else if ([[line substringToIndex:1] isEqualToString:@"#"]) {
                textAttributes = _headingOneAttributes;
                line = [line substringFromIndex:1];
            }
        }
        
        // apply the attributes to this line of text
        NSAttributedString* attributedText = [[NSAttributedString alloc] initWithString:line attributes:textAttributes];
        
        // append to the output
        [parsedOutput appendAttributedString:attributedText];
        [parsedOutput appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
    }
    
    // locate images
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\!\\[.*\\]\\((.*)\\)"
                                                                           options:0
                                                                             error:nil];
    NSArray* matches = [regex matchesInString:[parsedOutput string]
                                      options:0
                                        range:NSMakeRange(0, parsedOutput.length)];
    // iterate over matches in reverse
    for (NSTextCheckingResult* result in [matches reverseObjectEnumerator]) {
        NSRange matchRange = [result range];
        NSRange captureRange = [result rangeAtIndex:1];
        
        // create an attachment for each image
        NSTextAttachment* ta = [NSTextAttachment new];
        ta.image = [UIImage imageNamed:[parsedOutput.string substringWithRange:captureRange]];
        
        // replace the image markup with the attachment
        NSAttributedString* rep = [NSAttributedString attributedStringWithAttachment:ta];
        [parsedOutput replaceCharactersInRange:matchRange withAttributedString:rep];
        
    }
    
    return parsedOutput;
}

@end

