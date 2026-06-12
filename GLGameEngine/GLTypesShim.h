//
//  GLTypesShim.h
//  GLGameEngine
//
//  Scalar typedefs formerly provided by <OpenGLES/gltypes.h>, so that all
//  existing method/function signatures stay unchanged after the OpenGL ES
//  framework is removed from the iOS target.
//

#ifndef GLGameEngine_GLTypesShim_h
#define GLGameEngine_GLTypesShim_h

#include <stdint.h>

#if !defined(GL_ES_VERSION_3_0) && !defined(__gltypes_h_)

typedef float    GLfloat;
typedef double   GLdouble;
typedef uint32_t GLuint;
typedef int32_t  GLint;
typedef int32_t  GLsizei;
typedef uint8_t  GLboolean;
typedef uint32_t GLenum;
typedef uint32_t GLbitfield;
typedef uint8_t  GLubyte;
typedef int8_t   GLbyte;
typedef int16_t  GLshort;
typedef uint16_t GLushort;
typedef char     GLchar;

#endif

#endif /* GLGameEngine_GLTypesShim_h */
