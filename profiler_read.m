%% IC Profiler read data
% this function will read in the raw output from the Sun Nuclear IC
% Profiler to arrays of chamber readings along the x and y axes, as well as
% the two diagonals.
% Written by Daniel Alexander, 2019

function [x, y, posDiag, negDiag] = profiler_read(pathname)
% Input
%   pathname    - string containing path to ASCII output from IC profiler
%                 software (.txt format)
%
% Outputs
%   x, y, posDiag, negDiag are each 65x2 tables with position and normalized IC signal as columns          

    rawOutput = readmatrix(pathname);

    yIndex  = (1:1:65)';
    xIndex  = [1:1:31, 33, 35:1:65]'; % x direction (and diagonals) are missing detectors adjecent to zero 
    
    x       = zeros(65,2);
    xRaw    = rawOutput(1:63,2);
    x(:,1)  = -16:.5:16;
    x(:,2)  = interp1(xIndex, xRaw, yIndex); % interpolate so all are 65x1
    
    y       = rawOutput(65:129, 1:2);

    posDiag         = zeros(65,2);
    posDiagRaw      = rawOutput(131:193,2);
    posDiag(:,1)    = -16*sqrt(2):sqrt(2)/2:16*sqrt(2); % diagonal spacing
    posDiag(:,2)    = interp1(xIndex, posDiagRaw, yIndex); % interpolate so all are 65x1
       
    negDiag         = zeros(65,2);
    negDiagRaw      = rawOutput(195:257,2);
    negDiag(:,1)    = -16*sqrt(2):sqrt(2)/2:16*sqrt(2); % diagonal spacing
    negDiag(:,2)    = interp1(xIndex, negDiagRaw, yIndex); % interpolate so all are 65x1
    clearvars rawOutput xIndex yIndex xRaw posDiagRaw negDiagRaw
    
    x       = array2table(x, 'VariableNames',{'Position (cm)', 'Signal'});
    y       = array2table(y, 'VariableNames',{'Position (cm)', 'Signal'});
    posDiag = array2table(posDiag, 'VariableNames',{'Position (cm)', 'Signal'});
    negDiag = array2table(negDiag, 'VariableNames',{'Position (cm)', 'Signal'});
end


