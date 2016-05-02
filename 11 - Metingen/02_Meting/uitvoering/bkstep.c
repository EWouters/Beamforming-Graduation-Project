// Wrapper for B&K 5997 Turntable controller
// using NI USB->GPIB dongle
// compile with mex('bkstep.c','***/gpib-32.obj');
// include ni4882.h in bkstep.c directory
//
// Written and tested by Marcel Korver, 2010-05-31
//
// Note: all commands are clockwise, the device anti-clockwise
// --> the commands are converted to correct, clockwise coordinates
// or directions

//////////////
// INCLUDES //
//////////////
#include <mex.h>

#include <math.h>
#include <string.h>
//#include <windows.h>
#include "matrix.h"

#include "ni4882.h"

/////////////////
// DEFINITIONS //
/////////////////
#define     FUNC_NONE       0
#define     FUNC_INIT       1
#define     FUNC_ZERO       2
#define     FUNC_TURN_REL   3
#define     FUNC_TURN_ABS   4
#define     FUNC_CONT       5
#define     FUNC_ACC        6
#define     FUNC_MAX360     7

#define     ERR_NONE        0
#define     ERR_NOT_RECOG   1
#define     ERR_NO_CONNEC   2
#define     ERR_NOT_STOPPED 3

//////////////
// FUNCTION //
//////////////
void mexFunction(int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[])
{
    // init vars
    mxArray *inData;
    int     inLength;    
    char    *inputString;
    
    char    command[50];
    
    int     acceleration;
    int     relative;
    int     absolute;
    int     absolute_conv;
    double  continuous;
    int     cont_status;
    int     max360_status;
    
    double  *outputError,*outputValue;
    
    int     value = 0;
    int     error = ERR_NONE;
    int     process = FUNC_NONE;
    
    int     bk5997 = 0;
    
    ///////////////////////////////////////////////////////////////////////
    // check in- and outputs
    
    // check for number of lhs (output) arguments
    // should be at least one
//    if(nlhs < 1)
 //   {
 //       mexPrintf("Too few output arguments specified\n");
 //       return;
//    }
    
    // check for number of rhs (input) arguments
    // should be at least one
    if(nrhs < 1)
    {
        mexPrintf("Too few input arguments specified\n");
        return;
    }
    
    // check for valid input commands
    inData = prhs[0];                                // copy input pointer 1
    inLength = mxGetN(inData)+1;                     // get length
    inputString = mxCalloc(inLength,sizeof(char));   // allocate memory
    mxGetString(inData,inputString,inLength);        // get string
    
    if(strcmp(inputString,"init") == 0)
    {
        process = FUNC_INIT;
    }
    else if(strcmp(inputString,"set zero") == 0)
    {
        process = FUNC_ZERO;
    }
    else if(strcmp(inputString,"turn relative") == 0)
    {
        if(nrhs < 2)    mexPrintf("Too few input arguments specified for [%s] command \n",inputString);
        else            process = FUNC_TURN_REL;
    }
    else if(strcmp(inputString,"turn absolute") == 0)
    {
        if(nrhs < 2)    mexPrintf("Too few input arguments specified for [%s] command \n",inputString);
        else            process = FUNC_TURN_ABS;
    }
    else if(strcmp(inputString,"turn continuous") == 0)
    {
        if(nrhs < 3)    mexPrintf("Too few input arguments specified for [%s] command \n",inputString);
        else            process = FUNC_CONT;
    }
    else if(strcmp(inputString,"acceleration") == 0)
    {
        if(nrhs < 2)    mexPrintf("Too few input arguments specified for [%s] command \n",inputString);
        else            process = FUNC_ACC;
    }
    else if(strcmp(inputString,"max 360") == 0)
    {
        if(nrhs < 2)    mexPrintf("Too few input arguments specified for [%s] command \n",inputString);
        else            process = FUNC_MAX360;
    }
    else
    {
        mexPrintf("Command [%s] not recognized\n",inputString);
    }
    
    ///////////////////////////////////////////////////////////////////////
    // process commands
    switch(process)
    {
        case FUNC_NONE:
            //mexPrintf("func_none\n");
            error = ERR_NOT_RECOG;
            break;
            
        case FUNC_INIT:
            //mexPrintf("func_init\n");
            
            // gpib
            bk5997 = ibdev(0,10,0,T30s,1,0);
            if(bk5997 < 0)
            {
                mexPrintf("Could not connect with B&K5997\n");
                error = ERR_NO_CONNEC;
                break;
            }
            ibclr(bk5997);
            ibwrt(bk5997,"REN",3L);
            ibonl(bk5997, 0);
            
            // output 
            value = 0;
            
            break;
        
        case FUNC_ZERO:
            //mexPrintf("func_zero\n");
            
            // gpib
            bk5997 = ibdev(0,10,0,T30s,1,0);
            if(bk5997 < 0)
            {
                mexPrintf("Could not connect with B&K5997\n");
                error = ERR_NO_CONNEC;
                break;
            }
            ibwrt(bk5997,"SET 0",5L);
            ibonl(bk5997,0);
            
            // output 
            value = 0;
            
            break;
            
        case FUNC_ACC:
            //mexPrintf("func_acc\n");
            
            // get input value and prepare string
            inData = prhs[1];
            acceleration = (int)(mxGetScalar(inData));
            if(acceleration < 1) acceleration = 1;
            if(acceleration > 10) acceleration = 10;
            sprintf(command,"ACC. %d",acceleration);
            
            // gpib
            bk5997 = ibdev(0,10,0,T30s,1,0);
            if(bk5997 < 0)
            {
                mexPrintf("Could not connect with B&K5997\n");
                error = ERR_NO_CONNEC;
                break;
            }
            ibwrt(bk5997,command,strlen(command));
            ibonl(bk5997,0);
            
            // output 
            value = (double)acceleration;
            
            break;
            
        case FUNC_TURN_REL:
            //mexPrintf("func_turn_rel\n");
            
            // get input value and prepare string
            inData = prhs[1];
            relative = -(int)(mxGetScalar(inData));
            if(relative < -360) relative = -360;
            if(relative > 360) relative = 360;
            sprintf(command,"TURN_REL %d",relative);
            
            // gpib
            bk5997 = ibdev(0,10,0,T30s,1,0);
            if(bk5997 < 0)
            {
                mexPrintf("Could not connect with B&K5997\n");
                error = ERR_NO_CONNEC;
                break;
            }
            ibwrt(bk5997,command,strlen(command));
            ibwrt(bk5997,"START",5L);
            ibwait(bk5997,TIMO|RQS);
            if (ibsta&(ERR|TIMO))   error = ERR_NOT_STOPPED;
            ibonl(bk5997,0);
            
            // output 
            value = -(double)relative;
            
            break;
            
        case FUNC_TURN_ABS:
            //mexPrintf("func_turn_abs\n");
            
            // get input value and prepare string
            inData = prhs[1];
            absolute = (int)(mxGetScalar(inData));
            absolute = absolute % 360;
            absolute_conv = 360 - absolute;
            sprintf(command,"TURN_ABS %d",absolute_conv);
            
            // gpib
            bk5997 = ibdev(0,10,0,T30s,1,0);
            if(bk5997 < 0)
            {
                mexPrintf("Could not connect with B&K5997\n");
                error = ERR_NO_CONNEC;
                break;
            }
            ibwrt(bk5997,command,strlen(command));
            ibwrt(bk5997,"START",5L);
            ibwait(bk5997,TIMO|RQS);
            ibonl(bk5997,0);
            
            // output 
            value = (double)absolute;
            
            break;
            
        case FUNC_CONT:
            //mexPrintf("func_cont\n");
            
            // get input values and prepare string
            inData = prhs[1];
            continuous = -(double)(mxGetScalar(inData));
            if(continuous < 0)
            {
                if(continuous > -22.7) continuous = -22.7;
                if(continuous < -720.0) continuous = -720.0;
            }
            else
            {
                if(continuous < 22.7) continuous = 22.7;
                if(continuous > 720.0) continuous = 720.0;
            }
            sprintf(command,"CONT. %.1f",continuous);
            inData = prhs[2];
            cont_status = (int)(mxGetScalar(inData));
                       
            // gpib
            bk5997 = ibdev(0,10,0,T30s,1,0);
            if(bk5997 < 0)
            {
                mexPrintf("Could not connect with B&K5997\n");
                error = ERR_NO_CONNEC;
                break;
            }
            ibwrt(bk5997,command,strlen(command));
            if(cont_status == 0)    ibwrt(bk5997,"STOP",4L);
            else                    ibwrt(bk5997,"START",5L);
            ibonl(bk5997,0);
            
            // output 
            if(cont_status == 0)    value = 0;
            else                    value = -(double)continuous;
                        
            break;
            
        case FUNC_MAX360:
            //mexPrintf("func_max360\n");
            
            // get input values and prepare string
            inData = prhs[1];
            max360_status = (int)(mxGetScalar(inData));
            if(max360_status == 0)
            {
                sprintf(command,"MAX_360 OFF\n");
            }
            else
            {
                sprintf(command,"MAX_360 ON\n");
            }
            
            // gpib
            bk5997 = ibdev(0,10,0,T30s,1,0);
            if(bk5997 < 0)
            {
                mexPrintf("Could not connect with B&K5997\n");
                error = ERR_NO_CONNEC;
                break;
            }
            ibwrt(bk5997,command,strlen(command));
            ibonl(bk5997,0);
            
            // output 
            value = (double)max360_status;
            
            break;
    }
    
    ///////////////////////////////////////////////////////////////////////
    // process outputs and return
    plhs[0] = mxCreateDoubleScalar(error);
    plhs[1] = mxCreateDoubleScalar(value);   
        
    return;
}
