//
//  ShaderProgram.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 21.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "ShaderProgram.h"

@implementation ShaderProgram

#pragma mark - Init
- (instancetype)init
{
    return [self initWithVertexShaderName:@"" andFragmentShaderName:@""];
}

- (instancetype)initWithVertexShaderName:(NSString *)vertexName andFragmentShaderName:(NSString *)fragmentName
{
    if ((self = [super init])) {
        NSString *vertexShaderFile = SHADER_FILE(vertexName, @"vsh");
        NSString *fragmentShaderFile = SHADER_FILE(fragmentName, @"fsh");
        
        _programID = glCreateProgram();
        
        // Compile Shaders
        if (![self compileShader:&_vertexShaderID type:GL_VERTEX_SHADER file:vertexShaderFile]) {
            NSLog(@"ERROR: CANT LOAD VERTEX SHADER AT PATH %@", vertexShaderFile);
            return nil;
        }
        
        if (![self compileShader:&_fragmentShaderID type:GL_FRAGMENT_SHADER file:fragmentShaderFile]) {
            NSLog(@"ERROR: CANT LOAD FRAGMENT SHADER AT PATH %@", fragmentShaderFile);
            return nil;
        }
        
        // Attach Shaders
        glAttachShader(_programID, _vertexShaderID);
        glAttachShader(_programID, _fragmentShaderID);
        
        // Bind attribute locations.
        // This needs to be done prior to linking.
        [self bindAttributes];
        
        // Link Program and check for errors
        if (![self linkProgram]) {
            NSLog(@"ERROR: FAILED TO LINK PROGRAM %d", _programID);
            
            // release possibly created resources
            if (_vertexShaderID) {
                glDeleteShader(_vertexShaderID);
                _vertexShaderID = 0;
            }
            
            if (_fragmentShaderID) {
                glDeleteShader(_fragmentShaderID);
                _fragmentShaderID = 0;
            }
            
            if (_programID) {
                glDeleteProgram(_programID);
                _programID = 0;
            }
            
            return nil;
        }
        
        [self getAllUniformLocations];
        
        NSLog(@"created program %d", _programID);
    }
    
    return self;
}

#pragma mark - abstract methods
- (void)bindAttributes __attribute__((noreturn))
{
    NSAssert(false, @"%s MUST BE IMPLEMENTED BY A SUBCLASS.", __PRETTY_FUNCTION__);
    abort();
}

- (void)getAllUniformLocations __attribute__((noreturn))
{
    NSAssert(false, @"%s MUST BE IMPLEMENTED BY A SUBCLASS.", __PRETTY_FUNCTION__);
    abort();
}

#pragma mark - Helpers
- (void)bindAttribute:(GLuint)index toVariableName:(const GLchar *)variableName
{
    glBindAttribLocation(self.programID, index, variableName);
}

- (GLuint)getUniformLocation:(const GLchar *)uniformName
{
    return glGetUniformLocation(self.programID, uniformName);
}

- (void)loadFloat:(GLfloat)value toLocation:(GLuint)location
{
    glUniform1f(location, value);
}

- (void)loadFloatVector3:(GLKVector3)value toLocation:(GLuint)location
{
    glUniform3f(location, value.x, value.y, value.z);
}

- (void)loadFloatVector4:(GLKVector4)value toLocation:(GLuint)location
{
    glUniform4f(location, value.x, value.y, value.z, value.w);
}

- (void)loadBool:(BOOL)value toLocation:(GLuint)location
{
    glUniform1i(location, value ? 1 : 0);
}

- (void)loadMatrix4x4:(GLKMatrix4)value toLocation:(GLuint)location
{
    glUniformMatrix4fv(location, 1, GL_FALSE, value.m);
}

- (void)loadMatrix3x3:(GLKMatrix3)value toLocation:(GLuint)location
{
    glUniformMatrix3fv(location, 1, GL_FALSE, value.m);
}

#pragma mark - binding
- (void)activate
{
    glUseProgram(self.programID);
}

- (void)deactivate
{
    glUseProgram(0);
}

#pragma mark - Memory management
- (void)cleanUp
{
    [self deactivate];
    
    glDetachShader(_programID, _fragmentShaderID);
    glDetachShader(_programID, _vertexShaderID);
    
    glDeleteShader(_vertexShaderID);
    glDeleteShader(_fragmentShaderID);
    
    glDeleteProgram(_programID);
    
    _vertexShaderID = _fragmentShaderID = _programID = 0;
}

#pragma mark - Shader/Program Utils
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil].UTF8String;
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram
{
    GLint status;
    glLinkProgram(self.programID);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(self.programID, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(self.programID, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(self.programID, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram
{
    GLint logLength, status;
    
    glValidateProgram(self.programID);
    glGetProgramiv(self.programID, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(self.programID, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(self.programID, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
