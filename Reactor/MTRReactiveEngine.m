//
//  MTRReactiveEngine.m
//  Reactor
//
//  Created by Ty Cobb on 1/15/15.
//  Copyright (c) 2015 cobb. All rights reserved.
//

@import ObjectiveC;

#import "MTRReactiveEngine.h"
#import "MTRReactive.h"

@implementation MTRReactiveEngine

+ (void)engage
{
    Class *classes; uint count;
   
    classes = objc_copyClassList(&count);
    
    for(int index=0 ; index<count ; index++) {
        Class klass = classes[index];
        if(class_conformsToProtocol(klass, @protocol(MTRReactive))) {
            [self reactify:klass];
        }
    }
    
    free(classes);
}

+ (void)reactify:(Class)klass
{
    objc_property_t *properties; uint count;
    
    properties = class_copyPropertyList(klass, &count);
   
    // filter out properties added in by the runtime:
    //   "hash", "superclass", "description", "debugDescription"
    count -= 4;
   
    for(int index=0 ; index<count ; index++) {
        objc_property_t property = properties[index];
        const char *name = property_getName(property);
       
        // getter may or may not be dynamically allocated; if so, store in _getterName
        // so that it can be freed
        char *getterName, *setterName;
        char *_getterName;
        
        // use the custom getter or assume the default
        _getterName = getterName = property_copyAttributeValue(property, "G");
        if(getterName == NULL) {
            getterName = mtr_getterNameFromProperty(name);
        }
        
        // get the custom setter name or a
        setterName = property_copyAttributeValue(property, "S");
        if(setterName == NULL) {
            setterName = mtr_setterNameFromProperty(name);
        }
       
        [self class:klass swizzleGetter:sel_registerName(getterName)];
        [self class:klass swizzleSetter:sel_registerName(setterName)];
        
        free(_getterName);
        free(setterName);
    }
    
    free(properties);
}

# pragma mark - Swizzling

// typedef id(*IMP)(id, SEL, ...);
// typedef void (*IMP)(void /* id, SEL, ... */ );

+ (void)class:(Class)klass swizzleGetter:(SEL)name
{
    Method getter = class_getInstanceMethod(klass, name);
    
    id(*existing)(id self, SEL _cmd) = (void *)method_getImplementation(getter);
    method_setImplementation(getter, imp_implementationWithBlock(^(id self) {
        return existing(self, name);
    }));
}

+ (void)class:(Class)klass swizzleSetter:(SEL)name
{
    Method setter = class_getInstanceMethod(klass, name);
    
    void(*existing)(id self, SEL _cmd, id value) = (void *)method_getImplementation(setter);
    method_setImplementation(setter, imp_implementationWithBlock(^(id self, id value) {
        existing(self, name, value);
    }));
}

# pragma mark - Naming

NS_INLINE char * mtr_getterNameFromProperty(const char *name)
{
    return (char *)name;
}

NS_INLINE char * mtr_setterNameFromProperty(const char *name)
{
    // get length of setter: "set" + prop + ":\0"
    size_t nameLength = strlen(name) + 5;
    char *setter = calloc(sizeof(char), nameLength);

    // construct the setter name
    strcat(setter, "set");
    setter[3] = toupper(name[0]);
    strcat(setter, name + 1);
    setter[nameLength-2] = ':';
    
    return setter;
}

@end
