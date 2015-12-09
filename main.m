%% Main script for CRT PPG analysis
%
%
% Author: Johann Roth
% Date: 01.12.2015

clear;

patient = 1:6;

%% Loop through all patients (1-6)
for iPatient = patient
    fprintf(['Computing patient ' num2str(iPatient) '.\n']);
    patientId = ['Pt0' int2str(iPatient)];
    
    %% Import data
    % use existing imported data if available and not older than a day
    
    fprintf('..importing unisens data..\n');
    if exist(['../data/matlab/' patientId '/' patientId '_unisensImport.mat'],'file')
        Data = load(['../data/matlab/' patientId '/' patientId '_unisensImport.mat']);
        Data = Data.Data;
        if hours(datetime('now') - Data.imported) > 24
            clearvars Data;
            [Data.Signals, Data.StimulationModes, Data.BsValues, Data.BeatDetections] = extractFromUnisens(iPatient);
            Data.imported = datetime('now');
            Data.Metadata = importPatientMetadata('..\data\raw\Patient_data.xlsx');
            save(['../data/matlab/' patientId '/' patientId '_unisensImport.mat'],'Data');
        else
            fprintf('....using existing imported dataset..\n');
        end
    else
        [Data.Signals, Data.StimulationModes, Data.BsValues, Data.BeatDetections] = extractFromUnisens(iPatient);
        Data.imported = datetime('now');
        Data.Metadata = importPatientMetadata('..\data\raw\Patient_data.xlsx');
        save(['../data/matlab/' patientId '/' patientId '_unisensImport.mat'],'Data');
    end

    %% Preprocessing
    
%     % Removing power line artifacts around 50 Hz
%     fprintf('..removing powerline artifacts..\n');
%     Data = filterPowerline(Data);
    
    % Downsampling to 200 Hz using MATLAB decimate function with a fir
    % filter with a Hamming window and order 30.
    fprintf('..downsampling data..\n');
    Data = downsampleData(Data,200);

    %% Detection of single beats (saved to Data.BeatDetections.Merged.samplestamp)
    
    % Beat detections from Labchart and Beatscope are merged to gain
    % maximum information. With constant heartrate of 90 or 100 bpm
    % (depending on manufactorer of the pacemaker) artifacts can be removed
    % by searching detections only in a certain time window.
    
    fprintf('..extracting beats..\n');
    Data.BeatDetections.Merged.samplestamp = detectBeats(Data, iPatient);
    Data.BeatDetections.Merged.fs = Data.BeatDetections.BsBp.fs;
    
    % Plots of sample beats for debugging
        %% Plot for waveform comparison of extracted beats
            stamp = Data.BeatDetections.Merged.samplestamp;

            % use this mask to select a specific part of the signal
            startSecond = 391.848; % coughing in pt3
            stopSecond = 400.856;
            samplestampmask = logical((stamp > startSecond*1000/5) .* (stamp < stopSecond*1000/5));

            test = extractBeats(Data.Signals.PpgClip.data, ...
                                Data.BeatDetections.Merged.samplestamp(samplestampmask), ...
                                Data.Signals.PpgClip.fs, ...
                                Data.Metadata.heartRate(iPatient), ...
                                true);
            [test2, quality] = extractGoodBeats(test,Data.Signals.PpgClip.fs,Data.Metadata.heartRate(iPatient), iPatient);
        %% second plot test 
        stamp = Data.BeatDetections.Merged.samplestamp;

        % use this mask to select a specific part of the signal
        startSecond = 830; % artifact in pt2
        stopSecond = 840;
        samplestampmask = logical((stamp > startSecond*1000/5) .* (stamp < stopSecond*1000/5));

        test = extractBeats(Data.Signals.PpgCuff.data, ...
                            Data.BeatDetections.Merged.samplestamp(samplestampmask), ...
                            Data.Signals.PpgClip.fs, ...
                            Data.Metadata.heartRate(iPatient), ...
                            true);
        [test2, quality] = extractGoodBeats(test,Data.Signals.PpgClip.fs,Data.Metadata.heartRate(iPatient), iPatient);

    %% Extract Modes and mode changes
    % including stimulation intervals, reference interval, change to or
    % from reference interval and the samplestamp of the mode change
    Modes.(patientId).AV.refInterval = Data.Metadata.referenceAV(iPatient);
    Modes.(patientId).VV.refInterval = 0;
    
    
end

fprintf('Done!\n');