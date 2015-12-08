function [ DataStructFiltered ] = filterPowerline( DataStruct )
%FILTERPOWERLINE removes powerline frequency from data struct
% Removing powerline frequency
%   Parameters:
%       dataStruct (struct)
%           struct containing data to be filtered
%   Returns:
%       dataStructFiltered (struct)
%           Struct containing filtered data
%
% Author: Johann Roth
% Date: 08.12.2015
    DataStructFiltered = DataStruct;
    powerline = 50; %Hz
    fs = DataStruct.Signals.Bp.fs;
    Nfir = 2;

    for signalName = [{'Bp'},...
                  {'PpgClip'},...
                  {'PpgCuff'}]

        d = designfilt('bandstopiir','FilterOrder',Nfir, ...
               'HalfPowerFrequency1',powerline-2,'HalfPowerFrequency2',powerline+2, ...
               'DesignMethod','butter','SampleRate',fs);
        DataStructFiltered.Signals.(char(signalName)).data = ...
            filtfilt(d,DataStruct.Signals.(char(signalName)).data);
    end
end

