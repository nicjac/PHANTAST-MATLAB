/**************************************************************
 * Region shrinking for halo removal on phase contrast images
 * C++ port of computationally intensive sections of the MATLAB 
 * code
 * By Nicolas Jaccard ( n.jaccard@ucl.ac.uk )
 * License: GPLv2
 * Version: 0.1
 * 
 *
 * 23.07.2012 
 * - Changed dimension checks for target pixels so it considers pixels that are one pixel away from borders
 *   but starting pixels still have to _not_ be on the borders
 * 
 *
 * 21.07.2012
 * - Added an optional system (currently commented out) to prevent pixels to move onto other pixels being processed
 *************************************************************/

#include <string.h> /* needed for memcpy() */
#include "mex.h"
#include <vector>
using namespace std;

//nlhs	Number of expected mxArrays (Left Hand Side)
//plhs	Array of pointers to expected outputs
//nrhs	Number of inputs (Right Hand Side)
//prhs	Array of pointers to input data. The input data is read-only and should not be altered by your mexFunction .
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{  
    // Initialize variables
    
    // ****************
    // INPUT  VARIABLES
    // ****************
    unsigned short * pixelsToProcess = (unsigned short*)mxGetData(prhs[0]);
    double * gradientMap = mxGetPr(prhs[1]);
    double * projectionCones = mxGetPr(prhs[2]);
    bool * consideredAsStartingPointInput = (bool*)mxGetData(prhs[3]);
    double * directionOffsets = mxGetPr(prhs[4]);
    bool * binaryImage = (bool*)mxGetData(prhs[5]);
    
    // *************
    // TMP VARIABLES
    // *************
        
    // Number of pixels to process
    unsigned int nCoordinatePairs;
    nCoordinatePairs = mxGetDimensions(prhs[0])[0];
    
    // Get gradient dimensions
    unsigned short gradientRows;
    unsigned short gradientColumns;
    gradientRows = mxGetDimensions(prhs[1])[0];
    gradientColumns = mxGetDimensions(prhs[1])[1];
    
    // Get consideredStartingPoint dimensions
    unsigned short consideredStartingPointRows,consideredStartingPointColumns;
    consideredStartingPointRows = mxGetDimensions(prhs[3])[0];
    consideredStartingPointColumns = mxGetDimensions(prhs[3])[1];
    
    unsigned short currentPosition[2];
    unsigned short currentDirection;
    unsigned short currentDirectionCone[3];
    unsigned short directionOffset[2];
    unsigned short nextPosition[2];
    
    bool validPath;
    
    // Temp vector to hold values for toAddToQueue (both components)
    vector<unsigned short> toAddToQueueX(0);
    vector<unsigned short> toAddToQueueY(0);

    // Temp vector to hold values for toBeRemoved (both components)
    vector<unsigned short> toBeRemovedX(0);
    vector<unsigned short> toBeRemovedY(0);

    // ****************
    // OUTPUT VARIABLES
    // ****************
    //mwSize numEl= mxGetNumberOfElements(prhs[1]);
 
    bool *seedingPoints;
    seedingPoints = (bool*)mxCalloc(gradientRows*gradientColumns,sizeof(bool));
    
    // Creating a new array for output starting point logical matrix 
    plhs[0] = mxCreateLogicalMatrix(gradientRows, gradientColumns);
    bool *consideredAsStartingPoint =(bool*)mxGetPr(plhs[0]);
    // Get the number of bytes to copy by multiplying the number of elements in the input array by their size
    int bytesToCopy = mxGetNumberOfElements(prhs[3]) * mxGetElementSize(prhs[3]);
    // Copy the content
    memcpy(consideredAsStartingPoint,consideredAsStartingPointInput,bytesToCopy);
    
    // !! Rest of the output variables defined at the end
    
    //
    // START
    //
    //unsigned int nElements;
    //nElements = mxGetNumberOfElements(prhs[3]);
    
    // Initialize array
    //for (int i = 0; i < nElements; i++) {
    //     seedingPoints[i]=false;
    //}
    
    // Copy positions of pixels that are already part of the pixels to process.
    // The point of seedingPoints is to avoid pixels moving onto other starting pixels
    // as this is _not_ a valid move!
    //for (int i = 0; i < nCoordinatePairs; i++) {
    //    currentPosition[0] = pixelsToProcess[nCoordinatePairs*0+i];
    //    currentPosition[1] = pixelsToProcess[nCoordinatePairs*1+i];
    //    seedingPoints[gradientRows*(currentPosition[1]-1)+(currentPosition[0]-1)]=true;
    // }
    
    
    for ( int i = 0; i < nCoordinatePairs; i++) {
        
        validPath = false;

        currentPosition[0] = pixelsToProcess[nCoordinatePairs*0+i];
        currentPosition[1] = pixelsToProcess[nCoordinatePairs*1+i];
        //i = nrow * icol + irow; // 0-based

        currentDirection = gradientMap[gradientRows*(currentPosition[1]-1)+(currentPosition[0]-1)];

        // Get the direction cones
        currentDirectionCone[0] = projectionCones[8*0+(currentDirection-1)];
        currentDirectionCone[1] = projectionCones[8*1+(currentDirection-1)];
        currentDirectionCone[2] = projectionCones[8*2+(currentDirection-1)];

        if(!(consideredAsStartingPoint[consideredStartingPointRows*(currentPosition[1]-1)+(currentPosition[0]-1)]))
        {
            if((currentPosition[0] >1) & (currentPosition[1] >1) & (currentPosition[0] < gradientRows) & (currentPosition[1] < gradientColumns))
            {           
                consideredAsStartingPoint[consideredStartingPointRows*(currentPosition[1]-1)+(currentPosition[0]-1)] = true;

                for (int k =0; k < 3; k++) {
                    directionOffset[0] = directionOffsets[8*0+(currentDirectionCone[k]-1)];
                    directionOffset[1] = directionOffsets[8*1+(currentDirectionCone[k]-1)];

                    nextPosition[0] = currentPosition[0] + directionOffset[0];
                    nextPosition[1] = currentPosition[1] + directionOffset[1];
    
                    // Added seeding points stuff to prevent pixels moving to other starting points!!
                    //if((binaryImage[gradientRows*(nextPosition[1]-1)+(nextPosition[0]-1)]==true) && (seedingPoints[gradientRows*(nextPosition[1]-1)+(nextPosition[0]-1)]==false))
                    if((binaryImage[gradientRows*(nextPosition[1]-1)+(nextPosition[0]-1)]==true))
                    {

                        if((nextPosition[0] >=1) & (nextPosition[1] >=1) & (nextPosition[0] <= gradientRows) & (nextPosition[1] <= gradientColumns))
                        {
                            validPath = true;

                            toAddToQueueX.push_back((unsigned short)nextPosition[0]);
                            toAddToQueueY.push_back((unsigned short)nextPosition[1]);
                        }
                    }  
                }
            }
        }

        if(validPath) {  
            toBeRemovedX.push_back((unsigned short) currentPosition[0]);
            toBeRemovedY.push_back((unsigned short) currentPosition[1]);
        }
    }

    //
    // Create output matrices
    //
    
    // toAddToQueue (both components)
    plhs[1] = mxCreateNumericMatrix(toAddToQueueX.size(),1,mxUINT16_CLASS,mxREAL);
    unsigned short * toAddToQueueXout  =(unsigned short*)mxGetData(plhs[1]);
    plhs[2] = mxCreateNumericMatrix(toAddToQueueY.size(),1,mxUINT16_CLASS,mxREAL);
    unsigned short * toAddToQueueYout  =(unsigned short*)mxGetData(plhs[2]);
        
    // toBeRemoved (both components)
    plhs[3] = mxCreateNumericMatrix(toBeRemovedX.size(),1,mxUINT16_CLASS,mxREAL);
    unsigned short * toBeRemovedXout  =(unsigned short*)mxGetData(plhs[3]);
    plhs[4] = mxCreateNumericMatrix(toBeRemovedY.size(),1,mxUINT16_CLASS,mxREAL);
    unsigned short * toBeRemovedYout  =(unsigned short*)mxGetData(plhs[4]);
    
    // Copy content from temp vector variables to output arrays
    memcpy(toAddToQueueXout, &toAddToQueueX[0], sizeof( unsigned short ) * toAddToQueueX.size() );
    memcpy(toAddToQueueYout, &toAddToQueueY[0], sizeof( unsigned short ) * toAddToQueueY.size() );
    memcpy(toBeRemovedXout, &toBeRemovedX[0], sizeof( unsigned short ) * toBeRemovedX.size() );
    memcpy(toBeRemovedYout, &toBeRemovedY[0], sizeof( unsigned short ) * toBeRemovedY.size() );
}
        