
//     File: ObjCClassWrapper.m
// Abstract: ObjCClassWrapper Implementation
//  Version: 1.1
//
// Based largely on Apple TreeView's example.


#import "ObjCClassWrapper.h"
#import <objc/runtime.h>


// Keeps track of the ObjCClassWrapper instances we create.  We create one unique
// ObjCClassWrapper for each Objective-C "Class" we're asked to wrap.

static NSMutableDictionary *classToWrapperMapTable = nil;


// Compares two ObjCClassWrappers by name, and returns an NSComparisonResult.

static NSInteger CompareClassNames(id classA, id classB, void* context)
{
    return [[classA description] compare:[classB description]];
}


@interface ObjCClassWrapper ()
{
    
@private
    Class wrappedClass;
    NSMutableArray *subclassesCache;
}

@end


@implementation ObjCClassWrapper


#pragma mark - NSCopying

- (id) copyWithZone:(NSZone *)zone
{
    return self;
}


#pragma mark - Creating Instances

- initWithWrappedClass:(Class)aClass
{
    self = [super init];
    if (self) {
        if (aClass != Nil) {
            wrappedClass = aClass;
            if (classToWrapperMapTable == nil) {
                classToWrapperMapTable = [NSMutableDictionary dictionaryWithCapacity:16];
            }
            classToWrapperMapTable[(id<NSCopying>)wrappedClass] = self;
        } else {
            return nil;
        }
    }
    return self;
}

+ (ObjCClassWrapper *) wrapperForClass:(Class)aClass
{
    ObjCClassWrapper *wrapper = classToWrapperMapTable[aClass];
    if (wrapper == nil) {
        wrapper = [[self alloc] initWithWrappedClass:aClass];
    }
    return wrapper;
}

+ (ObjCClassWrapper *) wrapperForClassNamed:(NSString *)aClassName
{
    return [self wrapperForClass:NSClassFromString(aClassName)];
}


#pragma mark -  Property Accessors

- (NSString *) name
{
    return NSStringFromClass(wrappedClass);
}

- (NSString *) description
{
    return [self name];
}

- (size_t) wrappedClassInstanceSize
{
    return class_getInstanceSize(wrappedClass);
}

- (ObjCClassWrapper *) superclassWrapper
{
    return [[self class] wrapperForClass:class_getSuperclass(wrappedClass)];
}

- (NSArray *) subclasses
{
    // If we haven't built our array of subclasses yet, do so.
    if (subclassesCache == nil) {

        // Iterate over all classes (as described in objc/objc-runtime.h) to find the subclasses of wrappedClass.
        int i;
        int numClasses = 0;
        int newNumClasses = objc_getClassList(NULL, 0);
        Class* classes = NULL;
        while (numClasses < newNumClasses) {
            numClasses = newNumClasses;
            classes = (Class*)realloc(classes, sizeof(Class) * numClasses);
            newNumClasses = objc_getClassList(classes, numClasses);
        }

        // Make an array of ObjCClassWrapper instances to represent the classes.
        subclassesCache = [[NSMutableArray alloc] initWithCapacity:numClasses];
        for (i = 0; i < numClasses; i++) {
            if (class_getSuperclass(classes[i]) == wrappedClass) {
                [subclassesCache addObject:[[self class] wrapperForClass:classes[i]]];
            }
        }
        free(classes);

        // Sort subclasses by name.
        [subclassesCache sortUsingFunction:CompareClassNames context:NULL];
    }
    return subclassesCache;
}


#pragma mark - TreeGraphModelNode Protocol

- (id <PSTreeGraphModelNode> ) parentModelNode
{
    return [self superclassWrapper];
}

- (NSArray *) childModelNodes
{
    return [self subclasses];
}


@end
