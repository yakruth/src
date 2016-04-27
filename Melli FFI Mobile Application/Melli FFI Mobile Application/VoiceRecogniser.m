//
//  VoiceRecogiser.m
//  Meli FFI Mobile Application
//
//  Created by ITSSTS on 12/3/15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

#import "VoiceRecogniser.h"
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEFliteController.h>
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OELogging.h>
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEEventsObserver.h>
#import <Slt/Slt.h>


@interface VoiceRecogniser()

// These three are the important OpenEars objects that this class demonstrates the use of.
@property (nonatomic, strong) Slt *slt;

@property (nonatomic, strong) OEEventsObserver *openEarsEventsObserver;
@property (nonatomic, strong) OEPocketsphinxController *pocketsphinxController;
@property (nonatomic, strong) OEFliteController *fliteController;

@property (nonatomic, assign) int restartAttemptsDueToPermissionRequests;
@property (nonatomic, assign) BOOL startupFailedDueToLackOfPermissions;
@property (nonatomic, retain) OELanguageModelGenerator *lmGenerator;

//Represents Menu Screen Path
@property (nonatomic, copy) NSString *pathToFirstDynamicallyGeneratedLanguageModel;
@property (nonatomic, copy) NSString *pathToFirstDynamicallyGeneratedDictionary;

//Represents Create Request Screen Path
@property (nonatomic, copy) NSString *pathToSecondDynamicallyGeneratedLanguageModel;
@property (nonatomic, copy) NSString *pathToSecondDynamicallyGeneratedDictionary;

- (void)changeModel:(NSString *)languageModelPath dictionaryPath:(NSString *)dictionaryPath;
@end


@implementation VoiceRecogniser

@synthesize delegate;
@synthesize stringArray;
//Represents for Model Change
@synthesize usingStartingLanguageModel;

+ (VoiceRecogniser *)sharedInstance {
    
    static dispatch_once_t p = 0;
    __strong static id sharedObject = nil;
    
    dispatch_once(&p, ^{
        sharedObject = [[self alloc] init];
    });
    
    return sharedObject;
}

#pragma mark ---
#pragma mark Init 

/**
Init Method: Called only once throughout the application
*/
- (void)initOpenEars    {

    self.fliteController = [[OEFliteController alloc] init];
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    self.openEarsEventsObserver.delegate = self;
    
    self.restartAttemptsDueToPermissionRequests = 0;
    self.startupFailedDueToLackOfPermissions = FALSE;
    
    [OELogging startOpenEarsLogging];
    [OEPocketsphinxController sharedInstance].verbosePocketSphinx = TRUE;
    
    [self.openEarsEventsObserver setDelegate:self];
    
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
    
    NSArray *firstLanguageArray = @[@"Create",
                                    @"Logout",
                                    @"Call",
                                    @"Chat",
                                    @"Schedule",
                                    @"Mail"];
    
    OELanguageModelGenerator *languageModelGenerator = [[OELanguageModelGenerator alloc] init];
    
    languageModelGenerator.verboseLanguageModelGenerator = TRUE;
    
    NSError *error = [languageModelGenerator generateLanguageModelFromArray:firstLanguageArray withFilesNamed:@"FirstOpenEarsDynamicLanguageModel" forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    if(error) {
        NSLog(@"Dynamic language generator reported error %@", [error description]);
    } else {
        self.pathToFirstDynamicallyGeneratedLanguageModel = [languageModelGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"FirstOpenEarsDynamicLanguageModel"];
        self.pathToFirstDynamicallyGeneratedDictionary = [languageModelGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"FirstOpenEarsDynamicLanguageModel"];
    }
    
    self.usingStartingLanguageModel = TRUE; 
    
    NSArray *secondLanguageArray = @[@"Notes",
                                     @"Cancel",
                                     @"Send",
                                     @"No",
                                     @"Yes"];
    
    error = [languageModelGenerator generateLanguageModelFromArray:secondLanguageArray withFilesNamed:@"SecondOpenEarsDynamicLanguageModel" forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    if(error) {
        NSLog(@"Dynamic language generator reported error %@", [error description]);
    }	else {
        
        self.pathToSecondDynamicallyGeneratedLanguageModel = [languageModelGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"SecondOpenEarsDynamicLanguageModel"];
        
        self.pathToSecondDynamicallyGeneratedDictionary = [languageModelGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"SecondOpenEarsDynamicLanguageModel"];;
        
        
        [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
        
        if(![OEPocketsphinxController sharedInstance].isListening) {
            [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE];
        }
        
    }
    
}

#pragma mark ---
#pragma mark Load

/**
Load Method: Called in Main Class
*/
//- (void)loadOpenEars    {
//    
//}

#pragma mark -
#pragma mark OEEventsObserver delegate methods

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {

    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    
    switch (self.usingStartingLanguageModel)    {
            
        case 1:
        {
            [[OEPocketsphinxController sharedInstance] changeLanguageModelToFile:self.pathToFirstDynamicallyGeneratedLanguageModel withDictionary:self.pathToFirstDynamicallyGeneratedDictionary];
        }
            break;
            
        case 2:
        {
            [[OEPocketsphinxController sharedInstance] changeLanguageModelToFile:self.pathToSecondDynamicallyGeneratedLanguageModel withDictionary:self.pathToSecondDynamicallyGeneratedDictionary];
        }
            break;
            
        default:
            assert(false);
            break;
    }
    
    if ([delegate respondsToSelector:@selector(voiceRecogniser: recognisedString:)])  {
        [delegate voiceRecogniser:self recognisedString:hypothesis];
    }

}

- (void) pocketsphinxDidStartListening {
    NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
    NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) testRecognitionCompleted {
    NSLog(@"A test file that was submitted for recognition is now complete.");
}


#pragma mark -
#pragma mark Method Change Model

- (void)changePathToSuccessfullyGeneratedModel    {
    /*NSError *err = [self.lmGenerator generateLanguageModelFromArray:stringArray withFilesNamed:pathToDynamicallyGeneratedLanguageModel forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];

    if (err == nil) {
        NSString *lmPath = [self.lmGenerator
                            pathToSuccessfullyGeneratedLanguageModelWithRequestedName:pathToDynamicallyGeneratedLanguageModel];
        
        NSString *dicPath = [self.lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:pathToDynamicallyGeneratedLanguageModel];
        
        [self changeModel:lmPath dictionaryPath:dicPath];
    }*/
}

- (void)changeModel:(NSString *)languageModelPath dictionaryPath:(NSString *)dictionaryPath {
    [[OEPocketsphinxController sharedInstance] changeLanguageModelToFile:languageModelPath withDictionary:dictionaryPath];
}

#pragma mark Method Stop Listening

- (void)stopListening   {
    if([OEPocketsphinxController sharedInstance].isListening)   {
        NSError *error = [[OEPocketsphinxController sharedInstance] stopListening];
        if(error)   {
            NSLog(@"Error while stopping listening in micPermissionCheckCompleted: %@", error);
        }
    }
}

#pragma mark Method Start Listening

- (void)startListening  {
//    if(![OEPocketsphinxController sharedInstance].isListening) {
//        [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:pathToDynamicallyGeneratedLanguageModel dictionaryAtPath:pathToDynamicallyGeneratedLanguageModel acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE];
//    }
}

@end