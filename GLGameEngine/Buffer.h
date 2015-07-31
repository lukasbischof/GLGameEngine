//
//  Buffer.h
//  GLGameEngine
//
//  Created by Lukas Bischof on 29.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#ifndef BUFFER_H
#define BUFFER_H

#include <stdio.h>
#include <stdlib.h> // malloc
#include <string.h> // memcpy
#include <sys/types.h>
#include <TargetConditionals.h>

#if !(TARGET_OS_IPHONE)
#include <OpenGL/OpenGL.h>
#else
#include <OpenGLES/gltypes.h>
#endif

#if TARGET_OS_WIN32
    #if !defined(EXPORT)
        #if !defined(__cplusplus)
            #define EXPORT extern __declspec(dllexport)
        #elif defined(__cplusplus)
            #define EXPORT extern "C" __declspec(dllimport)
        #else
            #define EXPORT extern __declspec(dllimport)
        #endif
    #endif
#else
    #define EXPORT extern
#endif

#define FLOAT_BUFFER_DATA_TYPE GLfloat
#define FLOAT_BUFFER_ELEMENT_SIZE sizeof(FLOAT_BUFFER_DATA_TYPE)

#define UINT_BUFFER_DATA_TYPE GLuint
#define UINT_BUFFER_ELEMENT_SIZE sizeof(UINT_BUFFER_DATA_TYPE)

struct _Buffer {
    /// The data
    const void *data;
    
    /// The lenght of the data
    size_t length;
};
typedef struct _Buffer Buffer;

struct _FloatBuffer {
    const FLOAT_BUFFER_DATA_TYPE *data;
    size_t length;
};
typedef struct _FloatBuffer FloatBuffer;

struct _UintBuffer {
    const UINT_BUFFER_DATA_TYPE *data;
    size_t length;
};
typedef struct _UintBuffer UintBuffer;


EXPORT
Buffer BufferCreateWithDataNoCopy(const void *data, size_t length);

EXPORT
Buffer BufferCreateWithDataCopy(const void *data, size_t length);


EXPORT
FloatBuffer FloatBufferCreateWithDataNoCopy(const FLOAT_BUFFER_DATA_TYPE *data, size_t length);

EXPORT
FloatBuffer FloatBufferCreateWithDataCopy(const FLOAT_BUFFER_DATA_TYPE *data, size_t length);


EXPORT
UintBuffer UintBufferCreateWithDataNoCopy(const UINT_BUFFER_DATA_TYPE *data, size_t length);

EXPORT
UintBuffer UintBufferCreateWithDataCopy(const UINT_BUFFER_DATA_TYPE *data, size_t length);


#endif
