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

/*
 Add reactivity to any appropriate properties on the class
*/

+ (void)reactify:(Class<MTRReactive>)klass
{
    NSArray *whitelist = mtr_invokeKeygenMethod(klass, @selector(reactiveProperties:));
    NSArray *blacklist = mtr_invokeKeygenMethod(klass, @selector(nonreactiveProperties:));
   
    NSAssert(!whitelist || !blacklist, @"Both +whitelist: and +blacklist: are not allowed on the same class");
    
    objc_property_t *properties; uint count;
    
    properties = class_copyPropertyList(klass, &count);
   
    for(int index=0 ; index<count ; index++) {
        objc_property_t property = properties[index];
        const char *name = property_getName(property);
        
        // ensure that the white/blacklist permits this property
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
        
        // get the custom setter name or assume the default
        setterName = property_copyAttributeValue(property, "S");
        if(setterName == NULL) {
            setterName = mtr_setterNameFromProperty(name);
        }
      
        // swizzle the methods for this property
        [self class:klass swizzleGetter:sel_registerName(getterName) setter:sel_registerName(setterName) forProperty:objcName];
        
        free(_getterName);
        free(setterName);
    }
    
    free(properties);
}

/*
 Call the black/whitelist method that is unique to this class (not its superclass imp) if such
 a method exists.
*/

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

/*
 Swizzles the getter by replacing its current implementation with one that first calls
 mtr_depend to invoke the dependency assosciated with this property.
*/

#define MTRSwizzleGetter(_type) \
    _type (*existing)(id self, SEL _cmd) = (void *)method_getImplementation(getter); \
    method_setImplementation(getter, imp_implementationWithBlock(^_type(id other) { \
        mtr_depend(other, property); \
        return existing(other, getterName); \
    }));

/*
 Swizzles the setter by replacing its current implementation with one that calls mtr_changed
 afterwards to update the dependency assosciated with this property
*/

#define MTRSwizzleSetter(_type) \
    void (*existing)(id self, SEL _cmd, _type value) = (void *)method_getImplementation(setter); \
    method_setImplementation(setter, imp_implementationWithBlock(^(id other, _type value) { \
        existing(other, setterName, value); \
        mtr_changed(other, property); \
    }));

/*
 Calls the above macros to swizzle the property's methods, provided they exist
*/

#define MTRSwizzleProperty(_type) \
    if(getter != NULL) { MTRSwizzleGetter(_type) } \
    if(setter != NULL) { MTRSwizzleSetter(_type) }

/* 
 Invokes the dependency for this property if inside a computation
*/

NS_INLINE void mtr_depend(id other, NSString *name)
{
    if(MTRReactor.reactor.isActive) {
        [mtr_dependencyForName(other, name, YES) depend];
    }
}

/*
 Updates the dependency for this property if necessary
*/

NS_INLINE void mtr_changed(id other, NSString *name)
{
    [mtr_dependencyForName(other, name, NO) changed];
}

/*
 Looks up the dependency on `other` for this property
 
 If `lazy` is `YES`, then the dependency (and the dependency collection) are created if they don't
 already exist. Otherwise, this method only returns pre-existing dependencies.
*/

NS_INLINE MTRDependency * mtr_dependencyForName(id other, NSString *name, BOOL lazy)
{
    static const char *mtr_dependenciesKey;
    
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

/*
 Swizzles the getter and setter for the property
 
 Typechecks the property to provide the correct implementations, calling MTRSwizzleProperty with
 the type if valid. If the type is not currently supported, reports an error.
*/

+ (void)class:(Class)klass swizzleGetter:(SEL)getterName setter:(SEL)setterName forProperty:(NSString *)property
{
    static const size_t mtr_typeLength = 64;
    
    Method getter = class_getInstanceMethod(klass, getterName);
    Method setter = class_getInstanceMethod(klass, setterName);
    
    // if the property doesn't have a setter, we're not going to make it reative; this also
    // filters some system properties: hash, description, debugDescription, superclass
    if(setter == NULL) {
        return;
    }
   
    // we need to check the getter (if it exists) or the setter for the property type
    char type[mtr_typeLength];
    method_getArgumentType(setter, 2, type, mtr_typeLength);
   
    // check each type so that we can swizzle the right signatures. this logic is borrowed
    // heavily from Expecta, thx!
    if(strcmp(type, @encode(char)) == 0) {
        MTRSwizzleProperty(char);
    } else if(strcmp(type, @encode(_Bool)) == 0) {
        MTRSwizzleProperty(_Bool);
    } else if(strcmp(type, @encode(double)) == 0) {
        MTRSwizzleProperty(double);
    } else if(strcmp(type, @encode(float)) == 0) {
        MTRSwizzleProperty(float);
    } else if(strcmp(type, @encode(int)) == 0) {
        MTRSwizzleProperty(int);
    } else if(strcmp(type, @encode(long)) == 0) {
        MTRSwizzleProperty(long);
    } else if(strcmp(type, @encode(long long)) == 0) {
        MTRSwizzleProperty(long long);
    } else if(strcmp(type, @encode(short)) == 0) {
        MTRSwizzleProperty(short);
    } else if(strcmp(type, @encode(unsigned char)) == 0) {
        MTRSwizzleProperty(unsigned char);
    } else if(strcmp(type, @encode(unsigned int)) == 0) {
        MTRSwizzleProperty(unsigned int);
    } else if(strcmp(type, @encode(unsigned long)) == 0) {
        MTRSwizzleProperty(unsigned long)
    } else if(strcmp(type, @encode(unsigned long long)) == 0) {
        MTRSwizzleProperty(unsigned long long);
    } else if(strcmp(type, @encode(unsigned short)) == 0) {
        MTRSwizzleProperty(unsigned short);
    } else if((strstr(type, @encode(id)) != NULL) || (strstr(type, @encode(Class)) != 0)) {
        MTRSwizzleProperty(id);
    } else if(strstr(type, "ff}{") != NULL) {
        MTRSwizzleProperty(float *)
    } else if(strstr(type, "=ff}") != NULL) {
        MTRSwizzleProperty(float *)
    } else if(strstr(type, "=ffff}") != NULL) {
        MTRSwizzleProperty(float *);
    } else if(strstr(type, "dd}{") != NULL) {
        MTRSwizzleProperty(double *);
    } else if(strstr(type, "=dd}") != NULL) {
        MTRSwizzleProperty(double *);
    } else if(strstr(type, "=dddd}") != NULL) {
        MTRSwizzleProperty(double *);
    } else {
        printf("%s: %s - MTRReactive doesn't support properties of this type\n", class_getName(klass), property.UTF8String);
        printf("\ta. Constrain reactivity using +nonreactiveProperties: or +reactiveProperties:\n");
        printf("\tb. Submit a pull request\n");
    }
}

@end
