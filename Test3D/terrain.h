//
//  terrian.h
//  Test3D
//
//  Created by Jose Lopes on 03/05/2014.
//  Copyright (c) 2014 Tom Berry. All rights reserved.
//

#ifndef __Test3D__terrian__
#define __Test3D__terrian__

class CTerrain
{
public:
    CTerrain();
    
    float ComputeHeight( float worldX, float worldY ) const;

    
    float *m_heights;
    int m_xSize;
    int m_ySize;
};

#endif /* defined(__Test3D__terrian__) */
