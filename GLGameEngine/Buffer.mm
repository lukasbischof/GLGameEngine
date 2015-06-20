//
//  Buffer.m
//  GLGameEngine
//
//  Created by Lukas Bischof on 29.05.15.
//  Copyright (c) 2015 Lukas Bischof. All rights reserved.
//

#import "Buffer.h"

Buffer BufferCreateWithDataNoCopy(const void *data, size_t length)
{
    if (data == NULL) {
        printf("Buffer: Can't create a buffer with NULL data\n");
        return (Buffer){};
    }
    
    Buffer buffer;
    buffer.data = data;
    buffer.length = length;
    
    return buffer;
}

Buffer BufferCreateWithDataCopy(const void *data, size_t length)
{
    if (data == NULL) {
        printf("Buffer: Can't create a buffer with NULL data\n");
        return (Buffer){};
    }
    
    if (length <= 0) {
        printf("Buffer: Can't create a copied buffer with length = 0\n");
        return (Buffer){};
    }
    
    Buffer buffer;
    buffer.data = malloc(length);
    buffer.length = length;
    
    memcpy((void *)buffer.data, data, length);
    
    return buffer;
}



FloatBuffer FloatBufferCreateWithDataNoCopy(const FLOAT_BUFFER_DATA_TYPE *data, size_t length)
{
    if (data == NULL) {
        printf("Buffer: Can't create a buffer with NULL data\n");
        return (FloatBuffer){};
    }
    
    FloatBuffer buffer;
    buffer.data = data;
    buffer.length = length;
    
    return buffer;
}

FloatBuffer FloatBufferCreateWithDataCopy(const FLOAT_BUFFER_DATA_TYPE *data, size_t length)
{
    if (data == NULL) {
        printf("Buffer: Can't create a buffer with NULL data\n");
        return (FloatBuffer){};
    }
    
    if (length <= 0) {
        printf("Buffer: Can't create a copied buffer with length = 0\n");
        return (FloatBuffer){};
    }
    
    FloatBuffer buffer;
    buffer.data = (const GLfloat *)malloc(length);
    buffer.length = length;
    
    memcpy((void *)buffer.data, data, length);
    
    return buffer;
}



UintBuffer UintBufferCreateWithDataNoCopy(const UINT_BUFFER_DATA_TYPE *data, size_t length)
{
    if (data == NULL) {
        printf("Buffer: Can't create a buffer with NULL data\n");
        return (UintBuffer){};
    }
    
    UintBuffer buffer;
    buffer.data = data;
    buffer.length = length;
    
    return buffer;
}

UintBuffer UintBufferCreateWithDataCopy(const UINT_BUFFER_DATA_TYPE *data, size_t length)
{
    if (data == NULL) {
        printf("Buffer: Can't create a buffer with NULL data\n");
        return (UintBuffer){};
    }
    
    if (length <= 0) {
        printf("Buffer: Can't create a copied buffer with length = 0\n");
        return (UintBuffer){};
    }
    
    UintBuffer buffer;
    buffer.data = (const GLuint *)malloc(length);
    buffer.length = length;
    
    memcpy((void *)buffer.data, data, length);
    
    return buffer;
}
