%
% Build the MEX pesq_itu 
%
%**************************************************************************
%	Copyright (C) CLEAR 2008
%   Version: 
%   Author:     Nick Gaubitch
%   Date:       01 Aug 2008
%**************************************************************************

Files = [   'pesqmain.c ' ...
            'dsp.c ' ...
            'pesqmod.c ' ...
            'pesqio.c ' ...
            'pesqdsp.c '];

opdir = './';
opfile = 'pesq_itu';

eval( ['mex -outdir ' opdir ' -output ' opfile ' ' Files])