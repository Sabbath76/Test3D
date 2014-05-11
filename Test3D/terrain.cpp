//
//  terrian.cpp
//  Test3D
//
//  Created by Jose Lopes on 03/05/2014.
//  Copyright (c) 2014 Tom Berry. All rights reserved.
//

#include "terrain.h"


float HEIGHTMAP[] =
{
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 1.5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    0, 1.5, 2, 1.5, 1.5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    0, 1, 1.5, 2, 2.5, 1.5, 1.5, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    0, 1, 1.5, 2.5, 2.5, 3, 2.5, 1.5, 1, 1, 1, 1, 1, 1, 1, 0,
    0, 1, 1.5, 2, 3, 3, 3, 2.5, 2, 1, 1, 1, 1, 1, 1, 0,
    0, 1, 1.5, 2, 3, 3, 3, 2.5, 2, 1, 1, 1, 1, 1, 1, 0,
    0, 1, 1, 1, 2, 2, 3, 2, 2, 1.5, 1.5, 1, 1, 1, 1, 0,
    0, 1, 1, 1, 1, 2, 3, 3, 2, 1.5, 1.5, 1, 1, 1, 0, 0,
    0, 1, 1, 1, 1, 2, 3, 3, 2, 1.5, 1.5, 1.5, 1, 1, 1, 0,
    0, 1, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 0,
    0, 1, 1, 1, 1.5, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 0,
    0, 1, 1, 1, 1.5, 2, 3, 3, 2, 1, 1, 1, 1, 1, 1, 0,
    0, 1, 1, 1, 1, 2, 3, 3, 2, 1, 1, 1, 1, 1, 1, 0,
    0, 0, 1, 1, 1, 2, 2, 2, 1, 1, 1, 1, 1, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};


CTerrain::CTerrain()
{
    m_heights = HEIGHTMAP;
    m_xSize = 16;
    m_ySize = 16;
    
}

template <typename T>
inline T min( T a, T b)
{
    return (a<b) ? a : b;
}
template <typename T>
inline T max( T a, T b)
{
    return (a>b) ? a : b;
}

//-----------------------------------------------------------------------------
// Calculate m_heights of position against m_heights map
//-----------------------------------------------------------------------------
float CTerrain::ComputeHeight( float worldX, float worldY ) const
{
    int nx = (int)worldX;
    int ny = (int)worldY;
    float x = worldX - (float)nx;
    float y = worldY - (float)ny;
    nx = min(nx, (m_xSize-1) / 3);
    ny = min(ny, (m_ySize-1) / 3);
    nx = max(nx, 0);
    ny = max(ny, 0);
    
    x = max(x, 0.0f);
    y = max(y, 0.0f);
    
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
    
    return  0.5f *
    (( 1.0 * m_heights[sx+3+((sy+3) * m_xSize)] * xTerms[0] * yTerms[0] ) + ( 1.0 * m_heights[sx+2+((sy+3) * m_xSize)] * xTerms[1] * yTerms[0] ) + (  4.0 * m_heights[sx+1+((sy+3) * m_xSize)] * xTerms[2] * yTerms[0] ) + ( 1.0 * m_heights[sx+0+((sy+3)*m_xSize)] * xTerms[3] * yTerms[0] ) +
     ( 2.0 * m_heights[sx+3+((sy+2)*m_xSize)] * xTerms[0] * yTerms[1] ) + ( 4.0 * m_heights[sx+2+((sy+2)*m_xSize)] * xTerms[1] * yTerms[1] ) + (  8.0 * m_heights[sx+1+((sy+2)*m_xSize)] * xTerms[2] * yTerms[1] ) + ( 2.0 * m_heights[sx+0+((sy+2)*m_xSize)] * xTerms[3] * yTerms[1] ) +
     ( 4.0 * m_heights[sx+3+((sy+1)*m_xSize)] * xTerms[0] * yTerms[2] ) + ( 8.0 * m_heights[sx+2+((sy+1)*m_xSize)] * xTerms[1] * yTerms[2] ) + ( 16.0 * m_heights[sx+1+((sy+1)*m_xSize)] * xTerms[2] * yTerms[2] ) + ( 4.0 * m_heights[sx+0+((sy+1)*m_xSize)] * xTerms[3] * yTerms[2] ) +
     ( 1.0 * m_heights[sx+3+((sy+0)*m_xSize)] * xTerms[0] * yTerms[3] ) + ( 2.0 * m_heights[sx+2+((sy+0)*m_xSize)] * xTerms[1] * yTerms[3] ) + (  4.0 * m_heights[sx+1+((sy+0)*m_xSize)] * xTerms[2] * yTerms[3] ) + ( 1.0 * m_heights[sx+0+((sy+0)*m_xSize)] * xTerms[3] * yTerms[3] ));
}