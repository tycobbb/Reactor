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
#import "MTRReactor.h"
#import "MTRDependency.h"

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

+ (void)reactify:(Class<MTRReactive>)klass
{
    NSArray *whitelist = mtr_invokeKeygenMethod(klass, @selector(reactiveProperties:));
    NSArray *blacklist = mtr_invokeKeygenMethod(klass, @selector(nonreactiveProperties:));
   
    NSAssert(!whitelist || !blacklist, @"Both +whitelist: and +blacklist: are not allowed on the same class");
    
    objc_property_t *properties; uint count;
    
    properties = class_copyPropertyList(klass, &count);
   
    // filter out properties added in by the runtime:
    //   "hash", "superclass", "description", "debugDescription"
    count -= 4;
   
    for(int index=0 ; index<count ; index++) {
        objc_property_t property = properties[index];
        const char *name = property_getName(property);
        
        // ensure that the white/blacklist accepts permits this property
        NSString *objcName = @(name);
        if((blacklist && [blacklist containsObject:objcName]) || (whitelist && ![whitelist containsObject:objcName])) {
            continue;
        }
       
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
      
        BOOL error;
        error = [self class:klass swizzleGetter:sel_registerName(getterName) forProperty:objcName];
        error = [self class:klass swizzleSetter:sel_registerName(setterName) forProperty:objcName];
        
        if(!error) {
            printf("%s: %s - MTRReactive doesn't support properties of this type\n", class_getName(klass), name);
            printf("\ta. Constrain reactivity using +nonreactiveProperties: or +reactiveProperties:\n");
            printf("\tb. Submit a pull request\n");
        }
        
        free(_getterName);
        free(setterName);
    }
    
    free(properties);
}


NSArray * mtr_invokeKeygenMethod(Class<MTRReactive> klass, SEL name)
{
    typedef NSArray *(*MTRKeygen)(id, SEL, id);
    
    Method local  = class_getClassMethod(klass, name);
    Method parent = class_getClassMethod(class_getSuperclass(klass), name);
    
    // we only want to invoke the method if the local imp is unique
    if(local && local != parent) {
        MTRKeygen keygen = (MTRKeygen)method_getImplementation(local);
        return keygen(klass, name, nil);
    }
    
    return nil;
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

# pragma mark - Swizzling

const char *mtr_dependenciesKey;
const size_t mtr_typeLength = 64;

/**
 @brief Looks up a dependency on a reactive object
 
 If @c lazy is true, created the dependency map and dependencies on demand, otherwise
 will return only dependencies that already exist.
 
 @param other The object to look up the dependency on
 @param name  The name corresponding to this dependency
 @param lazy  @c YES if dependencies should be lazy-loaded
 
 @return The dependecny for this name or nil
*/

NS_INLINE MTRDependency * mtr_dependencyForName(id other, NSString *name, BOOL lazy)
{
    // lazy-load the dependencies dictionary
    NSMutableDictionary *dependencies = objc_getAssociatedObject(other, mtr_dependenciesKey);
    if(lazy && !dependencies) {
        dependencies = [NSMutableDictionary new];
        objc_setAssociatedObject(other, mtr_dependenciesKey, dependencies, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // lazy load the dependency for this property name
    MTRDependency *dependency = dependencies[name];
    if(lazy && !dependency) {
        dependency = [MTRDependency new];
        dependencies[name] = dependency;
    }
    
    return dependency;
}

/**
 @brief The meat and potatotes of getter swizzling, the rest is type checking

 Replaces the existing instance with one that calls @c mtr_depend first, passing
 the callee and the name of the property to depend on. That function, in turn, 
 triggers the assosciated dependency.
*/

#define MTRSwizzleGetter(_type) \
    _type (*existing)(id self, SEL _cmd) = (void *)method_getImplementation(getter); \
    method_setImplementation(getter, imp_implementationWithBlock(^_type(id other) { \
        mtr_depend(other, property); \
        return existing(other, name); \
    }));

NS_INLINE void mtr_depend(id other, NSString *name)
{
    if(MTRReactor.reactor.isActive) {
        [mtr_dependencyForName(other, name, YES) depend];
    }
}

/** 
 @brief Swizzles the getter according to its return type
 If there is no getter to swizzle, then this method does nothing.
 @return @c NO if the return type was unsupported
*/

+ (BOOL)class:(Class)klass swizzleGetter:(SEL)name forProperty:(NSString *)property
{
    Method getter = class_getInstanceMethod(klass, name);
    if(getter == NULL) {
        return YES;
    }
    
    // we need to check the return type to ensure we can support any value
    char type[mtr_typeLength];
    method_getReturnType(getter, type, mtr_typeLength);
   
    // check every return type so that we can swizzle the right signature
    // this logic is borrowed heavily from Expecta, thx!
    if(strcmp(type, @encode(char)) == 0) {
        MTRSwizzleGetter(char);
    } else if(strcmp(type, @encode(_Bool)) == 0) {
        MTRSwizzleGetter(_Bool);
    } else if(strcmp(type, @encode(double)) == 0) {
        MTRSwizzleGetter(float);
    } else if(strcmp(type, @encode(float)) == 0) {
        MTRSwizzleGetter(float);
    } else if(strcmp(type, @encode(int)) == 0) {
        MTRSwizzleGetter(int);
    } else if(strcmp(type, @encode(long)) == 0) {
        MTRSwizzleGetter(long);
    } else if(strcmp(type, @encode(long long)) == 0) {
        MTRSwizzleGetter(long long);
    } else if(strcmp(type, @encode(short)) == 0) {
        MTRSwizzleGetter(short);
    } else if(strcmp(type, @encode(unsigned char)) == 0) {
        MTRSwizzleGetter(unsigned char);
    } else if(strcmp(type, @encode(unsigned int)) == 0) {
        MTRSwizzleGetter(unsigned int);
    } else if(strcmp(type, @encode(unsigned long)) == 0) {
        MTRSwizzleGetter(unsigned long)
    } else if(strcmp(type, @encode(unsigned long long)) == 0) {
        MTRSwizzleGetter(unsigned long long);
    } else if(strcmp(type, @encode(unsigned short)) == 0) {
        MTRSwizzleGetter(unsigned short);
    } else if((strstr(type, @encode(id)) != NULL) || (strstr(type, @encode(Class)) != 0)) {
        MTRSwizzleGetter(id);
    } else if(strstr(type, "ff}{") != NULL) { // TODO: of course this only works for a 2x2 e.g. CGRect
        MTRSwizzleGetter(float *)
    } else if(strstr(type, "=ff}") != NULL) {
        MTRSwizzleGetter(float *)
    } else if(strstr(type, "=ffff}") != NULL) {
        MTRSwizzleGetter(float *);
    } else if(strstr(type, "dd}{") != NULL) { // TODO: same here
        MTRSwizzleGetter(double *);
    } else if(strstr(type, "=dd}") != NULL) {
        MTRSwizzleGetter(double *);
    } else if(strstr(type, "=dddd}") != NULL) {
        MTRSwizzleGetter(double *);
    } else {
        return NO; // this is unsupported
    }
    
    return YES;
}

/**
 @brief The meat and potatotes of setter swizzling, the rest is type checking
 
 Replaces the existing instance with one that calls @c mtr_changed first, passing
 the callee and the name of the invalidated property. That function, in turn, triggers 
 the assosciated dependency.
*/

#define MTRSwizzleSetter(_type) \
    void (*existing)(id self, SEL _cmd, _type value) = (void *)method_getImplementation(setter); \
    method_setImplementation(setter, imp_implementationWithBlock(^(id other, _type value) { \
        mtr_changed(other, property); \
        existing(other, name, value); \
    }));

NS_INLINE void mtr_changed(id other, NSString *name)
{
    [mtr_dependencyForName(other, name, NO) changed];
}

+ (BOOL)class:(Class)klass swizzleSetter:(SEL)name forProperty:(NSString *)property
{
    Method setter = class_getInstanceMethod(klass, name);
    if(setter == NULL) {
        return YES;
    }
    
    // we need to check the return type to ensure we can support any value
    char type[mtr_typeLength];
    method_getArgumentType(setter, 2, type, mtr_typeLength);
    
    // check every return type so that we can swizzle the right signature
    // this logic is borrowed heavily from Expecta, thx!
    if(strcmp(type, @encode(char)) == 0) {
        MTRSwizzleSetter(char);
    } else if(strcmp(type, @encode(_Bool)) == 0) {
        MTRSwizzleSetter(_Bool);
    } else if(strcmp(type, @encode(double)) == 0) {
        MTRSwizzleSetter(float);
    } else if(strcmp(type, @encode(float)) == 0) {
        MTRSwizzleSetter(float);
    } else if(strcmp(type, @encode(int)) == 0) {
        MTRSwizzleSetter(int);
    } else if(strcmp(type, @encode(long)) == 0) {
        MTRSwizzleSetter(long);
    } else if(strcmp(type, @encode(long long)) == 0) {
        MTRSwizzleSetter(long long);
    } else if(strcmp(type, @encode(short)) == 0) {
        MTRSwizzleSetter(short);
    } else if(strcmp(type, @encode(unsigned char)) == 0) {
        MTRSwizzleSetter(unsigned char);
    } else if(strcmp(type, @encode(unsigned int)) == 0) {
        MTRSwizzleSetter(unsigned int);
    } else if(strcmp(type, @encode(unsigned long)) == 0) {
        MTRSwizzleSetter(unsigned long)
    } else if(strcmp(type, @encode(unsigned long long)) == 0) {
        MTRSwizzleSetter(unsigned long long);
    } else if(strcmp(type, @encode(unsigned short)) == 0) {
        MTRSwizzleSetter(unsigned short);
    } else if((strstr(type, @encode(id)) != NULL) || (strstr(type, @encode(Class)) != 0)) {
        MTRSwizzleSetter(id);
    } else if(strstr(type, "ff}{") != NULL) { //TODO: of course this only works for a 2x2 e.g. CGRect
        MTRSwizzleSetter(float *)
    } else if(strstr(type, "=ff}") != NULL) {
        MTRSwizzleSetter(float *)
    } else if(strstr(type, "=ffff}") != NULL) {
        MTRSwizzleSetter(float *);
    } else if(strstr(type, "dd}{") != NULL) { //TODO: same here
        MTRSwizzleSetter(double *);
    } else if(strstr(type, "=dd}") != NULL) {
        MTRSwizzleSetter(double *);
    } else if(strstr(type, "=dddd}") != NULL) {
        MTRSwizzleSetter(double *);
    } else {
        return NO; // this is unsupported
    }
    
    return YES;
}

@end
