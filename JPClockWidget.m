/*
 * 
 * JPClock Widget (based on Clock Widget) for SmartSreen
 * Copyright (C) 2009 Takuo Kitame.
 *                    MediaPhone SA. (based on MediaPhone Clock Widget)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 */

#import "JPClockWidget.h"
#import "JPDate.h"

@implementation JPClockWidget

-(id) init
{
    self = [super init];
    
    _timeFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter = [[NSDateFormatter alloc] init];
    
    return self;
}

-(void) dealloc
{
    [_timer invalidate];
    _timer = nil;

    [_timeFormatter release];
    _timeFormatter = nil;

    [_dateFormatter release];
    _dateFormatter = nil;
	    
    [super dealloc];
}

-(void) loadView
{
// Create only view and controls here
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
    
    ivBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
    [view addSubview:ivBackground];
    [ivBackground release];
    
    lTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    lTime.textColor = [UIColor whiteColor];
    lTime.textAlignment = UITextAlignmentCenter;
    lTime.backgroundColor = [UIColor clearColor];
    [view addSubview:lTime];
    [lTime release];

    lDate = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 320, 20)];
    lDate.textColor = [UIColor whiteColor];
    lDate.textAlignment = UITextAlignmentLeft;
    lDate.backgroundColor = [UIColor clearColor];
    [view addSubview:lDate];
    [lDate release];
	
	ivHoliday = [[UIImageView alloc] initWithFrame:CGRectMake(0,62,18,14)];
	ivHoliday.image = [UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"holiday" ofType:@"png"]];
	ivHoliday.hidden = true;
	[view addSubview:ivHoliday];
	[ivHoliday release];
	
	lHoliday = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 320, 20)];
    lHoliday.textColor = [UIColor whiteColor];
    lHoliday.textAlignment = UITextAlignmentLeft;
    lHoliday.backgroundColor = [UIColor clearColor];
	[view addSubview:lHoliday];
    [lHoliday release];

    self.view = view;
    [view release];
}

-(CGSize) widgetSize
{
// Return widget size in pixels. Recommended widget width is 320 pixel and height is 70, 140, 210, 280 or 350 pixels.
    return CGSizeMake(320, 70);
}

-(void) loadWidget
{
// Called on widget load. Should be used to initialize widget information and start update loop.
// Do not put time consuming code here - use NSOperation for asynchronous code execution
    
    [self loadPreferences];
    
    if([[_preferences objectForKey:@"ShowBackground"] boolValue])
        ivBackground.image = [UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"Background" ofType:@"png"]];
    
    lTime.hidden = [[_preferences objectForKey:@"TimeHidden"] boolValue];

    if(!lTime.hidden)
    {
        UIFont* font = nil;
        NSString* fontName = [_preferences objectForKey:@"TimeFontName"];
        CGFloat fontSize = [[_preferences objectForKey:@"TimeFontSize"] floatValue];

        if(fontName)
            font = [UIFont fontWithName:fontName size:fontSize];

        if(font == nil)
            font = [UIFont systemFontOfSize:[UIFont systemFontSize]];

        lTime.font = font;
        lTime.textColor = [UIColor colorWithRGB:[[_preferences objectForKey:@"TimeColor"] unsignedIntValue]];
        lTime.numberOfLines = 2;
        
        [_timeFormatter setDateFormat:[_preferences objectForKey:@"TimeFormat"]];
    }

    lDate.hidden = [[_preferences objectForKey:@"DateHidden"] boolValue];    
    lHoliday.hidden = [[_preferences objectForKey:@"DateHidden"] boolValue];    

    if(!lDate.hidden)
    {
        UIFont* font = nil;
        NSString* fontName = [_preferences objectForKey:@"DateFontName"];
        CGFloat fontSize = [[_preferences objectForKey:@"DateFontSize"] floatValue];
    
        if(fontName)
            font = [UIFont fontWithName:fontName size:fontSize];
        
        if(font == nil)
            font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        
        lDate.font = font;
        lDate.textColor = [UIColor colorWithRGB:[[_preferences objectForKey:@"DateColor"] unsignedIntValue]];
        lDate.numberOfLines = 2;

        [_dateFormatter setDateFormat:[_preferences objectForKey:@"DateFormat"]];
    }

	if (!lHoliday.hidden) {
        lHoliday.font = lDate.font;
        lHoliday.textColor = [UIColor colorWithRGB:[[_preferences objectForKey:@"HolidayColor"] unsignedIntValue]];
        lDate.numberOfLines = 2;		
	}

    [self updateControls];
    
    if(!lTime.hidden)
    {
        CGRect frame = lTime.frame;
        frame.origin.y += [[_preferences objectForKey:@"TimeOffset"] doubleValue];
        frame.size.height = [lTime.text sizeWithFont:lTime.font constrainedToSize:CGSizeMake(320, 70) lineBreakMode:UILineBreakModeWordWrap].height;
        lTime.frame = frame;
    }

    if(!lDate.hidden)
    {
        CGRect frame = lDate.frame;
        if(lTime.hidden)
            frame.origin.y = 0;
        else
            frame.origin.y = CGRectGetMaxY(lTime.frame);
        frame.origin.y += [[_preferences objectForKey:@"DateOffset"] doubleValue];
        frame.size.height = [lDate.text sizeWithFont:lDate.font constrainedToSize:CGSizeMake(320, 70) lineBreakMode:UILineBreakModeWordWrap].height;;
        lDate.frame = frame;
    }

	if(!lHoliday.hidden)
    {
        CGRect frame = lHoliday.frame;
        if(lTime.hidden)
            frame.origin.y = 0;
        else
            frame.origin.y = CGRectGetMaxY(lTime.frame);
        frame.origin.y += [[_preferences objectForKey:@"DateOffset"] doubleValue];
        frame.size.height = [lHoliday.text sizeWithFont:lDate.font constrainedToSize:CGSizeMake(320, 70) lineBreakMode:UILineBreakModeWordWrap].height;;
        lHoliday.frame = frame;
		frame = ivHoliday.frame;
		frame.origin.y = lHoliday.frame.origin.y + 2;
		ivHoliday.frame = frame;
    }
	[self updateControls];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFire:) userInfo:nil repeats:YES];
}

-(void) unloadWidget
{
// Called on widget unload. Should be used to release widget information and stop update loop.
// Do not put time consuming code here - use NSOperation for asynchronous code execution
    
    [_timer invalidate];
    _timer = nil;

// Save widget settings back to disk
    [self savePreferences];
}

-(void) pauseWidget
{
// Pause information updates to save battery power
    [_timer invalidate];
    _timer = nil;
}

-(void) resumeWidget
{
// Resume information updates    
// Don not put time consuming code here - use NSOperation for asynchronous code execution
    [self updateControls];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFire:) userInfo:nil repeats:YES];
}

-(void) timeFire:(NSTimer*) timer
{
    [self updateControls];
}

-(void) loadPreferences
{
    // Use Preferences.plist inside your widget bundle to keep widget settings
    // This file is also used by SmartScreen Preferences tool
    NSString* preferencesPath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"Preferences.plist"];
    
    _preferences = [NSMutableDictionary dictionaryWithContentsOfFile:preferencesPath];
    if(_preferences == nil)
        _preferences = [NSMutableDictionary dictionary];
    
    // Use PreferenceSpecifiers.plist inside your widget bundle to keep default widget settings
    // This file is also used by SmartScreen Preferences tool
    NSString* preferenceSpecifiersPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"PreferenceSpecifiers" ofType:@"plist"];
    NSArray* preferenceSpecifiers = [NSArray arrayWithContentsOfFile:preferenceSpecifiersPath];
    for(NSDictionary* specifier in preferenceSpecifiers)
    {
        NSString* key = [specifier objectForKey:@"Key"];
        NSString* value = [specifier objectForKey:@"DefaultValue"];
        
        if(key && value)
        {
            // Apply default values for missing settings
            if([_preferences objectForKey:key] == nil)
                [_preferences setObject:value forKey:key];
        }
    }

    [_preferences retain];
}

-(void) savePreferences
{
    NSString* preferencesPath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"Preferences.plist"];
    [_preferences writeToFile:preferencesPath atomically:YES];
    [_preferences release];
    _preferences = nil;
}

-(void) updateControls
{
    NSDate* date = [NSDate date];

    if(!lTime.hidden)
        lTime.text = [_timeFormatter stringFromDate:date];
    if(!lDate.hidden) {
		int i;
		CGRect frame_date = lDate.frame;
		CGRect frame_holiday = lHoliday.frame;
		CGRect frame_iv = ivHoliday.frame;
		NSString *str = [date holidayName];
		lDate.text = [_dateFormatter stringFromDate:date];

		if (str != nil) {
			lHoliday.text = str;
			lHoliday.hidden = false;
			ivHoliday.hidden = false;
			frame_date.size.width = [lDate.text sizeWithFont:lDate.font constrainedToSize:CGSizeMake(320, 70) lineBreakMode:UILineBreakModeWordWrap].width;
			frame_holiday.size.width = [lHoliday.text sizeWithFont:lHoliday.font constrainedToSize:CGSizeMake(320, 70) lineBreakMode:UILineBreakModeWordWrap].width;
			i = frame_date.size.width + frame_holiday.size.width + frame_iv.size.width + 5;
			i = floor((320 - i) / 2);
			frame_date.origin.x = i;
			frame_iv.origin.x = i + frame_date.size.width + 3;
			frame_holiday.origin.x = frame_iv.origin.x + frame_iv.size.width + 2;
			lHoliday.frame = frame_holiday;
			ivHoliday.frame = frame_iv;
			lDate.textAlignment = UITextAlignmentLeft;
		} else {
			lHoliday.text = @"";
			lHoliday.hidden = true;
			ivHoliday.hidden = true;
			frame_date.size.width = 320;
			lDate.textAlignment = UITextAlignmentCenter;
		}		
		lDate.frame = frame_date;
    }
}

@end

@implementation UIColor (RGBA)

+(UIColor*) colorWithRGB:(unsigned int) rgb
{
    return [UIColor colorWithRed:(float)(rgb >> 16) / 255 green:(float)((rgb >> 8) & 0xFF) / 255 blue:(float)(rgb & 0xFF) / 255 alpha:1.0];
}

@end
