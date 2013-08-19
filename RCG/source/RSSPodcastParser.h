//
//  RSSPodcastParser.h
//  RCG
//
//  Created by Jonathan Ritchey on 7/25/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

enum
{
    kPodcastDict_URLIndex = 0,
    kPodcastDict_TitleIndex = 1,
    kPodcastDict_TitleNumberIndex = 2,
    kPodcastDict_DescriptionIndex = 3,
    kPodcastDict_PubdateIndex = 4,
    kPodcastDict_ContentIndex = 5,
};

typedef void (^CompletionBlock)(BOOL success, NSDictionary *dictionary);

@interface RSSPodcastParser : NSObject <NSXMLParserDelegate>

- (id) initWithURL: (NSString*) urlString;
- (void) startParsingCache:(CompletionBlock) completionBlock;
- (void) startParsing: (CompletionBlock) completionBlock;

@end
