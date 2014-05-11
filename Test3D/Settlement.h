//
//  Settlement.h
//  Test3D
//
//  Created by Jose Lopes on 03/05/2014.
//  Copyright (c) 2014 Tom Berry. All rights reserved.
//

#ifndef __Test3D__Settlement__
#define __Test3D__Settlement__

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#include "glm/glm.hpp"


#include "Shader.h"

class CTerrain;
class CSettlement
{
public:
    static const int SURPLUS_FOOD_DIV = 2;
    static const int NUM_PER_HOUSE = 1;
    
    CSettlement();
    
    void Init(CTerrain *pTerrain);
    void Update();
    void Draw(glm::mat3 &normals, glm::mat4 &viewProj);
    
    int m_population;
    int m_food;
    int m_capacity;
    int m_foodProductionRate;
    
    glm::vec3 m_pos;
    
    CTerrain *m_pTerrain;
    
    //--- Rendering
    unsigned int m_vertexArray;
    unsigned int m_vertexBuffer;
    Shader *m_pShader;
};

#endif /* defined(__Test3D__Settlement__) */
