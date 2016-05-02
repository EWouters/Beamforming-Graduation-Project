/*
Program     : Room Impulse Response Generator
 
Description : Function for simulating the impulse response of a specified
              room using the image method [1,2].
 
              [1] J.B. Allen and D.A. Berkley,
              Image method for efficiently simulating small-room Acoustics,
              Journal Acoustic Society of America, 65(4), April 1979, p 943.
 
              [2] P.M. Peterson,
              Simulating the response of multiple microphones to a single
              acoustic source in a reverberant room, Journal Acoustic
              Society of America, 80(5), November 1986.
 
Author      : dr.ir. E.A.P. Habets (ehabets@dereverberation.org)
modified    : Jorge Martinez, Msc. (J.A.MartinezCastaneda@TuDelft.nl)

Original Version   : 1.8.20080713
Last Modification  : 20090427

History     : 1.0.20030606 Initial version
              1.1.20040803 + Microphone directivity
                           + Improved phase accuracy [2]
              1.2.20040312 + Reflection order
              1.3.20050930 + Reverberation Time
              1.4.20051114 + Supports multi-channels
              1.5.20051116 + High-pass filter [1]
                           + Microphone directivity control
              1.6.20060327 + Minor improvements
              1.7.20060531 + Minor improvements
              1.8.20080713 + Minor improvements (Compiled using Matlab R2008a)
Modifications:
		20080806   + Supports multiple sound sources. Delivers the impulse 
                     responses in column vectors.
        20081212   + BUG FIX (Direct Path erasing problem).
                   + Hability use either the original version of Allen & Berkley 
                     or the enhanced LPF-based version from Peterson.
        20090427   + The LPF hanning window length can be specified.
                   + The room dimension now can be specified with a 1 X 3 boolean
                     vector which controls the projection of the space on 
                     any of the Cartesian coordinates.


                   

Copyright (C) 2003-2008 E.A.P. Habets, The Netherlands.
 
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
 
You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

#define _USE_MATH_DEFINES

#include "matrix.h"
#include "mex.h"
#include "math.h"

#define ROUND(x) ((x)>=0?(long)((x)+0.5):(long)((x)-0.5))

double sinc(double x)
{
	if (x == 0)
		return(1.);
	else
		return(sin(x)/x);
}

double sim_microphone(double x, double y, double angle, char* mtype)
{
	double a, refl_theta, P, PG;

	refl_theta = atan2(y,x) - angle;

	// Polar Pattern         P       PG
	// ------------------------------------
	// Omnidirectional       1       0
	// Subcardioid           0.75    0.25
	// Cardioid              0.5     0.5
	// Hypercardioid         0.25    0.75
	// Bidirectional         0       1

	switch(mtype[0])
	{
	case 'o':
		P = 1;
		PG = 0;
		break;
	case 's':
		P = 0.75;
		PG = 0.25;
		break;
	case 'c':
		P = 0.5;
		PG = 0.5;
		break;
	case 'h':
		P = 0.25;
		PG = 0.75;
		break;
	case 'b':
		P = 0;
		PG = 1;
		break;
	default:
		P = 1;
		PG = 0;
		break;
	};

	a = P + PG * cos(refl_theta);

	return a;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if (nrhs == 0)
	{
		mexPrintf("--------------------------------------------------------------------\n"
			"| Room Impulse Response Generator                                  |\n"
			"|                                                                  |\n"
			"| Function for simulating the impulse response of a specified      |\n"
			"| room using the image method [1,2].                               |\n"
			"|                                                                  |\n"
			"| Author    : dr.ir. Emanuel Habets (ehabets@dereverberation.org)  |\n"
			"| modified  :                                                      |\n"
			"|         Jorge Martinez, Msc. (J.A.MartinezCastaneda@TuDelft.nl)  |\n"
			"| Original Version   : 1.8.20080713                                |\n"
			"| Last modification  : 20090427                                    |\n"
			"| Copyright (C) 2003-2008 E.A.P. Habets, The Netherlands.          |\n"
			"|                                                                  |\n"
			"| [1] J.B. Allen and D.A. Berkley,                                 |\n"
			"|     Image method for efficiently simulating small-room Acoustics,|\n"
			"|     Journal Acoustic Society of America,                         |\n"
			"|     65(4), April 1979, p 943.                                    |\n"
			"|                                                                  |\n"
			"| [2] P.M. Peterson,                                               |\n"
			"|     Simulating the response of multiple microphones to a single  |\n"
			"|     acoustic source in a reverberant room, Journal Acoustic      |\n"
			"|     Society of America, 80(5), November 1986.                    |\n"
			"--------------------------------------------------------------------\n\n"
			"function [h, beta_hat] = rir_generator(c, fs, r, s, L, beta, nsample, mtype,"
			" order, dim, orientation, hp_filter, lp_filter, window_l);\n\n"
			"Input parameters:\n"
			" c  = sound velocity in m/s.\n"
			" fs = sampling frequency in Hz.\n"
			" r  = M x 3 array specifying the (x,y,z) coordinates of the receiver(s) in m.\n"
			" s  = N x 3 vector specifying the (x,y,z) coordinates of the source(s) in m.\n"
			" L  = 1 x 3 vector specifying the room dimensions (x,y,z) in m.\n"
			" beta = 1 x 6 vector specifying the reflection coefficients"
			" [beta_x1 beta_x2 beta_y1 beta_y2\n"
			"      beta_z1 beta_z2] or beta = Reverberation Time (T_60) in seconds.\n"
			" nsample = number of samples to calculate, default is T_60*fs.\n"
			" mtype = [omnidirectional, subcardioid, cardioid, hypercardioid, bidirectional],"
			" default is omnidirectional.\n"
			" order = reflection order, default is -1, i.e. maximum order).\n"
			" dim = room dimension. 1 x 3 boolean vector which specifies if the room space"
            " is defined over the corresponding Cartesian coordinate ([X Y Z]).\n"
			" orientation = specifies the angle (in rad) in which the microphone is pointed,"
			" default is 0.\n"
			" hp_filter = use 'false' to disable high-pass filter, the high-pass filter is"
			" enabled by default.\n"
            " lp_filter = use 'false' to disable low-pass filtering of the pulses and use"
            " rounding of the arrival time in the impulse responses (Allen & Berkley) original"
            " algorithm, the low_pass filter is enabled by default.\n"
            " window_l = Time length (in  seconds) of the Hanning window used in the LPF.\n\n"
			"Output parameters:\n"
			" h = nsample X M X N matrix containing the calculated room impulse response(s).\n"
			" beta_hat = In case a reverberation time is specified as an input parameter the "
			"corresponding reflection coefficient is returned.\n\n");
		return;
	}
	// Check for proper number of arguments
	if (nrhs < 6)
		mexErrMsgTxt("Error: There are at least six input parameters required.");
	if (nrhs > 14)
		mexErrMsgTxt("Error: Too many input arguments.");
	if (nlhs > 2)
		mexErrMsgTxt("Error: Too many output arguments.");

	// Check for proper arguments
	if (!(mxGetN(prhs[0])==1) || !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]))
		mexErrMsgTxt("Invalid input arguments!");
	if (!(mxGetN(prhs[1])==1) || !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]))
		mexErrMsgTxt("Invalid input arguments!");
	if (!(mxGetN(prhs[2])==3) || !mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]))
		mexErrMsgTxt("Invalid input arguments!");
	if (!(mxGetN(prhs[3])==3) || !mxIsDouble(prhs[3]) || mxIsComplex(prhs[3]))
		mexErrMsgTxt("Invalid input arguments!");
	if (!(mxGetN(prhs[4])==3) || !mxIsDouble(prhs[4]) || mxIsComplex(prhs[4]))
		mexErrMsgTxt("Invalid input arguments!");
	if (!(mxGetN(prhs[5])==6 || mxGetN(prhs[5])==1) || !mxIsDouble(prhs[5]) || mxIsComplex(prhs[5]))
		mexErrMsgTxt("Invalid input arguments!");

	// Load parameters
	double          c = mxGetScalar(prhs[0]);
	double          fs = mxGetScalar(prhs[1]);
	const double*   rr = mxGetPr(prhs[2]);
	int             nr_of_mics = (int) mxGetM(prhs[2]);
	const double*   ss = mxGetPr(prhs[3]);
	int             nr_of_louds = (int) mxGetM(prhs[3]);
	const double*   LL = mxGetPr(prhs[4]);
	const double*   beta_ptr = mxGetPr(prhs[5]);
	double*         beta = new double[6];
	int             nsamples;
	char*           mtype;
	int             order;
	int             dim;
	double          angle;
	int             hp_filter;
    int             lp_filter;
	double          TR;
    double          Wl;
   	int*            dim_s = new int[3];
    
	plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
	double* beta_hat = mxGetPr(plhs[1]);
	beta_hat[0] = 0;

	// Reflection coefficients or Reverberation Time?
	if (mxGetN(prhs[5])==1)
	{
		double V = LL[0]*LL[1]*LL[2];
		double S = 2*(LL[0]*LL[2]+LL[1]*LL[2]+LL[0]*LL[1]);
		TR = beta_ptr[0];
		double alfa = 24*V*log(10.0)/(c*S*TR);
		if (alfa > 1)
			mexErrMsgTxt("Error: The reflection coefficients cannot be calculated using the current "
				"room parameters, i.e. room size and reverberation time.\n           Please "
				"specify the reflection coefficients or change the room parameters.");
		beta_hat[0] = sqrt(1-alfa);
		for (int i=0;i<6;i++)
			beta[i] = beta_hat[0];
	}
	else
	{
		for (int i=0;i<6;i++)
			beta[i] = beta_ptr[i];
	}

    // Time window length of the LPF (optional)
    if(nrhs > 13)
    {
        Wl = (double) mxGetScalar(prhs[13]);
    }
    else
    {
        Wl=0.008;   //8ms default.
    }
    //Low-pass filter for interaural preservation or shifted pulses? (optional)
    if(nrhs > 12)
    {
       lp_filter = (int) mxGetScalar(prhs[12]);
    }
    else
    {
       lp_filter = 1;
    }
	// High-pass filter (optional)
	if (nrhs > 11)
	{
		hp_filter = (int) mxGetScalar(prhs[11]);
	}
	else
	{
		hp_filter = 1;
	}

	// Microphone orientation (optional)
	if (nrhs > 10)
	{
		angle = (double) mxGetScalar(prhs[10]);
	}
	else
	{
		angle = 0;
	}

	// Room Dimension (optional)
	if (nrhs > 9)
	{
		if (!(mxGetN(prhs[9])==3) || !mxIsDouble(prhs[9]) || mxIsComplex(prhs[9]))
        	mexErrMsgTxt("Invalid input arguments!");
       	const double*   dim = mxGetPr(prhs[9]);
        
		
        if (dim[0] == 0)
		{
			beta[0] = 0;
			beta[1] = 0;
            dim_s[0] = 0;
		}
        else
        {
            dim_s[0] = 1;
        }
        
        if (dim[1] == 0)
		{
			beta[2] = 0;
			beta[3] = 0;
            dim_s[1] = 0;
		}
        else
        {
            dim_s[1] = 1;
        }

        if (dim[2] == 0)
		{
			beta[4] = 0;
			beta[5] = 0;
            dim_s[2] = 0;            
		}
        else
        {
            dim_s[2] = 1;
        }
    }
    else
    {
        dim_s[0] = 1;
        dim_s[1] = 1;
        dim_s[2] = 1;    
    }
	// Reflection order (optional)
	if (nrhs > 8 &&  mxIsEmpty(prhs[8]) == false)
	{
		order = (int) mxGetScalar(prhs[8]);
		if (order < -1)
			mexErrMsgTxt("Invalid input arguments!");
	}
	else
	{
		order = -1;
	}

	// Type of microphone (optional)
	if (nrhs > 7 &&  mxIsEmpty(prhs[7]) == false)
	{
		mtype = new char[mxGetN(prhs[7])+1];
		mxGetString(prhs[7], mtype, mxGetN(prhs[7])+1);
	}
	else
	{
		mtype = new char[1];
		mtype[0] = 'o';
	}

	// Number of samples (optional)
	if (nrhs > 6 &&  mxIsEmpty(prhs[6]) == false)
	{
		nsamples = (int) mxGetScalar(prhs[6]);
	}
	else
	{
		if (mxGetN(prhs[5])>1)
		{
			double V = LL[0]*LL[1]*LL[2];
			double S = 2*(LL[0]*LL[2]+LL[1]*LL[2]+LL[0]*LL[1]);
			double alpha = ((1-pow(beta[0],2))+(1-pow(beta[1],2)))*LL[0]*LL[2] +
				((1-pow(beta[2],2))+(1-pow(beta[3],2)))*LL[1]*LL[2] +
				((1-pow(beta[4],2))+(1-pow(beta[5],2)))*LL[0]*LL[1];
			TR = 24*log(10.0)*V/(c*alpha);
			if (TR < 0.128)
				TR = 0.128;
		}
		nsamples = (int) (TR * fs);
	}

	// Create output vector
	
	int dims_out_array[3]={nsamples,nr_of_mics,nr_of_louds};
	plhs[0] = mxCreateNumericArray(3,dims_out_array,mxDOUBLE_CLASS,mxREAL);
	double* imp = mxGetPr(plhs[0]);

	// Temporary variables and constants (high-pass filter)
	const double W = 2*M_PI*100/fs;
	const double R1 = exp(-W);
	const double R2 = R1;
	const double B1 = 2*R1*cos(W);
	const double B2 = -R1 * R1;
	const double A1 = -(1+R2);
	const double A2 = R2;
	double       X0, Y0, Y1, Y2;

	// Temporary variables and constants (image-method)
	const double Fc = 1;
	const int    Tw = (ROUND(Wl*fs) < 1) ? 1 : ROUND(Wl*fs);
	const double cTs = c/fs;
	double*      hanning_window = new double[Tw+1];
	double*      LPI = new double[Tw+1];
	double*      r = new double[3];
	double*      s = new double[3];
	double*      L = new double[3];
	double       hu[6];
	double       refl[3];
	double       dist;
	double       ll;
	double       strength;
	int          pos, fdist;
	int          n1,n2,n3;
	int          q, j, k;
	int          mx, my, mz;
	int          n;

	L[0] = LL[0]/cTs; L[1] = LL[1]/cTs; L[2] = LL[2]/cTs;

	// Hanning window
	for (n = 0 ; n < Tw+1 ; n++)
	{
		hanning_window[n] = 0.5 * (1 + cos(2*M_PI*(n+Tw/2)/Tw));
	}
	
	int abs_counter=0;

	for (int loud_nr = 0; loud_nr < nr_of_louds; loud_nr++ )	
	{	
		
			s[0] = ss[loud_nr + 0*nr_of_louds] / cTs;
			s[1] = ss[loud_nr + 1*nr_of_louds] / cTs;
			s[2] = ss[loud_nr + 2*nr_of_louds] / cTs;
        	
		for (int mic_nr = 0; mic_nr < nr_of_mics ; mic_nr++)
		{
			// [x_1 x_2 ... x_N y_1 y_2 ... y_N z_1 z_2 ... z_N]
			r[0] = rr[mic_nr + 0*nr_of_mics] / cTs;
			r[1] = rr[mic_nr + 1*nr_of_mics] / cTs;
			r[2] = rr[mic_nr + 2*nr_of_mics] / cTs;
	
			n1 = ceil(nsamples/(2*L[0]))*dim_s[0];
			n2 = ceil(nsamples/(2*L[1]))*dim_s[1];
			n3 = ceil(nsamples/(2*L[2]))*dim_s[2];
	
			// Generate room impulse response
			for (mx = -n1 ; mx <= n1 ; mx++)
			{
				hu[0] = 2*mx*L[0];
		
	
				for (my = -n2 ; my <= n2 ; my++)
				{
					hu[1] = 2*my*L[1];
	
					for (mz = -n3 ; mz <= n3 ; mz++)
					{
						hu[2] = 2*mz*L[2];
	
						for (q = 0 ; q <= 1*dim_s[0] ; q++)
						{
                            hu[3] = s[0] - r[0] + 2*q*r[0] + hu[0];
							refl[0] = pow(beta[0], abs(mx)) * pow(beta[1], abs(mx+q));
							
                            for (j = 0 ; j <= 1*dim_s[1] ; j++)
							{
								hu[4] = s[1] - r[1] + 2*j*r[1] + hu[1];
								refl[1] = pow(beta[2], abs(my)) * pow(beta[3], abs(my+j));
	
								for (k = 0 ; k <= 1*dim_s[2] ; k++)
								{
									hu[5] = s[2] - r[2] + 2*k*r[2] + hu[2];
									refl[2] = pow(beta[4],abs(mz)) * pow(beta[5], abs(mz+k));
	
									dist = sqrt(pow(hu[3], 2) + pow(hu[4], 2) + pow(hu[5], 2));
	
									fdist = (int) floor(dist);
									if (abs(2*mx+q)+abs(2*my+j)+abs(2*mz+k) <= order || order == -1)
									{
										if (fdist < nsamples)
										{
											
                                            //if ( mx == 0 && my == 0 && mz == 0 && q == 0 && j == 0 && k==0)
                                            //{
                                            //    mexPrintf("x: %f | y: %f | z: %f \n",refl[0],refl[1],refl[2]);
                                            //}
                                            
                                            strength = sim_microphone(hu[3], hu[4], angle, mtype)
												* refl[0]*refl[1]*refl[2]/(4*M_PI*dist*cTs);
	
                                            //if ( mx == 0 && my == 0 && mz == 0 && q == 0 && j == 0 && k==0)
                                            //{
                                            //    mexPrintf("str: %f | dist: %f | dist*cTs: %f \n",strength,dist,dist*cTs);
                                            //}
                                            
                                            
                                            
											if (lp_filter == 1)
                                            {
                                                for (n = 0 ; n < Tw+1 ; n++)
                                                    LPI[n] = hanning_window[n] * Fc * sinc( M_PI*Fc*(n-(dist-fdist)-(Tw/2)) );

                                                pos = fdist-(Tw/2);
                                                for (n = 0; n < Tw+1; n++)
                                                {    
                                                  if (pos+n >=0 && pos+n < nsamples)
                                                  {
                                                    //if ( mx == 0 && my == 0 && mz == 0)
                                                      imp[ abs_counter + (pos+n)] += strength * LPI[n];
                                                  }
                                                }
                                            }
                                            else
                                            {
                                                //if ( mx == 0 && my == 0 && mz == 0)
                                                imp[ abs_counter + fdist] += strength;
                                            }
										}
									}
								}
							}
						}
					}
				}
			}
	
			// 'Original' high-pass filter as proposed by Allen and Berkley.
			if (hp_filter == 1)
			{
				Y0 = 0;
				Y1 = 0;
				Y2 = 0;
				for (int idx = 0 ; idx < nsamples ; idx++)
				{
					X0 = imp[ abs_counter + idx];
					Y2 = Y1;
					Y1 = Y0;
					Y0 = B1*Y1 + B2*Y2 + X0;
					imp[ abs_counter + idx] = Y0 + A1*Y1 + A2*Y2;                    
				}
			}
			abs_counter+=nsamples;
		}
	}
}
