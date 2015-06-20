//
//  ShaderProgram.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>

#define SHADER_FILE(name, extension) ([[NSBundle mainBundle] pathForResource:(name) ofType:(extension)])

/*!
 @class ShaderProgram
 @brief abstract class that represents a Shader Program
*/
@interface ShaderProgram : NSObject

@property (assign, nonatomic, readonly) GLuint programID;
@property (assign, nonatomic, readonly) GLuint vertexShaderID;
@property (assign, nonatomic, readonly) GLuint fragmentShaderID;

- (instancetype)initWithVertexShaderName:(NSString *)vertexName
                   andFragmentShaderName:(NSString *)fragmentName;

// Needs to be implemented by subclasses
- (void)bindAttributes;
- (void)getAllUniformLocations;

// Helpers. Only for subclasses
- (void)bindAttribute:(GLuint)index toVariableName:(const GLchar *)variableName;
- (GLuint)getUniformLocation:(const GLchar *)uniformName;
- (void)loadFloat:(GLfloat)value toLocation:(GLuint)location;
- (void)loadFloatVector3:(GLKVector3)value toLocation:(GLuint)location;
- (void)loadFloatVector4:(GLKVector4)value toLocation:(GLuint)location;
- (void)loadBool:(BOOL)value toLocation:(GLuint)location;
- (void)loadMatrix4x4:(GLKMatrix4)value toLocation:(GLuint)location;
// End Helpers.

// "Binds" the program; calls glUseProgram
- (void)activate;

// "Unbinds" the program; calls glUseProgram
- (void)deactivate;

- (void)cleanUp;

- (BOOL)validateProgram;
- (BOOL)linkProgram;

@end
