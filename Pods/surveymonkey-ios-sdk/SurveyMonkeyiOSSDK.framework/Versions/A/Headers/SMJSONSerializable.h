/*
 * Copyright (C) SurveyMonkey
 */

#import <Foundation/Foundation.h>
/** Protocol that describes behavior for Json serialization. */
@protocol SMJSONSerializableProtocol <NSObject>

/** Retrieves the relevant info from the dictionary. */
- (void)readFromJsonDictionary:(NSDictionary *) dictionary;


@optional
/** Turn this object into a JSON Dictionary */
- (NSDictionary *)toJson;

@end
