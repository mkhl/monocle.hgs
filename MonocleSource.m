//
//  MonocleSource.m
//
//  Copyright (c) 2009  Martin Kuehl <purl.org/net/mkhl>
//  Licensed under the MIT License.
//

#import <Vermilion/Vermilion.h>

static NSString *const kMonocleBundleIdentifier = @"net.wafflesoftware.Monocle";
static NSString *const kMonocleEnginesKey = @"engines";
static NSString *const kMonocleEngineNameKey = @"name";
static NSString *const kMonocleEngineShortcutKey = @"callword";
static NSString *const kMonocleEngineURLKey = @"get_URL";
static NSString *const kMonocleEngineIconKey = @"icon";
static NSString *const kMonocleValidEnginePredicateFormat = @"type == 'GET'";

static NSURL *_MonocleBaseURL(const NSURL *const url)
{
  NSString *urlString
    = [NSString stringWithFormat:@"%@://%@", [url scheme], [url host]];
  return [NSURL URLWithString:urlString];
}


@interface MonocleSource : HGSMemorySearchSource
- (void)recacheContents;
- (void)indexResultForEngine:(NSDictionary *)engine;
@end

@implementation MonocleSource

- (id)initWithConfiguration:(NSDictionary *)configuration
{
  self = [super initWithConfiguration:configuration];
  if (self == nil)
    return nil;
  if (![self loadResultsCache]) {
    [self recacheContents];
  } else {
    [self performSelector:@selector(recacheContents)
               withObject:nil
               afterDelay:10.0];
  }
  return self;
}

- (void)recacheContents
{
  [self clearResultIndex];
  NSDictionary *settings = [[NSUserDefaults standardUserDefaults]
                            persistentDomainForName:kMonocleBundleIdentifier];
  NSPredicate *predicate
    = [NSPredicate predicateWithFormat:kMonocleValidEnginePredicateFormat];
  NSArray *engines = [[settings objectForKey:kMonocleEnginesKey]
                      filteredArrayUsingPredicate:predicate];
  for (NSDictionary *engine in engines) {
    [self indexResultForEngine:engine];
  }
  [self performSelector:@selector(recacheContents)
             withObject:nil
             afterDelay:60.0];
}

- (void)indexResultForEngine:(NSDictionary *)engine
{
  NSString *name = [engine objectForKey:kMonocleEngineNameKey];
  NSString *urlFormat = [engine objectForKey:kMonocleEngineURLKey];
  NSString *template
    = [urlFormat stringByReplacingOccurrencesOfString:@"%@"
                                           withString:@"{searchterms}"];
  NSString *urlString
    = [urlFormat stringByReplacingOccurrencesOfString:@"%@"
                                           withString:@"magic"];
  NSURL *url = _MonocleBaseURL([NSURL URLWithString:urlString]);
  NSData *data = [engine objectForKey:kMonocleEngineIconKey];
  NSImage *icon = [NSUnarchiver unarchiveObjectWithData:data];
  NSDictionary *attrs
    = [NSDictionary dictionaryWithObjectsAndKeys:
//       url, kHGSObjectAttributeSourceURLKey,
       icon, kHGSObjectAttributeIconKey,
       template, kHGSObjectAttributeWebSearchTemplateKey, nil];
  HGSResult *result = [HGSResult resultWithURL:url
                                          name:name
                                          type:kHGSTypeWebpage
                                        source:self
                                    attributes:attrs];
  [self indexResult:result];
}

@end
