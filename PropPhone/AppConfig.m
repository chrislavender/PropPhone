



#import "AppConfig.h"

static AppConfig *instance;

@implementation AppConfig

@synthesize name=_name;

// Initialization
- (id) init {
  _name = @"unknown";
  return self;
}


// Cleanup


// Automatically initialize if called for the first time
+ (AppConfig*) getInstance {
  @synchronized([AppConfig class]) {
    if ( instance == nil ) {
      instance = [[AppConfig alloc] init];
    }
  }
  
  return instance;
}

@end
