//
//  RSSPodcastParser.m
//  RCG
//
//  Created by Jonathan Ritchey on 7/25/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import "RSSPodcastParser.h"

#define DATA_ATTRIBUTE_COUNT 6

typedef enum 
{
    kCaptureMode_Inactive    = 0,
    kCaptureMode_Title       = 1,
    kCaptureMode_Category    = 2,
    kCaptureMode_Description = 3,
    kCaptureMode_Pubdate     = 4,
    kCaptureMode_Content     = 5,
} CaptureMode;

@interface RSSPodcastParser()
{
    BOOL isBlog;
}

@property (nonatomic, strong) NSXMLParser *parser;
@property (nonatomic, strong) CompletionBlock completionBlock;
@property (nonatomic, strong) NSMutableString *titleScratch;
@property (nonatomic, strong) NSMutableData *categoryDataScratch;
@property (nonatomic, strong) NSMutableString *category;
@property (nonatomic, strong) NSString *series;
@property (nonatomic, assign) CaptureMode captureMode;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *podcastSet;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) int titleNumber;
@property (nonatomic, strong) NSMutableDictionary *dictionary;
// add by Jon
@property (nonatomic, strong) NSURL *theURL;

@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSMutableData *descriptionDataScratch;
@property (nonatomic, strong) NSString *pubdate;
@property (nonatomic, strong) NSMutableString *pubdateScratch;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSMutableData *contentScratch;

// debugging flags
@property (nonatomic, assign) BOOL debugFeedVerbose; // verbose rss feed parsing.
@property (nonatomic, assign) BOOL debugSeriesTitleParsing; // verbose series name extraction.
@property (nonatomic, assign) BOOL debugDictionary; // output dictionary contents after parsing.
// end debugging.

@end

@implementation RSSPodcastParser

static NSString *gCacheFilePathExtension = @"/rssfeed_data.dat";

- (id) initWithURL: (NSString*) urlString
{
    if ( self = [super init] )
    {
        self.theURL = [NSURL URLWithString:urlString];
        // self.debugFeedVerbose = YES;        // enable to see verbose rss feed parsing.
        // self.debugSeriesTitleParsing = YES; // enable to see title extraction process.
        // self.debugDictionary = YES;         // enable to print out dictionary after parsing.
    }
    return self;
}

- (NSString *) getRSSDocumentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *rssDataPath = [NSString stringWithFormat:@"%@%@",documentsDirectory,gCacheFilePathExtension];
    return rssDataPath;
}

- (void) clearParsingData
{
    self.dictionary = nil;
    [self clearRecordFields];
}

- (void) startParsingCache:(CompletionBlock) completionBlock
{
    // empty out records and dictionary
    [self clearParsingData];
    
    // check and see if cached data already exists, if so, then parse it first.
    NSString *rssDataPath = [self getRSSDocumentPath];
    NSData *rssCachedData = [[NSData alloc]initWithContentsOfFile:rssDataPath];
    
    BOOL isOKToParse = false;
    
    if ( rssCachedData )
    {
        // cached file from previous run exists...
        // this should be fast...
        isOKToParse = true;
    }
    else
    {
        // no cached file, check and see if resource data is available
        rssDataPath = [[NSBundle mainBundle]resourcePath];
        rssDataPath = [rssDataPath stringByAppendingString:gCacheFilePathExtension];
        rssCachedData = [[NSData alloc]initWithContentsOfFile:rssDataPath];
        NSLog(@"resDataPath %@",rssDataPath);
        
        if ( rssCachedData )
        {
            isOKToParse = true;
        }
        else
        {
            completionBlock(false,nil);
        }
    }

    if ( isOKToParse )
    {
        self.parser = [[NSXMLParser alloc] initWithData:rssCachedData];
        
        [self.parser setDelegate:self];
        self.captureMode = kCaptureMode_Inactive;
        self.completionBlock = completionBlock;
        //});
        [self.parser parse];
    }

}

- (void) startParsing: (CompletionBlock) completionBlock
{
    // empty out records and dictionary
    [self clearParsingData];

    NSData *data = [NSData dataWithContentsOfURL:self.theURL];
    // used to test updating data. to test comment out "NSData *data = [NSData dataWithContentsOfURL:self.theURL] and uncomment the line below.
    // then swap, check to see if UI and contents update appropriately.
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://www.thewindtradition.com/feed/"]];
    [data writeToFile:[self getRSSDocumentPath] atomically:YES];
    
    self.parser = [[NSXMLParser alloc] initWithData:data];
    [self.parser setDelegate:self];
    self.captureMode = kCaptureMode_Inactive;
    self.completionBlock = completionBlock;
    [self.parser parse];
}

- (NSString *) matchCategoryInSeries: (NSString *) category
{
    if ( [category compare:@"Tribing"]                      == NSOrderedSame ) return category;
    if ( [category compare:@"Hero's Journey"]               == NSOrderedSame ) return category;
    if ( [category compare:@"Patterns of Fate and Destiny"] == NSOrderedSame ) return category;
    if ( [category compare:@"Metaprogramming"]              == NSOrderedSame ) return category;
    if ( [category compare:@"Dreams"]                       == NSOrderedSame ) return category;
    if ( [category compare:@"The Way of the Warrior"]       == NSOrderedSame ) return category;
    if ( [category compare:@"Swimming with Dolphins"]       == NSOrderedSame ) return category;
    if ( [category compare:@"Positive Deviancy"]            == NSOrderedSame ) return category;
    if ( [category compare:@"The Earth as a Sacred Text"]   == NSOrderedSame ) return category;
    if ( [category compare:@"The Body of Wisdom"]           == NSOrderedSame ) return category;
    if ( [category compare:@"Adaptive Intelligences"]       == NSOrderedSame ) return category;
    if ( [category compare:@"Radical NLP"]                  == NSOrderedSame ) return category;
    if ( [category compare:@"Radical Myth"]                 == NSOrderedSame ) return category;
    if ( [category compare:@"8 Circuit Brain Series"]       == NSOrderedSame ) return category;
    if ( [category compare:@"Radical Leaders"]              == NSOrderedSame ) return category;
    if ( [category compare:@"Radical Profit"]               == NSOrderedSame ) return category;
    if ( [category compare:@"Radical Science"]              == NSOrderedSame ) return category;
    if ( [category compare:@"The Alchemy of Voice"]         == NSOrderedSame ) return category;
    if ( [category compare:@"5Rhythms"]                     == NSOrderedSame ) return category;
    if ( [category compare:@"ParaTheatre"]                  == NSOrderedSame ) return category;
    
    if ( [category compare:@"Blog"]                         == NSOrderedSame ) return category;
    if ( [category compare:@"Announcements"]                == NSOrderedSame ) return category;
    
    return nil;
}

- (int) extractTitleNumberFromTitle: (NSString *) title
{
    NSCharacterSet *acceptableSet = [ NSCharacterSet characterSetWithCharactersInString:@" 0123456789" ];
    NSCharacterSet *invertedSet = [ acceptableSet invertedSet ];
    NSString *acceptableCharString = [ [ title componentsSeparatedByCharactersInSet:invertedSet ] componentsJoinedByString:@"" ];
    
    NSCharacterSet *spaceSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
    NSString *trimmedString = [acceptableCharString stringByTrimmingCharactersInSet:spaceSet];
    NSRange part1Range = [trimmedString rangeOfString:@" "];
    NSString *part1;
    int titleNumber = 0;
    if ( part1Range.location != NSNotFound )
    {
        part1 = [trimmedString substringToIndex:part1Range.location];
        titleNumber = [part1 integerValue];
    }
    else
    {
        // only has one number inside
        titleNumber = [trimmedString integerValue];
    }
    return titleNumber;
}

- (NSString *) extractSeriesFromTitle: (NSString *) title
{
    NSCharacterSet *acceptableSet = [ NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ :0123456789-&–" ];
    NSCharacterSet *invertedSet = [ acceptableSet invertedSet ];
    NSString *acceptableCharString = [ [ title componentsSeparatedByCharactersInSet:invertedSet ] componentsJoinedByString:@"" ];
    NSRange titleRange = [acceptableCharString rangeOfString:@"title"];
    NSString *noTitleString;
    if ( titleRange.location != NSNotFound )
    {
        noTitleString = [acceptableCharString substringFromIndex:titleRange.location+titleRange.length];
    }
    else
    {
        noTitleString = acceptableCharString;
    }
    NSString *noPartString;
    NSRange partRange = [noTitleString rangeOfString:@"part"];
    if ( partRange.location != NSNotFound )
    {
        noPartString = [noTitleString substringToIndex:partRange.location];
    }
    else
    {
        noPartString = noTitleString;
    }
    // remove numbers and spaces from either end of the string.
    NSCharacterSet *numbersAndSpaceSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789 "];
    NSString *trimmedString = [noPartString stringByTrimmingCharactersInSet:numbersAndSpaceSet];
    if ( self.debugSeriesTitleParsing )
    {
        NSLog(@"acceptableString %@",acceptableCharString);
        NSLog(@"noTitleString %@",noTitleString);
        NSLog(@"noPartString %@",noPartString);
        NSLog(@"trimmedString %@",trimmedString);
    }
    return trimmedString;
}

- (void) insertRecordIntoDictionary
{
    if ( self.dictionary == nil )
    {
        self.dictionary = [[NSMutableDictionary alloc]initWithCapacity:500];
    }
    if ( self.series == nil )
    {
        self.series = @"Other";
    }
    if ( [self.dictionary objectForKey:self.series] == nil )
    {
        // series key doesn't exist yet.
        // create NSMutableArray for urls and titles
        NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:DATA_ATTRIBUTE_COUNT];
        NSMutableArray *urlArray = [[NSMutableArray alloc]initWithObjects:self.url, nil];
        NSMutableArray *titleArray = [[NSMutableArray alloc]initWithObjects:self.title, nil];
        NSMutableArray *titleNumberArray = [[NSMutableArray alloc]initWithObjects:@(self.titleNumber), nil];
        NSMutableArray *descriptionArray = [[NSMutableArray alloc]initWithObjects:self.description, nil];
        NSMutableArray *pubdateArray = [[NSMutableArray alloc]initWithObjects:self.pubdate, nil];
        NSMutableArray *contentArray = [[NSMutableArray alloc]initWithObjects:self.content, nil];
        [array setObject:urlArray atIndexedSubscript:kPodcastDict_URLIndex];
        [array setObject:titleArray atIndexedSubscript:kPodcastDict_TitleIndex];
        [array setObject:titleNumberArray atIndexedSubscript:kPodcastDict_TitleNumberIndex];
        [array setObject:descriptionArray atIndexedSubscript:kPodcastDict_DescriptionIndex];
        [array setObject:pubdateArray atIndexedSubscript:kPodcastDict_PubdateIndex];
        [array setObject:contentArray atIndexedSubscript:kPodcastDict_ContentIndex];
        [self.dictionary setObject:array forKey:self.series];
    }
    else
    {
        // series key does exist, we need to append to the arrays.
        NSMutableArray *array = [self.dictionary objectForKey:self.series];
        NSMutableArray *urlArray = [array objectAtIndex:kPodcastDict_URLIndex];
        NSMutableArray *titleArray = [array objectAtIndex:kPodcastDict_TitleIndex];
        NSMutableArray *titleNumberArray = [array objectAtIndex:kPodcastDict_TitleNumberIndex];
        NSMutableArray *descriptionArray = [array objectAtIndex:kPodcastDict_DescriptionIndex];
        NSMutableArray *pubdateArray = [array objectAtIndex:kPodcastDict_PubdateIndex];
        NSMutableArray *contentArray = [array objectAtIndex:kPodcastDict_ContentIndex];
        if ( self.url)
            [urlArray addObject:self.url];
        if (self.title)
            [titleArray addObject:self.title];
        [titleNumberArray addObject:@(self.titleNumber)];
        if (self.description)
            [descriptionArray addObject:self.description];
        if (self.pubdate)
            [pubdateArray addObject:self.pubdate];
        if (self.content)
            [contentArray addObject:self.content];
    }
}

- (void) clearRecordFields
{
    self.podcastSet             = nil;
    self.title                  = nil;
    self.series                 = nil;
    self.titleNumber            = 0;
    self.url                    = nil;
    self.titleScratch           = nil;
    self.categoryDataScratch    = nil;
    self.category               = nil;
    self.description            = nil;
    self.descriptionDataScratch = nil;
    self.pubdate                = nil;
    self.content                = nil;
    self.contentScratch         = nil;
}

#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ( [elementName compare:@"item"] == NSOrderedSame )
    {
        // clear out record?
        [self clearRecordFields];
    }
    else if ( [elementName compare:@"category"] == NSOrderedSame )
    {
        self.captureMode = kCaptureMode_Category;
        self.categoryDataScratch = [[NSMutableData alloc]init];
    }
    else if ( [elementName compare:@"title"] == NSOrderedSame )
    {
        self.captureMode = kCaptureMode_Title;
        self.titleScratch = [NSMutableString string];
    }
    else if ( [elementName compare:@"enclosure"] == NSOrderedSame && [self.series compare:@"Blog"] != NSOrderedSame)
    {
        NSString *type = [attributeDict objectForKey:@"type"];
        
        if ( [type compare:@"audio/mpeg"] == NSOrderedSame)
        {
            self.url = [attributeDict objectForKey:@"url"];
            if ( self.debugFeedVerbose )
            {
                NSLog(@"series: %@", self.series);
                NSLog(@"set: %@", self.podcastSet);
                NSLog(@"title: %@", self.title);
                NSLog(@"number: %d", self.titleNumber);
                NSLog(@"url: %@", self.url);
                NSLog(@"description: %@", self.description);
                NSLog(@"pubdate: %@", self.pubdate);
                NSLog(@"-------");
            }
            [self insertRecordIntoDictionary];
            
        }
    } else if ([elementName compare:@"description"] == NSOrderedSame)
    {
        self.captureMode = kCaptureMode_Description;
        self.descriptionDataScratch = [[NSMutableData alloc] init];
    } else if ([elementName compare:@"pubDate"] == NSOrderedSame) {
        self.captureMode = kCaptureMode_Pubdate;
        self.pubdateScratch = [[NSMutableString alloc] init];
        
    } else if ([elementName compare:@"content:encoded"] == NSOrderedSame) {
        self.captureMode = kCaptureMode_Content;
        self.contentScratch = [[NSMutableData alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //from parser:foundCharacters: docs:
    //The parser object may send the delegate several parser:foundCharacters: messages to report the characters of an element.
    //Because string may be only part of the total character content for the current element, you should append it to the current
    //accumulation of characters until the element changes.

    switch (self.captureMode )
    {
        case kCaptureMode_Title:
            [self.titleScratch appendString:string];
            break;
        case kCaptureMode_Category:
            // do nothing, category data is inside CDATA object.
            break;
        case kCaptureMode_Description:
            break;
        case kCaptureMode_Pubdate:
            [self.pubdateScratch appendString:string];
            break;
        case kCaptureMode_Content:
            break;
        default: break;
    }
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    // this reports a CDATA block to the delegate as an NSData.
    switch ( self.captureMode )
    {
        case kCaptureMode_Title:
            break;
        case kCaptureMode_Category:
            [self.categoryDataScratch appendData:CDATABlock];
            break;
        case kCaptureMode_Description:
            //NSLog(@"foundCDATA for description");
            [self.descriptionDataScratch appendData:CDATABlock];
            break;
        case kCaptureMode_Pubdate:
            break;
        case kCaptureMode_Content:
            [self.contentScratch appendData:CDATABlock];
            break;
        default: break;
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ( [elementName compare:@"title"] == NSOrderedSame )
    {
        // NSMutableArray
        self.title = self.titleScratch;
        self.titleNumber = [self extractTitleNumberFromTitle:self.title];
        
        self.titleScratch = nil;
        self.captureMode = kCaptureMode_Inactive;

        // key
        self.podcastSet = [self extractSeriesFromTitle:self.title];
    } else if ( [elementName compare:@"pubDate"] == NSOrderedSame)
    {
        self.pubdate = self.pubdateScratch;
        self.pubdate = [self.pubdate substringWithRange:NSMakeRange(5, 11)];
        self.pubdateScratch = nil;
        self.captureMode = kCaptureMode_Inactive;
    }
    else if ( [elementName compare:@"category"] == NSOrderedSame )
    {
        self.category = [[NSMutableString alloc] initWithData:self.categoryDataScratch encoding:NSUTF8StringEncoding];
        if ( self.debugFeedVerbose ) NSLog(@"category string: %@",self.category);
        NSString *seriesCandidate = [self matchCategoryInSeries:self.category];
        if ( seriesCandidate != nil ) self.series = seriesCandidate;
        if ([self.category compare:@"Blog"] == NSOrderedSame) isBlog = YES;
    } else if ( [elementName compare:@"description"] == NSOrderedSame)
    {
        self.description = [[NSMutableString alloc] initWithData:self.descriptionDataScratch encoding:NSUTF8StringEncoding];
        if ( self.debugFeedVerbose ) NSLog(@"description %@", self.description);
        self.description = [self decodeHtmlUnicodeCharactersToString:self.description];
    } else if ( [elementName compare:@"content:encoded"] == NSOrderedSame)
    {
        
        self.content = [[NSMutableString alloc] initWithData:self.contentScratch encoding:NSUTF8StringEncoding];
        //self.content = [self decodeHtmlUnicodeCharactersToString:self.content];

        if ([self.series compare:@"Blog"]          == NSOrderedSame ||
            [self.series compare:@"Announcements"] == NSOrderedSame)
        {
            if ( self.debugFeedVerbose )
            {
                NSLog(@"series: %@", self.series);
                NSLog(@"set: %@", self.podcastSet);
                NSLog(@"title: %@", self.title);
                NSLog(@"number: %d", self.titleNumber);
                NSLog(@"url: %@", self.url);
                NSLog(@"description: %@", self.description);
                NSLog(@"pubdate: %@", self.pubdate);
                NSLog(@"content scratch %@", self.contentScratch.description);
                NSLog(@"content: %@", self.content);
                NSLog(@"-------");
            }
            [self insertRecordIntoDictionary];
        }
    }
}

- (NSString*) decodeHtmlUnicodeCharactersToString:(NSString*)str
{
    NSMutableString* string = [[NSMutableString alloc] initWithString:str];  // #&39; replace with '
    NSString* unicodeStr = nil;
    NSString* replaceStr = nil;
    int counter = -1;
    
    for(int i = 0; i < [string length]; ++i)
    {
        unichar char1 = [string characterAtIndex:i];
        for (int k = i + 1; k < [string length] - 1; ++k)
        {
            unichar char2 = [string characterAtIndex:k];
            
            if (char1 == '&'  && char2 == '#' )
            {
                ++counter;
                unicodeStr = [string substringWithRange:NSMakeRange(i + 2 , 2)];
                // read integer value i.e, 39
                replaceStr = [string substringWithRange:NSMakeRange (i, 5)];     //     #&39;
                [string replaceCharactersInRange: [string rangeOfString:replaceStr] withString:@""];
                break;
            }
        }
    }

    
    if (counter > 1)
        return  [self decodeHtmlUnicodeCharactersToString:string];
    else
        return string;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:self.dictionary];
    self.completionBlock(true,dict);
        
    if ( self.debugDictionary ) NSLog(@"dictionary %@",self.dictionary);
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"parser: parseErrorOccurred: %@",parseError);
    // ...and this reports a fatal error to the delegate. The parser will stop parsing.
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    // If validation is on, this will report a fatal validation error to the delegate. The parser will stop parsing.
    NSLog(@"parser: validationErrorOccurred: %@",validationError);
}

@end
