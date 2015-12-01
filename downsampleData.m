function [ DataStructDs ] = downsampleData( DataStruct, targetFs )
%DOWNSAMPLEDATA downsamples data in given data struct
%   Parameters:
%       dataStruct (struct)
%           struct containing data to be downsampled
%       targetFs (int)
%           target sampling frequency after downsampling
%   Returns:
%       dataStructDs (struct)
%           Struct containing downsampled data and correctly adapted
%           samplestamps and fs information
%
% Author: Johann Roth
% Date: 26.11.2015

    DataStructDs = DataStruct;

    for signalName = [{'Bp'},...
                  {'PpgClip'},...
                  {'PpgCuff'}]

        factor = DataStruct.Signals.(char(signalName)).fs/targetFs;
        DataStructDs.Signals.(char(signalName)).data = ...
            decimate(DataStruct.Signals.(char(signalName)).data,factor,'fir');
        DataStructDs.Signals.(char(signalName)).fs = targetFs;
    end

    for stimulationMode = [{'AV'},...
                           {'VV'}]

        factor = DataStruct.StimulationModes.(char(stimulationMode)).fs/targetFs;
        DataStructDs.StimulationModes.(char(stimulationMode)).samplestamp = ...
            round(DataStruct.StimulationModes.(char(stimulationMode)).samplestamp/factor);
        DataStructDs.StimulationModes.(char(stimulationMode)).fs = targetFs;
    end

    for bsValue = [   {'BpDiastolic'},...
                      {'BpMean'},...
                      {'BpSystolic'},...
                      {'CardiacOutput'},...
                      {'Heartrate'},...
                      {'Lvet'},...
                      {'MaximumSlope'},...
                      {'PulseInterval'},...
                      {'StrokeVolume'},...
                      {'Tpr'}]
        factor = DataStruct.BsValues.(char(bsValue)).fs/targetFs;
        DataStructDs.BsValues.(char(bsValue)).samplestamp = ...
            round(DataStruct.BsValues.(char(bsValue)).samplestamp/factor);
        DataStructDs.BsValues.(char(bsValue)).fs = targetFs;
    end

    for beatDetection = [{'BsBp'},...
                         {'PpgCuff'},...
                         {'PpgClip'}]

        factor = DataStruct.BeatDetections.(char(beatDetection)).fs/targetFs;
        DataStructDs.BeatDetections.(char(beatDetection)).samplestamp = ...
            round(DataStruct.BeatDetections.(char(beatDetection)).samplestamp/factor);
        DataStructDs.BeatDetections.(char(beatDetection)).fs = targetFs;
    end

end

