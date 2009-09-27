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

static NSString *_MonocleItemTemplate(NSString *const urlFormat)
{
  return [urlFormat stringByReplacingOccurrencesOfString:@"%@" withString:@"{searchterms}"];
}

static NSURL *_MonocleItemURL(NSString *const urlFormat)
{
  NSURL *url = [NSURL URLWithString:[urlFormat stringByReplacingOccurrencesOfString:@"%@" withString:@"magic"]];
  return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", [url scheme], [url host]]];
}


@interface MonocleSource : HGSMemorySearchSource
- (void)recacheContents;
- (void)recacheContentsAfterDelay:(NSTimeInterval)delay;
- (void)indexResultForEngine:(NSDictionary *)engine;
@end

@implementation MonocleSource

- (id)initWithConfiguration:(NSDictionary *)configuration
{
  self = [super initWithConfiguration:configuration];
  if (self) {
    if ([self loadResultsCache]) {
      [self recacheContentsAfterDelay:10.0];
    } else {
      [self recacheContents];
    }
  }
  return self;
}

- (void)recacheContents
{
  [self clearResultIndex];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *dict = [defaults persistentDomainForName:kMonocleBundleIdentifier];
  NSArray *engines = [dict objectForKey:kMonocleEnginesKey];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:kMonocleValidEnginePredicateFormat];
  for (NSDictionary *engine in [engines filteredArrayUsingPredicate:predicate]) {
    [self indexResultForEngine:engine];
  }
  [self recacheContentsAfterDelay:60.0];
}

- (void)recacheContentsAfterDelay:(NSTimeInterval)delay
{
  SEL action = @selector(recacheContents);
  [self performSelector:action withObject:nil afterDelay:delay];
}

- (void)indexResultForEngine:(NSDictionary *)engine
{
  NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
  NSString *name = [engine objectForKey:kMonocleEngineNameKey];
  NSString *urlFormat = [engine objectForKey:kMonocleEngineURLKey];
  NSString *template = _MonocleItemTemplate(urlFormat);
  [attrs setObject:template forKey:kHGSObjectAttributeWebSearchTemplateKey];
  NSURL *url = _MonocleItemURL(urlFormat);
  NSData *data = [engine objectForKey:kMonocleEngineIconKey];
  NSImage *icon = [NSUnarchiver unarchiveObjectWithData:data];
  if (icon) [attrs setObject:icon forKey:kHGSObjectAttributeIconKey];
  [self indexResult:[HGSResult resultWithURL:url
                                        name:name
                                        type:kHGSTypeWebpage
                                      source:self
                                  attributes:attrs]];
}

@end
