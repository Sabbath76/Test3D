//
//  Settlement.cpp
//  Test3D
//
//  Created by Jose Lopes on 03/05/2014.
//  Copyright (c) 2014 Tom Berry. All rights reserved.
//

#include "Settlement.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
//#define GL_GLEXT_PROTOTYPES

//#include <OpenGLES/ES2/glext.h>
//#include <GLKit/GLKit.h>

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"
#include "glm/gtc/type_ptr.hpp"

#include "terrain.h"

float gCubeVertexData2[216] =
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


CSettlement::CSettlement()
:
m_population(2),
m_capacity(2),
m_food(2),
m_foodProductionRate(10)
{
}

void CSettlement::Init(CTerrain *pTerrain)
{
    m_pTerrain = pTerrain;
 /*   PFNGLGENVERTEXARRAYSOESPROC glGenVertexArraysOES;
    PFNGLBINDVERTEXARRAYOESPROC glBindVertexArrayOES;
    PFNGLDELETEVERTEXARRAYSOESPROC glDeleteVertexArraysOES;
    PFNGLISVERTEXARRAYOESPROC glIsVertexArrayOES;
    
    glGenVertexArraysOES = (PFNGLGENVERTEXARRAYSOESPROC)eglGetProcAddress ( "glGenVertexArraysOES" );
    glBindVertexArrayOES = (PFNGLBINDVERTEXARRAYOESPROC)eglGetProcAddress ( "glBindVertexArrayOES" );
    glDeleteVertexArraysOES = (PFNGLDELETEVERTEXARRAYSOESPROC)eglGetProcAddress ( "glDeleteVertexArraysOES" );
    glIsVertexArrayOES = (PFNGLISVERTEXARRAYOESPROC)eglGetProcAddress ( "glIsVertexArrayOES" );
*/
    m_pShader = new Shader("Shader.vsh", "Shader.fsh");
    
    if(!m_pShader->compileAndLink())
    {
//        NSLog(@"Encountered problems when loading shader, application will crash...");
    }

    
    glGenVertexArraysOES(1, &m_vertexArray);
    glBindVertexArrayOES(m_vertexArray);

    glGenBuffers(1, &m_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, m_vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData2), gCubeVertexData2, GL_STATIC_DRAW);
    
    int attribPos    = m_pShader->getAttribId(ATTRIB_POSITION);
    int attribNormal = m_pShader->getAttribId(ATTRIB_NORMAL);
    glEnableVertexAttribArray(attribPos);
    glVertexAttribPointer(attribPos, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(attribNormal);
    glVertexAttribPointer(attribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    glBindVertexArrayOES(0);
    
    m_pos.x = 1.5;
    m_pos.y = 1.5;
    m_pos.z = 0.0;
}

void CSettlement::Update()
{
    m_food += m_foodProductionRate;
    
    m_food -= m_population;
    if (m_food < 0)
    {
        //--- Starvation
        m_population += m_food;
        m_food = 0;
    }
    else
    {
        //--- Reproduction
        int surplus = m_food - m_population;
        int children = surplus / SURPLUS_FOOD_DIV;
        if (children > m_population/2)
        {
            children = m_population/2;
        }
        m_population += children;
        if (m_population > m_capacity)
        {
            m_capacity = m_population;
        }
    }
}

void CSettlement::Draw(glm::mat3 &normals, glm::mat4 &viewProj)
{
    int numHouses    = m_capacity / NUM_PER_HOUSE;
    int numOccHouses = m_population / NUM_PER_HOUSE;
    
    glBindVertexArrayOES(m_vertexArray);
    glUseProgram(m_pShader->getProgram());
    glUniformMatrix3fv(m_pShader->getUniformId(UNIFORM_NORMAL_MATRIX), 1, 0, glm::value_ptr(normals));

    glm::vec3 housePos = m_pos;
    glm::vec3 inc(0.0f, 0.1f, 0.0f);
    glm::vec3 incs[4] = {glm::vec3(0.0f, 0.1f, 0.0f), glm::vec3(0.1f, 0.0f, 0.0f), glm::vec3(0.0f, -0.1f, 0.0f), glm::vec3(-0.1f, 0.0f, 0.0f)};
    int sideCount = 0;
    int sideMax = 1;
    int dir = 0;
    
    for (int i=0; i<numHouses; i++)
    {
        housePos.z = m_pTerrain->ComputeHeight(housePos.x, housePos.y);
        glm::mat4 modelMatrix = glm::scale(glm::translate(glm::mat4(1.0f), housePos), glm::vec3(0.05, 0.05, 0.2));
        
        glm::mat4 modelViewProjectionMatrix = viewProj * modelMatrix;
        glUniformMatrix4fv(m_pShader->getUniformId(UNIFORM_MODELVIEWPROJECTION_MATRIX), 1, 0, glm::value_ptr(modelViewProjectionMatrix));
        
        glDrawArrays(GL_TRIANGLES, 0, 36);
        
        sideCount++;
        if(sideCount>=sideMax)
        {
            sideCount = 0;
            sideMax += dir%2;
            dir = (dir+1)%4;
        }
        housePos+=incs[dir];
    }
}