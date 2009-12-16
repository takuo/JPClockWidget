@protocol SmartScreenWidgetProtocol <NSObject, NSCoding>

-(CGSize) widgetSize;

-(void) loadWidget;
-(void) unloadWidget;
-(void) pauseWidget;
-(void) resumeWidget;

@end