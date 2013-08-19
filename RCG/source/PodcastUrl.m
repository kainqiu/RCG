//
//  PodcastUrl.m
//  RCG
//
//  Created by Daniel Ho on 7/24/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import "PodcastUrl.h"

@interface PodcastUrl ()
{
    NSArray *seriesList;
    NSDictionary *dictionary;
    NSString *description;
}

@end

@implementation PodcastUrl

- (id) init
{
    seriesList = @[@"Tribing: creating groups that work", @"Hero's Journey by Paul Rebillot", @"Patterns of Fate and Destiny", @"Metaprogramming", @"Dreams", @"Way of the Warrior", @"Swimming with Dolphins", @"Positive Deviants", @"The Earth as a Sacred Text", @"The Body of Wisdom", @"Adaptive Intelligences", @"Radical NLP", @"Radical Myth", @"8 Circuit Brain Series", @"Radical leaders", @"Radical Profit", @"Radical Science", @"The Alchemy of Voice", @"The 5Rhythms Dance", @"ParaTheatre"];
    dictionary = @{@"Way of the Warrior": @[
                           @"http://www.radicalchangegroup.com/podpress_trac/web/82/0/21-the-way-of-the-warrior-01.mp3",
                           @"http://www.radicalchangegroup.com/podpress_trac/web/85/0/23-the-way-of-the-warrior-2.mp3",
                           @"http://www.radicalchangegroup.com/podpress_trac/web/86/0/24-the-way-of-the-warrior-3.mp3",
                           @"http://www.radicalchangegroup.com/podpress_trac/web/1526/0/154-Way-of-the-Warrior-part-4-Tradition-and-Teacher.mp3",
                           @"http://www.radicalchangegroup.com/podpress_trac/web/1529/0/155-Way-of-the-Warrior-part-5-Evolution-and-Approaches.mp3",
                           @"http://www.radicalchangegroup.com/podpress_trac/web/1532/0/156-Way-of-the-Warrior-part-6-Humility-and-Art.mp3",
                           @"http://www.radicalchangegroup.com/podpress_trac/web/1535/0/157-Way-of-the-Warrior-part-7-Change-and-Learning.mp3"
                           ]
                   , @"Tribing: creating groups that work": @[
                           @"http://www.radicalchangegroup.com/podpress_trac/web/1932/0/212-Tribing-part-1-Introduction.mp3",
                           @"http://www.radicalchangegroup.com/podpress_trac/web/1950/0/213-Tribing-part-2-Modeling-Skills.mp3",
                           @"http://www.radicalchangegroup.com/podpress_trac/web/1953/0/214-Tribing-part-3-Modeling-People.mp3",
                           @"http://www.radicalchangegroup.com/podpress_trac/web/1956/0/215-Tribing-part-4-Modeling-Self.mp3",
                           @"http://www.radicalchangegroup.com/podpress_trac/web/1959/0/216-Tribing-part-5-Modeling-Conclusion.mp3",
                           @"http://www.radicalchangegroup.com/podpress_trac/web/2432/0/217-Tribing-part-6-RCG-Story.mp3",
                           @"http://www.radicalchangegroup.com/podpress_trac/web/2441/0/218-Tribing-part-7-Stages.mp3",
                           @"http://www.radicalchangegroup.com/podpress_trac/web/2444/0/219-Tribing-part-8-Roles.mp3",
                           @"http://www.radicalchangegroup.com/podpress_trac/web/2452/0/220-Tribing-part-9-Attributes.mp3",
                           @"http://www.radicalchangegroup.com/podpress_trac/web/2454/0/221-Tribing-part-10-Syntax-Introduction.mp3",
                           @"http://www.radicalchangegroup.com/podpress_trac/web/2469/0/222-Tribing-part-11-Vision.mp3",
                           @"http://www.radicalchangegroup.com/podpress_trac/web/2475/0/223-Tribing-part-12-aligning-values.mp3",
                           @"http://www.radicalchangegroup.com/podpress_trac/web/2485/0/224-Tribing-part-13-Bringing-Roles-Together.mp3",
                           @"http://www.radicalchangegroup.com/podpress_trac/web/2487/0/225-Tribing-part-15-Last-Three-Steps.mp3"]};
    description = @"We are continuing our series of podcasts on what we term as “Tribe-ing”, a process by which groups function exquisitely well together towards a common goal. We explore the process of modeling and apply it to tribe-ing.";
    return self;
}

- (NSArray *) getSeriesList
{
    return seriesList;
}

- (NSArray *) getEpisodeList:(NSString *)seriesName
{
    return [dictionary objectForKey:seriesName];
}

- (NSString *) getURLForSeries:(NSString *)seriesName episodeNumber:(int)number
{
    NSArray *series = [dictionary objectForKey:seriesName];
    return [series objectAtIndex:number];
    
}

- (NSString *) getDescription:(NSString *)seriesName
{
    return description;
}


@end
