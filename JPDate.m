/*
 * 
 * JPClock Widget (based on Clock Widget) for SmartSreen
 * Copyright (C) 2009 Takuo Kitame.
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

//
//  JPDate.m
//  exteded NSDate, NSDate with Japanese Holiday Information.
//
//  Created by Takuo Kitame on 09/12/07.
//  Copyright 2009 Takuo Kitame. All rights reserved.
//
//

#import "JPDate.h"


@implementation NSDate(JPDate)
-(int)privDayOfAutumn {
	NSDateComponents *c;
	NSCalendar *cal = [NSCalendar currentCalendar];
	c = [cal components:NSYearCalendarUnit fromDate:self];
	
	if ([c year] <= 1947) return 99;
	if ([c year] <= 1979) return floor(23.2588 + (0.242194 * ([c year] - 1980)) - floor(([c year] - 1980) / 4));
	if ([c year] <= 2099) return floor(23.2488 + (0.242194 * ([c year] - 1980)) - floor(([c year] - 1980) / 4));
	if ([c year] <= 2150) return floor(24.2488 + (0.242194 * ([c year] - 1980)) - floor(([c year] - 1980) / 4));
	
	return 99;
}

-(int)privDayOfSpring {
	NSDateComponents *c;
	NSCalendar *cal = [NSCalendar currentCalendar];
	c = [cal components:NSYearCalendarUnit fromDate:self];
	
	if ([c year] <= 1947) return 99;	
	if ([c year] <= 1979) return floor(20.8357 + (0.242194 * ([c year] - 1980)) - floor(([c year] - 1980) / 4));
	if ([c year] <= 2099) return floor(20.8431 + (0.242194 * ([c year] - 1980)) - floor(([c year] - 1980) / 4));
	if ([c year] <= 2150) return floor(21.851 + (0.242194 * ([c year] - 1980)) - floor(([c year] - 1980) / 4));
	return 99;
}

-(NSString *)privHolidayName {
	NSDateComponents *c;
	NSCalendar *cal = [NSCalendar currentCalendar];
	c = [cal components:NSWeekdayCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:self];
	
	switch ([c month]) {
		case 1:
			if ([c day] == 1) return @"元旦";
			if ([c year] >= 2000) {
				// Happy Monday
				if ( floor(([c day] -1 ) / 7) + 1 == 2 && [c weekday] == 2) {
					return @"成人の日";
				}
			} else if ([c day] == 15) {
				return @"成人の日";
			}
			break;
		case 2:
			if ([c day] == 11 && [c year] >= 1967) return @"建国記念の日";
			if ([c day] == 24 && [c year] == 1989) return @"昭和天皇大喪の礼";
			break;
		case 3:
			if ([self privDayOfSpring] == [c day]) return @"春分の日";
			break;
		case 4:
			if ([c day] == 29) {
				if ([c year] >= 2007) return @"昭和の日";
				if ([c year] >= 1989) return @"みどりの日";
				return @"天皇誕生日";
			}
			break;
		case 5:
			switch ([c day]) {
				case 3: return @"憲法記念日"; break;
				case 4:
					if ([c year] >= 2007) return @"みどりの日"; break;
					if ([c year] >= 1986 && [c weekday] == 2) return @"国民の休日";
					break;
				case 5:
					return @"こどもの日";
					break;
				case 6:
					if ([c year] >= 2007 &&
						([c weekday] == 3 || [c weekday] == 4)) return @"振替休日";
					break;
			}
			break;
		case 6:
			if ([c year] == 1993 && [c day] == 9) return @"皇太子徳仁親王の結婚の儀";
			break;
		case 7:
			if ([c year] >= 2003) {
				if (floor( ([c day] -1 ) / 7 ) + 1 == 3 && [c weekday] == 2) return @"海の日";
			} else if ([c year] >= 1996 && [c day] == 20) {
				return @"海の日";					
			}
			break;
		case 8:
			break;
		case 9:
			if ([self privDayOfAutumn] == [c day]) return @"秋分の日";
			if ([c year] >= 2003) {
				if (floor( ([c day] - 1) / 7) + 1 == 3 && [c weekday] == 2) return @"敬老の日";
				if ([c weekday] == 3 && [self privDayOfAutumn] - 1 == [c day]) return @"国民の休日";
			} else {
				if ([c year] >= 1966 && [c day] == 15) return @"敬老の日";
			}
			break;
		case 10:
			if ([c year] >= 2000) {
				if (floor(([c day] - 1) / 7) + 1 == 2 && [c weekday] == 2) return @"体育の日";
			} else if ([c year] >= 1966 && [c day] == 10) {
				return @"体育の日";
			}
			break;
		case 11:
			if ([c day] == 3) return @"文化の日";
			if ([c day] == 23) return @"勤労感謝の日";
			if ([c year] == 1990 && [c day] == 12) return @"即位礼正殿の儀";
			break;
		case 12:
			if ([c year] >= 1989 && [c day] == 23) return @"天皇誕生日";
			break;
			
	}
	return nil;
}

-(NSString *)holidayName {
	NSString *ret = [self privHolidayName];
	NSDateComponents *c;
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	NSDate* implAltholiday;
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDate *yesterday;
	c = [cal components:NSWeekdayCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
	
	// 1973/4/12 振替休日実装
	[comps setYear:1973];[comps setMonth:4];[comps setDay:12];
	implAltholiday = [cal dateFromComponents:comps];
	if (ret == nil &&
		[c weekday] == 2 && self >= implAltholiday)
		{
		yesterday  = [[NSDate alloc] initWithTimeInterval:-(24*3600) sinceDate:self];
		NSString *yest = [yesterday privHolidayName];
		if (yest != nil) {
			ret = @"振替休日";
		}
	}	
	return ret;
}

-(Boolean)isHoliday {
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *c = [cal components:NSWeekdayCalendarUnit fromDate:self];
	
	if ([c weekday] == 1 || [self holidayName] != nil)
		return true;
	return false;
}
@end
