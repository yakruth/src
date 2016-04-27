//
//  VoiceRecogiser.h
//  Meli FFI Mobile Application
//
//  Created by ITSSTS on 12/3/15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

#ifndef VoiceRecogiser_h
#define VoiceRecogiser_h

//#import <OpenEars/OEEventsObserver.h> // We need to import this here in order to use the delegate.

@class VoiceRecogniser;

@protocol VoiceRecogniserDelegate <NSObject>

@required
- (void)voiceRecogniser:(VoiceRecogniser *)voicerecogniser recognisedString:(NSString *)string;

@end

@interface VoiceRecogniser : NSObject /*<OEEventsObserverDelegate>*/

@property (assign) id <VoiceRecogniserDelegate> delegate;
@property (assign) NSInteger usingStartingLanguageModel;
@property (strong) NSArray *stringArray;

/* Shared Instance Method */
+ (VoiceRecogniser *)sharedInstance;

/* Init Method */
- (void)initOpenEars;

/* Load Method */
//- (void)loadOpenEars;

/* Change Model Path Method */
- (void)changePathToSuccessfullyGeneratedModel;

/* Stop & Start Listening Methods */
- (void)stopListening;
- (void)startListening;

@end



#endif /* VoiceRecogiser_h */
