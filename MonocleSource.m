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
- (BOOL) loadMonocleEngines;
- (void) indexResultForEngine:(NSDictionary *)engine;
@end

@implementation MonocleSource

- (id) initWithConfiguration:(NSDictionary *)configuration
{
  self = [super initWithConfiguration:configuration];
  if (self == nil)
    return nil;
  if (![self loadMonocleEngines]) {
    HGSLogDebug(@"Unable to load Monocle Search Engines");
    [self release];
    return nil;
  }
  return self;
}

- (BOOL) loadMonocleEngines
{
  [self clearResultIndex];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *settings
    = [defaults persistentDomainForName:kMonocleBundleIdentifier];
  if (settings == nil) {
    return NO;
  }
  NSPredicate *predicate
    = [NSPredicate predicateWithFormat:kMonocleValidEnginePredicateFormat];
  NSArray *engines = [[settings objectForKey:kMonocleEnginesKey]
                      filteredArrayUsingPredicate:predicate];
  if ((engines == nil) || ([engines count] == 0)) {
    return NO;
  }
  for (NSDictionary *engine in engines) {
    [self indexResultForEngine:engine];
  }
  return YES;
}

- (void) indexResultForEngine:(NSDictionary *)engine
{
  NSString *name = [engine objectForKey:kMonocleEngineNameKey];
  NSString *shortcut = [engine objectForKey:kMonocleEngineShortcutKey];
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
  [self indexResult:result name:shortcut otherTerm:name];
}

@end
