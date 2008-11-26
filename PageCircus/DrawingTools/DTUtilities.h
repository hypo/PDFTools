// DTUtilities.h

#import <Cocoa/Cocoa.h>

// unit conversion and utility functions
float DTpt2cm(float pt);
float DTcm2pt(float cm);
float DTinch2pt(float inch);
NSPoint DTMakePointInCM(float x_cm, float y_cm);
NSRect DTMakeRectWithSizeInCM(float w_cm, float h_cm);
NSRect DTMakeRectInCM(float x_cm, float y_cm, float w_cm, float h_cm);
