
//     File: ObjCClassWrapper.h
// Abstract: ObjCClassWrapper Interface
//  Version: 1.1
//
// Based largely on Apple TreeView's example.


#import <Foundation/Foundation.h>
#import "PSTreeGraphModelNode.h"


/// Wraps an Objective-C Class in an NSObject, that we can conveninently query to find
/// related classes (superclass and subclasses) and the instance size.  Conforms to
/// the PSTreeGraphModelNode protocol, so that we can use these as model nodes with a TreeGraph.

@interface ObjCClassWrapper : NSObject <PSTreeGraphModelNode, NSCopying>


#pragma mark - Creating Instances

/// Returns an ObjCClassWrapper for the given Objective-C class.  ObjCClassWrapper maintains
/// a set of unique instances, so this will always return the same ObjCClassWrapper for a given Class.

+ (ObjCClassWrapper *) wrapperForClass:(Class)aClass;


/// Returns an ObjCClassWrapper for the given Objective-C class, by looking the Class up by
/// name and then invoking +wrapperForClass:

+ (ObjCClassWrapper *) wrapperForClassNamed:(NSString *)aClassName;


#pragma mark - Property Accessors

/// The wrappedClass' name (e.g. @"UIControl" or @"CALayer" or "CAAnimation")

@property (weak, nonatomic, readonly) NSString *name;


/// An ObjCClassWrapper representing the wrappedClass' superclass.

@property (weak, nonatomic, readonly) ObjCClassWrapper *superclassWrapper;


/// An array of ObjCClassWrappers representing the wrappedClass' subclasses.
/// (For convenience, the subclasses are sorted by name.)

@property (weak, nonatomic, readonly) NSArray *subclasses;


/// The wrappedClass' intrinsic instance size (which doesn't include external/auxiliary storage).

@property (nonatomic, readonly) size_t wrappedClassInstanceSize;


@end
