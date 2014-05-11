//-----------------------------------------------------------------------------
// Global variables
//-----------------------------------------------------------------------------
float4x4 mWorldViewProj;  // World * View * Projection transformation
float4x4 mCubicWeights;	  //used in the ComputeHeight() function



//-----------------------------------------------------------------------------
// Vertex shader output structure
//-----------------------------------------------------------------------------
struct VS_OUTPUT
	{
		float4 Position   : POSITION;   // vertex position 
		float4 Diffuse    : COLOR0;     // vertex diffuse color
	};


//-----------------------------------------------------------------------------
// The main mathematical function for this is:
//   (A+B)^3 • (C+D)^3 == 1
// Where A and B are [0..1] along the X edge, and C, D are along the Y edge
//   (A+(1-A)^3 • (B+(1-B))^3 == 1
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
//  Y^3       | 1•(X^3)•(Y^3)      | 1•(X^2(1-X))•(Y^3)      |  4•(3X(1-X)^2)•(Y^3)     | 1•((1-X)^3)•(Y^3)
// -----------+--------------------+-------------------------+--------------------------+-----------------------
//  Y^2(1-Y)  | 2•(X^3)•(Y^2(1-Y)) | 4•(X^2(1-X))•(Y^2(1-Y)) |  8•(X(1-X)^2)•(Y^2(1-Y)) | 2•((1-X)^3)•(Y^2(1-Y))
// -----------+--------------------+-------------------------+--------------------------+-----------------------
//  Y(1-Y)^2  | 4•(X^3)•(Y(1-Y)^2) | 8•(X^2(1-X))•(Y(1-Y)^2) | 16•(X(1-X)^2)•(Y(1-Y)^2) | 4•((1-X)^3)•(Y(1-Y)^2)
// -----------+--------------------+-------------------------+--------------------------+-----------------------
//  (1-Y)^3   | 1•(X^3)•((1-Y)^3)  | 2•(X^2(1-X))•((1-Y)^3)  |  4•(X(1-X)^2)•((1-Y)^3)  | 1•((1-X)^3)•((1-Y)^3)
//
// The final height is defined as the summation of all 16 functions in the above table, the
// actual shape of the curve is controlled by placing a coefficient in front of each of the
// terms. These coefficients are stored in a matching 4x4 matrix called 'mCubicWeights'.
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Optimized implementation of the above mathematics. Generates 58 Instructions
//-----------------------------------------------------------------------------
float ComputeHeight1( in float x, in float y )
	{
	
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
			a		=	1.0f - x;
		float a_2;
			a_2		=	a * a;
		float a_3;
			a_3		=	a_2 * a;
		
		float b;
			b		=	1.0f - y;
		float b_2;
			b_2		=	b * b;
		float b_3;
			b_3		=	b_2 * b;
		
		//The following equation has had several common factors pulled out to help the D3DX compiler
		//generate better code. Doing so knocked 6 instructions off the overall length.
		return   ( mCubicWeights[0][0] * x_3 * y_3 ) 
			   + ( mCubicWeights[1][0] * x_3 * y_2 * b ) 
			   + ( mCubicWeights[3][0] * x_3 * b_3 ) 

			   + 2.0f * (
							(
								  ( mCubicWeights[0][1] * x_2 * a * y_3 )
								+ ( mCubicWeights[3][1] * b_3 * x_2 * a )
								+ ( mCubicWeights[1][3] * a_3 * y_2 * b ) 
							)
							
							+ 2.0f *	(
											(
												  ( mCubicWeights[2][0] * x_3 * y * b_2 ) 
												+ ( mCubicWeights[0][2] * x * y_3 * a_2 ) 
												+ ( mCubicWeights[1][1] * x_2 * y_2 * a * b ) 
												+ ( mCubicWeights[3][2] * x * a_2 * b_3 ) 
												+ ( mCubicWeights[2][3] * y * b_2 * a_3 )
											)

											+ 2.0f *	( 
															  ( mCubicWeights[2][1] * x_2 * a_2 * y * b_2 ) 
															+ ( mCubicWeights[1][2] * x * a_2 * y * b )
														)
										)
						)
			   
			   + ( mCubicWeights[2][2] * 16.0f * x * a_2 * y * b_2 ) 
			   
			   + ( mCubicWeights[0][3] * a_3 * y_3 )          
			   + ( mCubicWeights[3][3] * a_3 * b_3 );
		
	}



//-----------------------------------------------------------------------------
// Trivial implementation of the above mathematics. Generates 64 instructions
//-----------------------------------------------------------------------------
float ComputeHeight2( in float x, in float y )
	{
	
		float x_2;
			x_2		=	x * x;
		float x_3;
			x_3		=	x_2 * x;
		
		float y_2;
			y_2		=	y * y;
		float y_3;
			y_3		=	y_2 * y;
		
		float a;
			a		=	1.0f - x;
		float a_2;
			a_2		=	a * a;
		float a_3;
			a_3		=	a_2 * a;
		
		float b;
			b		=	1.0f - y;
		float b_2;
			b_2		=	b * b;
		float b_3;
			b_3		=	b_2 * b;
	
		float4 xTerms = float4( x_3, 
								x_2 * a, 
								x * a_2, 
								a_3 );
								
		float4 yTerms = float4( y_3, 
								y_2 * b, 
								y * b_2, 
								b_3 );
		
		return  ( 1.0f * mCubicWeights[0][0] * xTerms[0] * yTerms[0] ) + ( 1.0f * mCubicWeights[1][0] * xTerms[1] * yTerms[0] ) + (  4.0f * mCubicWeights[2][0] * xTerms[2] * yTerms[0] ) + ( 1.0f * mCubicWeights[3][0] * xTerms[3] * yTerms[0] ) +
				( 2.0f * mCubicWeights[0][1] * xTerms[0] * yTerms[1] ) + ( 4.0f * mCubicWeights[1][1] * xTerms[1] * yTerms[1] ) + (  8.0f * mCubicWeights[2][1] * xTerms[2] * yTerms[1] ) + ( 2.0f * mCubicWeights[3][1] * xTerms[3] * yTerms[1] ) +
				( 4.0f * mCubicWeights[0][2] * xTerms[0] * yTerms[2] ) + ( 8.0f * mCubicWeights[1][2] * xTerms[1] * yTerms[2] ) + ( 16.0f * mCubicWeights[2][2] * xTerms[2] * yTerms[2] ) + ( 4.0f * mCubicWeights[3][2] * xTerms[3] * yTerms[2] ) +
				( 1.0f * mCubicWeights[0][3] * xTerms[0] * yTerms[3] ) + ( 2.0f * mCubicWeights[1][3] * xTerms[1] * yTerms[3] ) + (  4.0f * mCubicWeights[2][3] * xTerms[2] * yTerms[3] ) + ( 1.0f * mCubicWeights[3][3] * xTerms[3] * yTerms[3] );
		
	}



//-----------------------------------------------------------------------------
// The main function for this shader
// The incoming positions will be in the range [-0.5 to +0.5]
// They will need to be offset accordingly in this shader..
//-----------------------------------------------------------------------------
VS_OUTPUT Cubic( in float2 vPosition : POSITION )
	{

		// Create some storage for the output
		VS_OUTPUT output = ( VS_OUTPUT )0;
		
		// Compute the correct height here...
		// Note: Switch between 'ComputeHeight1' and 'ComputeHeight2'...
		float height = ComputeHeight1( vPosition.x + 0.5f, vPosition.y + 0.5f );
		
		// Transform the output position by the correct matrices
		output.Position = mul( float4( vPosition.x, height, vPosition.y, 1.0f ), mWorldViewProj );
		
		// Output a gradient colour based on the height.
		// Start at black for the lowest points, red in the middle, green at the peaks:	
		float lowRange		= saturate( height + 1.0f );
		float highRange		= saturate( height );
		output.Diffuse		= float4(	
										lowRange - highRange, 
										highRange, 
										0.0f, 
										1.0f 
									);
		
		return output;
		
	}

