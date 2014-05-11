//
//  ViewController.m
//  Test3D
//
//  Created by Jose Lopes on 02/02/2014.
//  Copyright (c) 2014 Tom Berry. All rights reserved.
//

#import "ViewController.h"
#include "terrain.h"
#include "Settlement.h"
#include "glm/gtc/matrix_transform.hpp"
#include "glm/gtc/type_ptr.hpp"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
GLint uniforms[NUM_UNIFORMS];

struct SProgram
{
    GLint program;
    GLint uniforms[NUM_UNIFORMS];
};

#define ARC4RANDOM_MAX      0x100000000

float randFloat()
{
    return (float)((double)arc4random() / ARC4RANDOM_MAX);
}

const int XSize = 16;
const int YSize = 16;

//const float GRIDSIZE = 0.5f;
/*
GLfloat Height[2][2] =
{
    {2, 1},
    {2, 2}
};
*/
GLfloat OldHeight[10][10] =
{
    {3, 2, 1, 0.5, 2, 2, 2, 2, 2, 2},
    {3, 2, 1, 0.5, 2, 2, 2, 2, 2, 2},
    {3, 2, 1, 0.5, 2, 2, 2, 2, 2, 2},
    {2, 1, 0.5, 0, 2, 2, 2, 2, 2, 2},
    {2, 2.2, 2, 2, 2, 2, 2, 2, 2, 2},
    {2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    {2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    {2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    {2, 2, 2, 2, 2, 2, 2, 2, 2, 2},
    {2, 2, 2, 2, 2, 2, 2, 2, 2, 2}
};

GLfloat Height[16][16] =
{
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {0, 0, 1.5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
    {0, 1.5, 2, 1.5, 1.5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
    {0, 1, 1.5, 2, 2.5, 1.5, 1.5, 1, 1, 1, 1, 1, 1, 1, 1, 0},
    {0, 1, 1.5, 2.5, 2.5, 3, 2.5, 1.5, 1, 1, 1, 1, 1, 1, 1, 0},
    {0, 1, 1.5, 2, 3, 3, 3, 2.5, 2, 1, 1, 1, 1, 1, 1, 0},
    {0, 1, 1.5, 2, 3, 3, 3, 2.5, 2, 1, 1, 1, 1, 1, 1, 0},
    {0, 1, 1, 1, 2, 2, 3, 2, 2, 1.5, 1.5, 1, 1, 1, 1, 0},
    {0, 1, 1, 1, 1, 2, 3, 3, 2, 1.5, 1.5, 1, 1, 1, 0, 0},
    {0, 1, 1, 1, 1, 2, 3, 3, 2, 1.5, 1.5, 1.5, 1, 1, 1, 0},
    {0, 1, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 0},
    {0, 1, 1, 1, 1.5, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 0},
    {0, 1, 1, 1, 1.5, 2, 3, 3, 2, 1, 1, 1, 1, 1, 1, 0},
    {0, 1, 1, 1, 1, 2, 3, 3, 2, 1, 1, 1, 1, 1, 1, 0},
    {0, 0, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1, 1, 0, 0, 0},
    {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
};

GLfloat Height2[13][13] =
{
    {2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
};

GLKMatrix4 bezierWeightsOLD =
{
    1, -0.5, 0.6, -1,
    -0.97, 0.0, -1.97, 0.0,
    0.0, 0.5, 3.0, 0,
    1, -1, 1, -1
};
GLKMatrix4 bezierWeights =
{
    0, 1, 1, 1,
    0, 1, 1, 1,
    0, 1, 1, 1,
    0, 1, 1, 1
};

struct LSVertex
{
    GLKVector3 p;
    GLKVector3 n;
//    GLfloat x, y, z;
//    GLfloat nx, ny, nz;
};

struct BezierPatchVert
{
    GLfloat x, y;
};

const int VERTS_PER_EDGE = 10;
struct BezierPatchVert BezierVertices[VERTS_PER_EDGE*VERTS_PER_EDGE];

struct LSVertex LandscapeVerts[XSize*YSize*5];

GLubyte LandscapeIndices[XSize*YSize*3*4];

GLfloat gCubeVertexData[216] = 
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};

const int NUM_THINGS = 20;

@interface ViewController () {
    struct SProgram _program;
    struct SProgram _cubicProgram;

    GLKMatrix4 _viewProjectionMatrix;

    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix4 m_viewMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    GLuint LSVertexArray;
    
    GLKVector3 m_viewTargetPos;

    GLKVector3 m_thingPos[NUM_THINGS];
    float m_thingHeading[NUM_THINGS];

    float m_cameraPitch;
    float m_cameraYaw;
    float m_cameraDistance;
    
    CTerrain m_terrain;
    CSettlement m_settlement;

}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) GLKBaseEffect *effectBezier;

- (void)setupGL;
- (void)tearDownGL;

- (struct SProgram)loadShader:(NSString*)vertexShaderFName fragShader:(NSString*)fragShaderFName;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

float ComputeHeight( float worldX, float worldY );
float ComputeHeightOpt( float worldX, float worldY );

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    m_viewTargetPos = GLKVector3Make(0.0f, 0.0f, 0.0f);
    
    m_cameraPitch    = -0.8f;
    m_cameraYaw      = 0.7f;
    m_cameraDistance = 5.0f;

    for (int i=0; i<NUM_THINGS; i++)
    {
        m_thingPos[i] = GLKVector3Make((float)i, (float)i, 0.0f);
        
        m_thingHeading[i] = randFloat() * M_PI * 2;
    }
    
    [self setupGL];

    m_settlement.Init(&m_terrain);

}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

const int offsX[9] =
{
    -1, 0, 1, -1, 0, 1, -1, 0, 1
};
const int offsY[9] =
{
    -1, -1, -1, 0, 0, 0, 1, 1, 1
};

- (void) getNeighbourHeight:(GLfloat[9]) ret xPos:(int)x yPos:(int)y
{
    for (int i=0; i<9; i++)
    {
        int newX = fminf(fmaxf(x+offsX[i], 0), XSize-1);
        int newY = fminf(fmaxf(y+offsY[i], 0), YSize-1);
        ret[i] = Height[newX][newY];
    }
}


- (GLfloat) heightAt:(float)x yPos:(float)y
{
    // Given a (x, z) position on the rendered height map this method
    // calculates the exact normal of the height map at that (x, z) position
    // using bilinear interpolation.
    
    x /= 1.0f;
    y /= 1.0f;
    
    //    assert(x >= 0.0f && x < (float)XSize);
    //    assert(y >= 0.0f && y < (float)YSize);
    
    int ix = (int)(x);
    int iy = (int)(y);
    
    float percentX = x - (float)(ix);
    float percentY = y - (float)(iy);
    
    GLfloat topLeft = Height[ix][iy];
    GLfloat topRight = Height[ix+1][iy];
    GLfloat bottomLeft = Height[ix][iy+1];
    GLfloat bottomRight = Height[ix+1][iy+1];
    
    GLfloat height;
    
    height = topLeft * (1.0f-percentX) * (1.0f-percentY);
    height += topRight * percentX * (1.0f-percentY);
    height += bottomLeft * (1.0f-percentX) * percentY;
    height += bottomRight * percentX * percentY;
    
    return height;
}

- (GLKVector3) normalAt:(float)x yPos:(float)y
{
    // Given a (x, z) position on the rendered height map this method
    // calculates the exact normal of the height map at that (x, z) position
    // using bilinear interpolation.
    
    x /= 1.0f;
    y /= 1.0f;
    
//    assert(x >= 0.0f && x < (float)XSize);
//    assert(y >= 0.0f && y < (float)YSize);
    
    int ix = (int)(x);
    int iy = (int)(y);
    
    float percentX = x - (float)(ix);
    float percentY = y - (float)(iy);
    
    GLKVector3 topLeft = [self normalAtPixel:ix yPos:iy];
    GLKVector3 topRight = [self normalAtPixel:ix+1 yPos:iy];
    GLKVector3 bottomLeft = [self normalAtPixel:ix yPos:iy+1];
    GLKVector3 bottomRight = [self normalAtPixel:ix+1 yPos:iy+1];

    GLKVector3 normal;

    normal = GLKVector3MultiplyScalar(topLeft, (1.0f-percentX) * (1.0f-percentY));
    normal = GLKVector3Add(normal, GLKVector3MultiplyScalar(topRight, percentX * (1.0f-percentY)));
    normal = GLKVector3Add(normal, GLKVector3MultiplyScalar(bottomLeft, (1.0f-percentX) * percentY));
    normal = GLKVector3Add(normal, GLKVector3MultiplyScalar(bottomRight, percentX * percentY));
    
    normal = GLKVector3Normalize(normal);
    
    return normal;
}

- (GLKVector3) normalAtPixel:(int)x yPos:(int)y
{
    // Returns the normal at the specified location on the height map.
    // The normal is calculated using the properties of the height map.
    // This approach is much quicker and more elegant than triangulating the
    // height map and averaging triangle surface normals.
    GLKVector3 n;
    if (x > 0 && x < XSize - 1)
        n.x = Height[x - 1][y] - Height[x + 1][y];
    else if (x > 0)
        n.x = 2.0f * (Height[x - 1][y] - Height[x][y]);
    else
        n.x = 2.0f * (Height[x][y] - Height[x + 1][y]);
    
    if (y > 0 && y < YSize - 1)
        n.y = Height[x][y - 1] - Height[x][y + 1];
    else if (y > 0)
        n.y = 2.0f * (Height[x][y - 1] - Height[x][y]);
    else
        n.y = 2.0f * (Height[x][y] - Height[x][y + 1]);
    
    n.z = 2.0f * 1.0f;// * m_gridSpacing;
    n = GLKVector3Normalize(n);
    
    return n;
}


- (void) createLandscape
{
    GLfloat surroundHeight[9];
    for (int y=0; y<YSize; y++)
    {
        for (int x=0; x<XSize; x++)
        {
            [self getNeighbourHeight:surroundHeight xPos:x yPos:y];
            
            int initialVert = ((y * XSize)+x) *5;
            struct LSVertex *pVert = LandscapeVerts+initialVert;
            pVert[0].p.x = x+0.5f;
            pVert[0].p.y = y+0.5f;
            pVert[0].p.z = [self heightAt:pVert[0].p.x yPos:pVert[0].p.y];// Height[x][y];
            
            pVert[1].p.x = x;
            pVert[1].p.y = y;
            pVert[1].p.z = [self heightAt:pVert[1].p.x yPos:pVert[1].p.y];//(surroundHeight[0]+surroundHeight[1]+surroundHeight[3]+surroundHeight[4]) * 0.25f;
            
            pVert[2].p.x = x+1;
            pVert[2].p.y = y;
            pVert[2].p.z = [self heightAt:pVert[2].p.x yPos:pVert[2].p.y];//(surroundHeight[1]+surroundHeight[2]+surroundHeight[4]+surroundHeight[5]) * 0.25f;
            
            pVert[3].p.x = x;
            pVert[3].p.y = y+1;
            pVert[3].p.z = [self heightAt:pVert[3].p.x yPos:pVert[3].p.y];//(surroundHeight[3]+surroundHeight[4]+surroundHeight[6]+surroundHeight[7]) * 0.25f;
            
            pVert[4].p.x = x+1;
            pVert[4].p.y = y+1;
            pVert[4].p.z = [self heightAt:pVert[4].p.x yPos:pVert[4].p.y];//(surroundHeight[4]+surroundHeight[5]+surroundHeight[7]+surroundHeight[8]) * 0.25f;
            
            for (int p=0; p<5; p++)
            {
                pVert[p].n = [self normalAt:pVert[p].p.x yPos:pVert[p].p.y];
            }
            
            GLubyte *pIndices = LandscapeIndices+(((y * XSize)+x) * 3*4);
            *(pIndices++) = initialVert;
            *(pIndices++) = initialVert+1;
            *(pIndices++) = initialVert+2;

            *(pIndices++) = initialVert;
            *(pIndices++) = initialVert+2;
            *(pIndices++) = initialVert+4;
            
            *(pIndices++) = initialVert;
            *(pIndices++) = initialVert+4;
            *(pIndices++) = initialVert+3;
            
            *(pIndices++) = initialVert;
            *(pIndices++) = initialVert+3;
            *(pIndices++) = initialVert+1;
        }
    }
}

GLuint BPVertexArray;
GLuint BPVertexBuffer;
GLuint BPIndexBuffer;
- (void) createBezierPatch
{
    const int vbSize = (VERTS_PER_EDGE * VERTS_PER_EDGE);
    struct BezierPatchVert verts[vbSize];
    const int ibSize = (6 * (VERTS_PER_EDGE-1) * (VERTS_PER_EDGE-1));
    GLubyte indices[ibSize];
    
    struct BezierPatchVert *pVerts = verts;
    for( int y = 0; y < VERTS_PER_EDGE; y++ )
    {
        for( int x = 0; x < VERTS_PER_EDGE; x++ )
        {
            pVerts->x = ((float)( x ) / (float)( VERTS_PER_EDGE - 1 ));
            pVerts->y = ((float)( y ) / (float)( VERTS_PER_EDGE - 1 ));
            pVerts++;
        }
    }

    GLubyte *pIndices = indices;
    for( int y = 1; y < VERTS_PER_EDGE; y++ )
    {
        for( int x = 1; x < VERTS_PER_EDGE; x++ )
        {
            *pIndices++ = ( y - 1 ) * VERTS_PER_EDGE + ( x - 1 );
            *pIndices++ = ( y - 0 ) * VERTS_PER_EDGE + ( x - 1 );
            *pIndices++ = ( y - 1 ) * VERTS_PER_EDGE + ( x - 0 );
            
            *pIndices++ = ( y - 1 ) * VERTS_PER_EDGE + ( x - 0 );
            *pIndices++ = ( y - 0 ) * VERTS_PER_EDGE + ( x - 1 );
            *pIndices++ = ( y - 0 ) * VERTS_PER_EDGE + ( x - 0 );
        }
    }

    
    glGenVertexArraysOES(1, &BPVertexArray);
    glBindVertexArrayOES(BPVertexArray);

    glGenBuffers(1, &BPVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, BPVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(verts), verts, GL_STATIC_DRAW);

    glGenBuffers(1, &BPIndexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, BPIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
    
    glBindVertexArrayOES(0);

    
    self.effectBezier = [[GLKBaseEffect alloc] init];
    self.effectBezier.light0.enabled = GL_TRUE;
    self.effectBezier.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);

}

GLuint LSVertexBuffer;
GLuint LSIndexBuffer;

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    _program = [self loadShader:@"Shader" fragShader:@"Shader"];
    _cubicProgram = [self loadShader:@"CubicShader" fragShader:@"Shader"];
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    
    glEnable(GL_DEPTH_TEST);
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    glBindVertexArrayOES(0);

    
    [self createLandscape];

    
    glGenVertexArraysOES(1, &LSVertexArray);
    glBindVertexArrayOES(LSVertexArray);
    
    glGenBuffers(1, &LSVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, LSVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(LandscapeVerts), LandscapeVerts, GL_STATIC_DRAW);
    
    glGenBuffers(1, &LSIndexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, LSIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(LandscapeIndices), LandscapeIndices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));

    glBindVertexArrayOES(0);
    
    [self createBezierPatch];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;
    self.effectBezier = nil;
    
    if (_program.program) {
        glDeleteProgram(_program.program);
        _program.program = 0;
    }
    
    if (_cubicProgram.program) {
        glDeleteProgram(_cubicProgram.program);
        _cubicProgram.program = 0;
    }
}
#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    self.effectBezier.transform.projectionMatrix = projectionMatrix;
    
    GLKVector3 lightDir = GLKQuaternionRotateVector3(GLKQuaternionMakeWithAngleAndAxis(_rotation, 1.0f, 0.0f, 0.0f), GLKVector3Make(0.0f, 0.0f, -1.0f));
    self.effectBezier.light0.position = GLKVector4MakeWithVector3(lightDir, 0.0f);
    self.effect.light0.position = GLKVector4MakeWithVector3(lightDir, 0.0f);
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
//    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    
    // Compute the model view matrix for the object rendered with GLKit
//    GLKMatrix4 viewMatrix = GLKMatrix4MakeLookAt(XSize/2, YSize/2, 10.0f, XSize/2, YSize/2, 0.0f, 0.0f, 1.0f, 0.0f);
    GLKQuaternion pitch = GLKQuaternionMakeWithAngleAndAxis(m_cameraPitch, 1.0f, 0.0f, 0.0f);
    GLKQuaternion yaw   = GLKQuaternionMakeWithAngleAndAxis(m_cameraYaw, 0.0f, 0.0f, 1.0f);
//    GLKQuaternion offset = GLKQuaternionMultiply(pitch, yaw);
    GLKVector3 pitchedOffset = GLKQuaternionRotateVector3(pitch, GLKVector3Make(0.0f, m_cameraDistance, 0.0f));
    GLKVector3 cameraOffset = GLKQuaternionRotateVector3(yaw, pitchedOffset);
    GLKVector3 cameraPos = GLKVector3Subtract(m_viewTargetPos, cameraOffset);
    cameraPos.z = MAX(ComputeHeight(cameraPos.x, cameraPos.y)+0.3f, cameraPos.z);
    m_viewMatrix = GLKMatrix4MakeLookAt(cameraPos.x, cameraPos.y, cameraPos.z, m_viewTargetPos.x, m_viewTargetPos.y, m_viewTargetPos.z, 0.0f, 0.0f, 1.0f);
//    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.5f);
////    viewMatrix = GLKMatrix4Rotate(viewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
//    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(m_viewMatrix, baseModelViewMatrix);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    self.effectBezier.transform.modelviewMatrix = modelViewMatrix;
    
    // Compute the model view matrix for the object rendered with ES2
/*    modelViewMatrix = GLKMatrix4MakeRotation(_rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0f, 0.0f, 1.5f);
//    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 1.5f);
//    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
 */
    
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    

    _viewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, m_viewMatrix);
    
    _rotation += self.timeSinceLastUpdate * 0.5f;
    
    float maxX = (float)((XSize-1) / 3);
    float maxY = (float)((YSize-1) / 3);
    float turnRate  = self.timeSinceLastUpdate * 6.0f;
    float moveSpeed = self.timeSinceLastUpdate * 1.0f;
    for (int i=0; i<NUM_THINGS; i++)
    {
        m_thingHeading[i] += (randFloat() * turnRate)-(turnRate*0.5f);
        
        float newX = m_thingPos[i].x + cosf(m_thingHeading[i]) * moveSpeed;
        float newY = m_thingPos[i].y + sinf(m_thingHeading[i]) * moveSpeed;
        
        if (newX < 0.0f)
        {
            newX = 0.0f;
            m_thingHeading[i] = (randFloat() * M_PI * 2.0) - M_PI;
        }
        else if (newX > maxX)
        {
            newX = maxX;
            m_thingHeading[i] = (randFloat() * M_PI * 2.0) - M_PI;
        }
        if (newY < 0.0f)
        {
            newY = 0.0f;
            m_thingHeading[i] = (randFloat() * M_PI * 2.0) - M_PI;
        }
        else if (newY > maxY)
        {
            newY = maxY;
            m_thingHeading[i] = (randFloat() * M_PI * 2.0) - M_PI;
        }
//        newX = MAX(0.0f, newX);
//        newY = MAX(0.0f, newY);
//        newX = MIN(maxX, newX);
//        newY = MIN(maxY, newY);
        
        m_thingPos[i].x = newX;
        m_thingPos[i].y = newY;
        m_thingPos[i].z = ComputeHeight(newX, newY);
    }
    
    static float frameCount = 0;
    frameCount += self.timeSinceLastUpdate;
    if (frameCount > 1.0f)
    {
        m_settlement.Update();
        frameCount = 0;
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
/*    glBindVertexArrayOES(_vertexArray);
    
    // Render the object with GLKit
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
*/
    
 /*   glBindVertexArrayOES(LSVertexArray);
    
    // Render the object with GLKit
    [self.effect prepareToDraw];

    glUseProgram(_program.program);

    glUniformMatrix4fv(_program.uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(_program.uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);

    glDrawElements(GL_TRIANGLES, sizeof(LandscapeIndices)/sizeof(LandscapeIndices[0]), GL_UNSIGNED_BYTE, 0);
*/

    //--- Draw patches
    glBindVertexArrayOES(BPVertexArray);
    
    glUseProgram(_cubicProgram.program);

    GLKMatrix4 patchWeights;
    int numXPatches = (XSize-1)/3;
    int numYPatches = (YSize-1)/3;
    for (int x=0; x<numXPatches; x++)
    {
        for (int y=0; y<numYPatches; y++)
        {
            GLKMatrix4 modelMatrix = GLKMatrix4MakeTranslation(x, y, 0.0f);
            _modelViewProjectionMatrix = GLKMatrix4Multiply(_viewProjectionMatrix, modelMatrix);
            
            glUniformMatrix4fv(_cubicProgram.uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
            for (int xx = 0; xx<4; xx++)
            {
                for (int yy = 0; yy<4; yy++)
                {
//                    patchWeights.m[((3-yy)*1)+((3-xx)*4)] = Height[xx + (x*3)][yy + (y*3)];
                    patchWeights.m[((3-yy)*4)+((3-xx)*1)] = Height[xx + (x*3)][yy + (y*3)];
//                    patchWeights.m[((/*3-*/yy)*4)+((/*3-*/xx)*1)] = Height[xx + (x*3)][yy + (y*3)];
                }
            }
            glUniformMatrix4fv(_cubicProgram.uniforms[UNIFORM_BEZIER_PATCH], 1, 0, patchWeights.m);

            const int ibSize = (6 * (VERTS_PER_EDGE-1) * (VERTS_PER_EDGE-1));
            glDrawElements(GL_TRIANGLES, ibSize, GL_UNSIGNED_BYTE, 0);
        
        }
    }
/*
    glBindVertexArrayOES(BPVertexArray);

    glUseProgram(_cubicProgram.program);
    
    glUniformMatrix4fv(_cubicProgram.uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
//    glUniformMatrix3fv(_cubicProgram.uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    glUniformMatrix4fv(_cubicProgram.uniforms[UNIFORM_BEZIER_PATCH], 1, 0, bezierWeights.m);
    
    const int ibSize = (6 * (VERTS_PER_EDGE-1) * (VERTS_PER_EDGE-1));
    glDrawElements(GL_TRIANGLES, ibSize, GL_UNSIGNED_BYTE, 0);
*/
   
/*    // Render the object again with ES2
    glUseProgram(_program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);*/
    
    glBindVertexArrayOES(_vertexArray);
    glUseProgram(_program.program);
    glUniformMatrix3fv(_program.uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
///*
 for (int i=0; i<NUM_THINGS; i++)
    {
        GLKMatrix4 modelMatrix = GLKMatrix4MakeTranslation(m_thingPos[i].x, m_thingPos[i].y, m_thingPos[i].z);
        modelMatrix = GLKMatrix4Scale(modelMatrix, 0.1f, 0.1f, 0.4f);

        _modelViewProjectionMatrix = GLKMatrix4Multiply(_viewProjectionMatrix, modelMatrix);
        glUniformMatrix4fv(_program.uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
        
        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
 //*/

    glm::mat3 normals = glm::make_mat3(_normalMatrix.m);
    glm::mat4 viewProj = glm::make_mat4(_viewProjectionMatrix.m);
    m_settlement.Draw(normals, viewProj);
    
/*
 float xPos = 0.0f;
    for (int x=0; x<XSize; x++)
    {
        float yPos = 0.0f;
        
        for (int y=0; y<YSize; y++)
        {
            GLKMatrix4 modelMatrix = GLKMatrix4MakeTranslation(xPos/3.0f, yPos/3.0f, ComputeHeight(xPos/3.0f, yPos/3.0f));
            modelMatrix = GLKMatrix4Scale(modelMatrix, 0.1f, 0.1f, 0.4f);
            
            _modelViewProjectionMatrix = GLKMatrix4Multiply(_viewProjectionMatrix, modelMatrix);
            glUniformMatrix4fv(_program.uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
            
            glDrawArrays(GL_TRIANGLES, 0, 36);

            yPos += 1.0f;
        }
        
        xPos += 1.0f;
    }
*/
}

#pragma mark -  OpenGL ES 2 shader compilation

- (struct SProgram)loadShader:(NSString*)vertexShaderFName fragShader:(NSString*)fragShaderFName;
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    struct SProgram prog;
    
    // Create shader program.
    prog.program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:vertexShaderFName ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return prog;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:fragShaderFName ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return prog;
    }
    
    // Attach vertex shader to program.
    glAttachShader(prog.program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(prog.program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(prog.program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(prog.program, GLKVertexAttribNormal, "normal");
    
    // Link program.
    if (![self linkProgram:prog.program]) {
        NSLog(@"Failed to link program: %d", prog.program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (prog.program) {
            glDeleteProgram(prog.program);
            prog.program = 0;
        }
        
        return prog;
    }
    
    // Get uniform locations.
    prog.uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(prog.program, "modelViewProjectionMatrix");
    prog.uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(prog.program, "normalMatrix");
    prog.uniforms[UNIFORM_BEZIER_PATCH] = glGetUniformLocation(prog.program, "mCubicWeights");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(prog.program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(prog.program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return prog;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
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

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    // MoooOOOoooooOOOOoooooOOOOoooo
    // red lorry yellow lorry red lorry yellow lorry red lorry yellow lorry red lorry yellow lorry red lorry yellow lorry
    // Peter Piper picked a peck of pickled peppers
    // If Peter Piper picked a peck of pickled peppers where's the pickled pepper Peter Piper picked
    // marshmallows burning in the bonfire
    // Daddy's beard is AWESOME!
    // Blah blah blah
    // Knox in box, Fox in socks
    // Luke Luck licks lakes, Luke Luck's duck licks lakes
    // Apple juice mummmmmmmmmm, I want to drink some
    return YES;
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    GLKVector3 viewTrans;
    viewTrans.x = -0.2f*(float)translation.x/(float)recognizer.view.frame.size.width;
    viewTrans.y = 0.2f*(float)translation.y/(float)recognizer.view.frame.size.height;
    viewTrans.z = 0.0f;
    GLKQuaternion yaw   = GLKQuaternionMakeWithAngleAndAxis(m_cameraYaw, 0.0f, 0.0f, 1.0f);
    GLKVector3 transPos = GLKQuaternionRotateVector3(yaw, viewTrans);

//    GLKMatrix4 copy = GLKMatrix4Transpose(GLKMatrix4SetColumn(m_viewMatrix, 3, GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f)));
//    GLKVector3 transPos = GLKMatrix4MultiplyVector3(copy, viewTrans);
    m_viewTargetPos = GLKVector3Add(m_viewTargetPos, transPos);
//    m_viewTargetPos.z = ComputeHeight(m_viewTargetPos.x, m_viewTargetPos.y)*0.5f;
/*    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];*/
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    m_cameraDistance += (recognizer.velocity * -0.1f);
    m_cameraDistance = MIN(m_cameraDistance, 10.0f);
    m_cameraDistance = MAX(m_cameraDistance, 1.0f);
    
    float t = (m_cameraDistance - 4.0f) / 4.0f;
    float delta = M_PI_2 - 0.85f;
    t = MAX(t, 0.0f);
    t = MIN(t, 1.0f);
    m_cameraPitch = -0.8f - (t * delta);
}

- (IBAction)handleRotation:(UIRotationGestureRecognizer *)recognizer
{
    m_cameraYaw += (recognizer.velocity * 0.1f);
}

float ComputeHeightOpt( float worldX, float worldY )
{
    int nx = (int)worldX;
    int ny = (int)worldY;
    float x = worldX - (float)nx;
    float y = worldY - (float)ny;
    nx = MIN(nx, (XSize-1) / 3);
    ny = MIN(ny, (YSize-1) / 3);
    nx = MAX(nx, 0);
    ny = MAX(ny, 0);
    
    int sx = 3*nx;
    int sy = 3*ny;
	
    // In order to simplify the main equation at the bottom, the
    // following aliases are used. They also have the added advantage of
    // being able to express the mathematics in factorized form - which
    // makes for a much tidier assembly listing...
	
    float x_2;
    x_2		=	x * x;
    float x_3;
    x_3		=	x_2 * x;
    
    float y_2;
    y_2		=	y * y;
    float y_3;
    y_3		=	y_2 * y;
    
    float a;
    a		=	1.0 - x;
    float a_2;
    a_2		=	a * a;
    float a_3;
    a_3		=	a_2 * a;
    
    float b;
    b		=	1.0 - y;
    float b_2;
    b_2		=	b * b;
    float b_3;
    b_3		=	b_2 * b;
    
    //The following equation has had several common factors pulled out to help the D3DX compiler
    //generate better code. Doing so knocked 6 instructions off the overall length.
    return   0.5f *
    (( Height[sx+3][sy+3] * x_3 * y_3 )
    + ( Height[sx+2][sy+3] * x_3 * y_2 * b )
    + ( Height[sx+0][sy+3] * x_3 * b_3 )
    
    + 2.0 * (
             (
              ( Height[sx+3][sy+2] * x_2 * a * y_3 )
              + ( Height[sx+0][sy+2] * b_3 * x_2 * a )
              + ( Height[sx+2][sy+0] * a_3 * y_2 * b )
              )
             
             + 2.0 *	(
                         (
                          ( Height[sx+1][sy+3] * x_3 * y * b_2 )
                          + ( Height[sx+3][sy+1] * x * y_3 * a_2 )
                          + ( Height[sx+2][sy+2] * x_2 * y_2 * a * b )
                          + ( Height[sx+0][sy+1] * x * a_2 * b_3 )
                          + ( Height[sx+1][sy+0] * y * b_2 * a_3 )
                          )
                         
                         + 2.0 *	(
                                     ( Height[sx+1][sy+2] * x_2 * a_2 * y * b_2 )
                                     + ( Height[sx+2][sy+1] * x * a_2 * y * b )
                                     )
                         )
             )
    
    + ( Height[sx+1][sy+1] * 16.0 * x * a_2 * y * b_2 )
    
    + ( Height[sx+3][sy+0] * a_3 * y_3 )
    + ( Height[sx+0][sy+0] * a_3 * b_3 ));
    
}

//-----------------------------------------------------------------------------
// Calculate height of position against height map
//-----------------------------------------------------------------------------
float ComputeHeight( float worldX, float worldY )
{
    int nx = (int)worldX;
    int ny = (int)worldY;
    float x = worldX - (float)nx;
    float y = worldY - (float)ny;
    nx = MIN(nx, (XSize-1) / 3);
    ny = MIN(ny, (YSize-1) / 3);
    nx = MAX(nx, 0);
    ny = MAX(ny, 0);
    
    x = MAX(x, 0.0f);
    y = MAX(y, 0.0f);
    
    int sx = 3*nx;
    int sy = 3*ny;
    
    float x_2;
    x_2		=	x * x;
    float x_3;
    x_3		=	x_2 * x;
    
    float y_2;
    y_2		=	y * y;
    float y_3;
    y_3		=	y_2 * y;
    
    float a;
    a		=	1.0 - x;
    float a_2;
    a_2		=	a * a;
    float a_3;
    a_3		=	a_2 * a;
    
    float b;
    b		=	1.0 - y;
    float b_2;
    b_2		=	b * b;
    float b_3;
    b_3		=	b_2 * b;
	
    const float xTerms[4] = {x_3,
                       x_2 * a,
                       x * a_2,
                        a_3 };
    
    const float yTerms[4] = {y_3,
                             y_2 * b,
                             y * b_2,
                             b_3 };
    
/*    
 return  0.5f * (( 1.0 * Height[sx+0][sy+0] * xTerms[0] * yTerms[0] ) + ( 1.0 * Height[sx+0][sy+1] * xTerms[1] * yTerms[0] ) + (  4.0 * Height[sx+0][sy+2] * xTerms[2] * yTerms[0] ) + ( 1.0 * Height[sx+0][sy+3] * xTerms[3] * yTerms[0] ) +
                    ( 2.0 * Height[sx+1][sy+0] * xTerms[0] * yTerms[1] ) + ( 4.0 * Height[sx+1][sy+1] * xTerms[1] * yTerms[1] ) + (  8.0 * Height[sx+1][sy+2] * xTerms[2] * yTerms[1] ) + ( 2.0 * Height[sx+1][sy+3] * xTerms[3] * yTerms[1] ) +
                    ( 4.0 * Height[sx+2][sy+0] * xTerms[0] * yTerms[2] ) + ( 8.0 * Height[sx+2][sy+1] * xTerms[1] * yTerms[2] ) + ( 16.0 * Height[sx+2][sy+2] * xTerms[2] * yTerms[2] ) + ( 4.0 * Height[sx+2][sy+3] * xTerms[3] * yTerms[2] ) +
                    ( 1.0 * Height[sx+3][sy+0] * xTerms[0] * yTerms[3] ) + ( 2.0 * Height[sx+3][sy+1] * xTerms[1] * yTerms[3] ) + (  4.0 * Height[sx+3][sy+2] * xTerms[2] * yTerms[3] ) + ( 1.0 * Height[sx+3][sy+3] * xTerms[3] * yTerms[3] ));
*/

    
return  0.5f *
    (( 1.0 * Height[sx+3][sy+3] * xTerms[0] * yTerms[0] ) + ( 1.0 * Height[sx+2][sy+3] * xTerms[1] * yTerms[0] ) + (  4.0 * Height[sx+1][sy+3] * xTerms[2] * yTerms[0] ) + ( 1.0 * Height[sx+0][sy+3] * xTerms[3] * yTerms[0] ) +
     ( 2.0 * Height[sx+3][sy+2] * xTerms[0] * yTerms[1] ) + ( 4.0 * Height[sx+2][sy+2] * xTerms[1] * yTerms[1] ) + (  8.0 * Height[sx+1][sy+2] * xTerms[2] * yTerms[1] ) + ( 2.0 * Height[sx+0][sy+2] * xTerms[3] * yTerms[1] ) +
     ( 4.0 * Height[sx+3][sy+1] * xTerms[0] * yTerms[2] ) + ( 8.0 * Height[sx+2][sy+1] * xTerms[1] * yTerms[2] ) + ( 16.0 * Height[sx+1][sy+1] * xTerms[2] * yTerms[2] ) + ( 4.0 * Height[sx+0][sy+1] * xTerms[3] * yTerms[2] ) +
     ( 1.0 * Height[sx+3][sy+0] * xTerms[0] * yTerms[3] ) + ( 2.0 * Height[sx+2][sy+0] * xTerms[1] * yTerms[3] ) + (  4.0 * Height[sx+1][sy+0] * xTerms[2] * yTerms[3] ) + ( 1.0 * Height[sx+0][sy+0] * xTerms[3] * yTerms[3] ));
/*
    return  0.5f * (( 1.0 * Height[sx+3][sy+3] * xTerms[0] * yTerms[0] ) + ( 1.0 * Height[sx+3][sy+2] * xTerms[1] * yTerms[0] ) + (  4.0 * Height[sx+3][sy+1] * xTerms[2] * yTerms[0] ) + ( 1.0 * Height[sx+3][sy+0] * xTerms[3] * yTerms[0] ) +
                    ( 2.0 * Height[sx+2][sy+3] * xTerms[0] * yTerms[1] ) + ( 4.0 * Height[sx+2][sy+2] * xTerms[1] * yTerms[1] ) + (  8.0 * Height[sx+2][sy+1] * xTerms[2] * yTerms[1] ) + ( 2.0 * Height[sx+2][sy+0] * xTerms[3] * yTerms[1] ) +
                    ( 4.0 * Height[sx+1][sy+3] * xTerms[0] * yTerms[2] ) + ( 8.0 * Height[sx+1][sy+2] * xTerms[1] * yTerms[2] ) + ( 16.0 * Height[sx+1][sy+1] * xTerms[2] * yTerms[2] ) + ( 4.0 * Height[sx+1][sy+0] * xTerms[3] * yTerms[2] ) +
                    ( 1.0 * Height[sx+0][sy+3] * xTerms[0] * yTerms[3] ) + ( 2.0 * Height[sx+0][sy+2] * xTerms[1] * yTerms[3] ) + (  4.0 * Height[sx+0][sy+1] * xTerms[2] * yTerms[3] ) + ( 1.0 * Height[sx+0][sy+0] * xTerms[3] * yTerms[3] ));
 */
/*
 return  0.5f * (( 1.0 * Height[sy+3][sx+3] * xTerms[0] * yTerms[0] ) + ( 1.0 * Height[sy+2][sx+3] * xTerms[1] * yTerms[0] ) + (  4.0 * Height[sy+1][sx+3] * xTerms[2] * yTerms[0] ) + ( 1.0 * Height[sy+0][sx+3] * xTerms[3] * yTerms[0] ) +
 ( 2.0 * Height[sy+3][sx+2] * xTerms[0] * yTerms[1] ) + ( 4.0 * Height[sy+2][sx+2] * xTerms[1] * yTerms[1] ) + (  8.0 * Height[sy+1][sx+2] * xTerms[2] * yTerms[1] ) + ( 2.0 * Height[sy+0][sx+2] * xTerms[3] * yTerms[1] ) +
 ( 4.0 * Height[sy+3][sx+1] * xTerms[0] * yTerms[2] ) + ( 8.0 * Height[sy+2][sx+1] * xTerms[1] * yTerms[2] ) + ( 16.0 * Height[sy+1][sx+1] * xTerms[2] * yTerms[2] ) + ( 4.0 * Height[sy+0][sx+1] * xTerms[3] * yTerms[2] ) +
 ( 1.0 * Height[sy+3][sx+0] * xTerms[0] * yTerms[3] ) + ( 2.0 * Height[sy+2][sx+0] * xTerms[1] * yTerms[3] ) + (  4.0 * Height[sy+1][sx+0] * xTerms[2] * yTerms[3] ) + ( 1.0 * Height[sy+0][sx+0] * xTerms[3] * yTerms[3] ));
 */
}


@end
