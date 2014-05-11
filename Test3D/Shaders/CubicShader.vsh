//
//  Shader.vsh
//  Test3D
//
//  Created by Jose Lopes on 02/02/2014.
//  Copyright (c) 2014 Tom Berry. All rights reserved.
//

attribute vec2 position;

varying lowp vec4 colorVarying;

uniform mat4 mCubicWeights;
uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;



//-----------------------------------------------------------------------------
// The main mathematical function for this is:
//   (A+B)^3 ï (C+D)^3 == 1
// Where A and B are [0..1] along the X edge, and C, D are along the Y edge
//   (A+(1-A)^3 ï (B+(1-B))^3 == 1
// Is a trivial replacement based on rearrangement
// Expanding out one half (e.g. A) gives the following cubic:
//   (A^3 + 3A^2(1-A) + 3A(1-A)^2 + (1-A)^3)
// The curve created can be controlled by adding 4 coefficients in for each term:
//   (aA^3 + b3A^2(1-A) + c3A(1-A)^2 + d(1-A)^3)
// The coefficients are noted by the lower-case letters a, b, c and d.
// When plotted in 2D the curve will go from 'a' to 'd' and be influenced by 'b' and 'c'.
//
// For a 2D surface such as the one being created here, the two cubics
// should be multiplied together:
//
//            | X^3                | X^2(1-X)                | X(1-X)^2                 | (1-X)^3
// -----------+--------------------+-------------------------+--------------------------+-----------------------
//  Y^3       | 1ï(X^3)ï(Y^3)      | 1ï(X^2(1-X))ï(Y^3)      |  4ï(3X(1-X)^2)ï(Y^3)     | 1ï((1-X)^3)ï(Y^3)
// -----------+--------------------+-------------------------+--------------------------+-----------------------
//  Y^2(1-Y)  | 2ï(X^3)ï(Y^2(1-Y)) | 4ï(X^2(1-X))ï(Y^2(1-Y)) |  8ï(X(1-X)^2)ï(Y^2(1-Y)) | 2ï((1-X)^3)ï(Y^2(1-Y))
// -----------+--------------------+-------------------------+--------------------------+-----------------------
//  Y(1-Y)^2  | 4ï(X^3)ï(Y(1-Y)^2) | 8ï(X^2(1-X))ï(Y(1-Y)^2) | 16ï(X(1-X)^2)ï(Y(1-Y)^2) | 4ï((1-X)^3)ï(Y(1-Y)^2)
// -----------+--------------------+-------------------------+--------------------------+-----------------------
//  (1-Y)^3   | 1ï(X^3)ï((1-Y)^3)  | 2ï(X^2(1-X))ï((1-Y)^3)  |  4ï(X(1-X)^2)ï((1-Y)^3)  | 1ï((1-X)^3)ï((1-Y)^3)
//
// The final height is defined as the summation of all 16 functions in the above table, the
// actual shape of the curve is controlled by placing a coefficient in front of each of the
// terms. These coefficients are stored in a matching 4x4 matrix called 'mCubicWeights'.
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Optimized implementation of the above mathematics. Generates 58 Instructions
//-----------------------------------------------------------------------------
float ComputeHeight1( float x, float y )
{
	
    // In order to simplify the main equation at the bottom, the
    // following aliases are used. They also have the added advantage of
    // being able to express the mathematics in factorized form - which
    // makes for a much tidier assembly listing...
    x = clamp(x, 0.0, 1.0);
    y = clamp(y, 0.0, 1.0);
	
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
    return   ( mCubicWeights[0][0] * x_3 * y_3 )
    + ( mCubicWeights[1][0] * x_3 * y_2 * b )
    + ( mCubicWeights[3][0] * x_3 * b_3 )
    
    + 2.0 * (
              (
               ( mCubicWeights[0][1] * x_2 * a * y_3 )
               + ( mCubicWeights[3][1] * b_3 * x_2 * a )
               + ( mCubicWeights[1][3] * a_3 * y_2 * b )
               )
              
              + 2.0 *	(
                         (
                          ( mCubicWeights[2][0] * x_3 * y * b_2 )
                          + ( mCubicWeights[0][2] * x * y_3 * a_2 )
                          + ( mCubicWeights[1][1] * x_2 * y_2 * a * b )
                          + ( mCubicWeights[3][2] * x * a_2 * b_3 )
                          + ( mCubicWeights[2][3] * y * b_2 * a_3 )
                          )
                         
                         + 2.0 *	(
                                     ( mCubicWeights[2][1] * x_2 * a_2 * y * b_2 )
                                     + ( mCubicWeights[1][2] * x * a_2 * y * b )
                                     )
                         )
              )
    
    + ( mCubicWeights[2][2] * 16.0 * x * a_2 * y * b_2 )
    
    + ( mCubicWeights[0][3] * a_3 * y_3 )          
    + ( mCubicWeights[3][3] * a_3 * b_3 );
    
}

//-----------------------------------------------------------------------------
// Trivial implementation of the above mathematics. Generates 64 instructions
//-----------------------------------------------------------------------------
float ComputeHeight2( float x, float y )
{
    x = clamp(x, 0.0, 1.0);
    y = clamp(y, 0.0, 1.0);
	
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
	
    vec4 xTerms = vec4( x_3,
                           x_2 * a,
                           x * a_2,
                           a_3 );
    
    vec4 yTerms = vec4( y_3,
                           y_2 * b,
                           y * b_2,
                           b_3 );
    
    return  ( 1.0 * mCubicWeights[0][0] * xTerms[0] * yTerms[0] ) + ( 1.0 * mCubicWeights[1][0] * xTerms[1] * yTerms[0] ) + (  4.0 * mCubicWeights[2][0] * xTerms[2] * yTerms[0] ) + ( 1.0 * mCubicWeights[3][0] * xTerms[3] * yTerms[0] ) +
    ( 2.0 * mCubicWeights[0][1] * xTerms[0] * yTerms[1] ) + ( 4.0 * mCubicWeights[1][1] * xTerms[1] * yTerms[1] ) + (  8.0 * mCubicWeights[2][1] * xTerms[2] * yTerms[1] ) + ( 2.0 * mCubicWeights[3][1] * xTerms[3] * yTerms[1] ) +
    ( 4.0 * mCubicWeights[0][2] * xTerms[0] * yTerms[2] ) + ( 8.0 * mCubicWeights[1][2] * xTerms[1] * yTerms[2] ) + ( 16.0 * mCubicWeights[2][2] * xTerms[2] * yTerms[2] ) + ( 4.0 * mCubicWeights[3][2] * xTerms[3] * yTerms[2] ) +
    ( 1.0 * mCubicWeights[0][3] * xTerms[0] * yTerms[3] ) + ( 2.0 * mCubicWeights[1][3] * xTerms[1] * yTerms[3] ) + (  4.0 * mCubicWeights[2][3] * xTerms[2] * yTerms[3] ) + ( 1.0 * mCubicWeights[3][3] * xTerms[3] * yTerms[3] );
    
}

void main()
{
/*    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(0.4, 0.4, 1.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
                 
    colorVarying = diffuseColor * nDotVP;*/
    float height = ComputeHeight1(position.x, position.y);
    vec4 position4 = vec4(position.x, position.y, height*0.5, 1.0);

/*    float xx = (position.x + 0.5) * 4.0;
    float yy = (position.y + 0.5) * 4.0;
    int ix = int(xx);
    int iy = int(yy);
    if (ix >= 4)
    {
        ix = 3;
    }
    if (iy >= 4)
    {
        iy = 3;
    }
    float col = mCubicWeights[ix][iy];*/
    colorVarying = vec4(height*0.15, sin(height)*0.5, height*0.15, 0);

    gl_Position = modelViewProjectionMatrix * position4;
}
