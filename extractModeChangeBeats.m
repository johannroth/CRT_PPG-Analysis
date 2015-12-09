function [ output_args ] = extractModeChangeBeats( ModeAV, ModeVV, Data, Metadata, iPatient )
%EXTRACTMODECHANGEBEATS analyses mode changes and beat detections and
% returns 'good' beats (i.e. beats that are not excluded) sorted by
% stimulation mode, change to or from a reference mode. For each mode there
% are 3 changes each for change to and from reference mode.
%   Parameters:
%       signal (vector [Nx1])
%           vector containing the signal (length N samples)
%       samplestamps (vector [Mx1])
%           stamps of detected beats (amount M of detected beats)
%       fs (double)
%           sample frequency of the given signal
%       heartrate (double)
%           expected heartrate in signal (determins the length of a beat)
%       removeDrift (bool)
%           bool to specify if baseline and drift should be removed
%   Returns:
%       beats (matrix [LxM])
%           matrix containing single beats (every column is a single beat),
%           length L of a beat is calculated from expected heart rate
%
% Author: Johann Roth
% Date: 07.12.2015



% Parameters have to be checked and description has to be updated!!!!