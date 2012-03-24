//DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
//Version 2, December 2004 
//
//Copyright (C) 2004 Sam Hocevar <sam@hocevar.net> 
//
//Everyone is permitted to copy and distribute verbatim or modified 
//copies of this license document, and changing it is allowed as long 
//as the name is changed. 
//
//DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
//TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION 
//
//0. You just DO WHAT THE FUCK YOU WANT TO. 
//
/* This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details. */

#import "Console.h"
#import <ncurses.h>
#import "SCUtil.h"

#import "SMXMLDocument.h"
#import "SMXMLDocument+Utils.h"

@interface Console()
- (void) buildGUI;
- (void) buildHeading;
// -
- (void) runLoop;
@end

@implementation Console
@synthesize pageNumber;

- (id)init {
    self = [super init];
    if(self) {
        [self setPageNumber:1];
        
        SCInitScreen();
        
        [self buildGUI];
        
        while(true) {
            [self runLoop];
        }
        
        SCCleanup();
    }
    return self;
}

- (void)buildHeading {
    NSString *divider = @"===================================";
    SCWriteBoldLineAtPoint(CGPointMake(0, 0), divider);
    SCMove(CGPointMake(0, 1));
    SCWriteString(@"Sickipedia CLI -");
    SCWriteBoldString(@" Dylan Janeke\n");
    SCWriteBoldLineAtPoint(CGPointMake(0, 2), divider);

    SCMove(CGPointMake(0, 3));
    SCWriteBoldString(@"Options: ");
    SCWriteString(@"Previous [");
    SCWriteBoldString(@"<");
    SCWriteString(@"] Next [");
    SCWriteBoldString(@">");
    SCWriteString(@"] :)");
}
    
- (void)buildGUI {
    [self buildHeading];
}

- (void)setLoading:(BOOL)isLoading {
    SCMove(CGPointMake(0, 5));
    if(isLoading) {
        SCWriteBoldString(@"> Loading...");
    } else {
        SCWriteBoldString(@"            ");
    }
    
    SCRebuildScreen();
}

- (void)runLoop {
    SCMove(CGPointMake(0, 4));
    SCWriteString(@"Current Page: ");
    SCWriteBoldString([NSString stringWithFormat:@"%d      ", pageNumber]);
    
    [self setLoading:YES];
    
    NSString *root = @"http://sickipedia.org/ajax/getjokes/today";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%i", root, pageNumber]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url 
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad 
                                         timeoutInterval:15];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request 
                                         returningResponse:&response 
                                                     error:&error];
    
    NSString *responseString = [[NSString alloc] initWithData:data 
                                                     encoding:NSUTF8StringEncoding];
    NSString *responseXML = [NSString stringWithFormat:@"%@%@%@", @"<html>", responseString, @"</html>"];
    
    [self setLoading:NO];

    CGSize screenSize = SCGetScreenSize();
    
    if(error != nil) {
        CGPoint center = CGPointMake(screenSize.width / 2, screenSize.height / 2);
        SCMove(center);
        SCWriteBoldString([error localizedDescription]);
    }
    
    SCMove(CGPointMake(0, 6));
    SCWriteString(@"Loaded ");
    SCWriteBoldString([NSString stringWithFormat:@"%d", data.length]);
    SCWriteString(@" bytes.");
    
    SCRebuildScreen();
  
    SCMove(CGPointMake(0, 8));
    for (int x = 8; x <= screenSize.height; x++) {
        SCWriteLine(@"                                                                                                               ");
    }
    SCMove(CGPointMake(0, 8));
    
    responseXML = [responseXML stringByReplacingOccurrencesOfString:@"&nbsp" withString:@" "];
    responseXML = [responseXML stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:responseXML 
                                                               options:nil 
                                                                 error:&error];    
    NSXMLElement *htmlElement = [document rootElement];
    
    NSString *childCountMessage = [NSString stringWithFormat:@"Loaded %d Jokes.", 
                                   [htmlElement childCount]];
    SCWriteBoldLine(childCountMessage);
    
    if([htmlElement childCount] == 10) {
        NSArray *divs = [htmlElement children];
        for (NSXMLElement *div in divs) {
            
            NSArray *divChildren = [div children];
            for (NSXMLElement *divChild in divChildren) {
                NSXMLNode *classNode = [divChild attributeForName:@"class"];
                if(classNode != nil) {
                    NSXMLElement *td = [[[divChild childAtIndex:0] childAtIndex:0] childAtIndex:0];
                    NSString *joke = [[td stringValue] stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
                    joke = [joke stringByReplacingOccurrencesOfString:@"\t" withString:@""];
                    SCWriteLine(joke);
                    SCWriteBoldLine(@"---------------------------------->");
                }
            }
        }
    }
    
    SCKeyCode key = SCRead();
    
    if( key == 62 || key == 10) { 
        [self setPageNumber:self.pageNumber + 1];
    } else if ( key == 60 || key == 127 ) {
        [self setPageNumber:self.pageNumber - 1];
        if(self.pageNumber < 1) {
            [self setPageNumber:1];
        }
    } else if ( key == 27 ) {
        SCWriteBoldString(@"Goodbye!");
        exit(0);
    }
}

@end