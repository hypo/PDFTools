// DTUtilities.m

#import "DTUtilities.h"

float DTpt2cm(float pt)
{
    return (pt / 72.0) * 2.54;
}
float DTcm2pt(float cm)
{
	return (cm / 2.54) * 72.0;
}

float DTinch2pt(float inch)
{
	return inch * 72.0;
}

NSPoint DTMakePointInCM(float x_cm, float y_cm)
{
	return NSMakePoint(DTcm2pt(x_cm), DTcm2pt(y_cm));
}

NSRect DTMakeRectWithSizeInCM(float w_cm, float h_cm)
{
	return NSMakeRect(0.0, 0.0, DTcm2pt(w_cm), DTcm2pt(h_cm));
}
NSRect DTMakeRectInCM(float x_cm, float y_cm, float w_cm, float h_cm)
{
	return NSMakeRect(DTcm2pt(x_cm), DTcm2pt(y_cm), DTcm2pt(w_cm), DTcm2pt(h_cm));
}
