function [ slope ] = getDerivative( beat )
%GETDERIVATIVE returns the first derivative of beat (slope)
%   Parameters:
%       beat (vector [Lx1])
%           single beat with a length of L samples
%       fs (scalar)
%           sampling frequency (needed for calculating width in ms)
%   Returns:
%       slope (vector [Lx1])
%           first derivative of the beat
%
% Author: Johann Roth
% Date: 15.12.2015

if isnan(beat(1))
    slope = NaN(length(beat)*2,1);
else
    df = designfilt('differentiatorfir','FilterOrder',20,...
        'PassbandFrequency',20,'StopbandFrequency',30,...
        'SampleRate',200);
    % hfvt = fvtool(df,[1 -1],1,'MagnitudeDisplay','zero-phase','Fs',200);
    % legend(hfvt,'50th order FIR differentiator','Response of diff function');
    
    D = mean(grpdelay(df)); % filter delay
    slope = filter(df,[beat; zeros(D,1)]);
    slope = slope(D+1:end);
    
    %     slope = zeros(length(beat),1);
    %
    %     for i = 1:length(beat)
    %         localSlope = zeros(filterOrder*2 + 1,1);
    %         for iSample = -fix(filterOrder/2) : fix(filterOrder/2)
    %             if ((i + iSample) < 1) || ((i+iSample+1) > length(beat))
    %                 localSlope(iSample + fix(filterOrder/2)+1) = 0;
    %             else
    %                 localSlope(iSample + fix(filterOrder/2)+1) = beat(i+iSample+1)-beat(i+iSample);
    %             end
    %         end
    %         slope(i) = mean(localSlope);
    %     end
end

end

