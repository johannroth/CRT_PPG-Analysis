%% Main script for CRT PPG analysis
% 
% In the following document the term mode will be used as short term for
% stimulation mode, i.e. a stimulation setting with certain stimulation
% parameters (esp. AV- and VV-intervals).
% 
% Calculations are based on the Unisens dataset (see section Import data).
% Unisens dataset has been imported by script rawToUnisens.m (calling
% several subscripts). Conversion of raw data to unisens dataset takes up
% to 20 minutes (for 6 patients).
%
% Author: Johann Roth
% Date: 10.12.2015

clear;
%% Add folders to path to find scripts
oldpath = path;
addpath('beatAnalysis','dataImport','plots','preprocessing','signalAnalysis','unisens');

%% Patient selection (1:6)
% Patients available for the study (1:6 for all patients of clinical study
% in Kiel in october/november 2015)
patient = 1:6;

%% Parameters
% Force to import unisens data freshly (instead of using a previous import
% if available)
FORCEIMPORT = false;

% create quality plots (takes up to 10 minutes!)
QUALITYPLOTS = false;

% Amount of beats before and after each change of the stimulation interval
% that are included in calculation. Maximum: 15 beats (maximum time: 10s,
% equals 15 beats with 90 bpm or 16.7 beats with 100 bpm)
% This value is the maximum possible amount. The amount of beats that are
% included in the calculation may be smaller due to exclusion of bad beats!
MAXBEATS = 8; % 3...15 beats

Results.Info.maxbeats = MAXBEATS;

% Amount of beats directly before or after the change of interval to be
% excluded. The maximum amount of beats will be lowered by excluding the
% 'inner' beats around a change of interval
EXCLUDEBEATS = 0; % 0...MAXBEATS-3

Results.Info.excludebeats = EXCLUDEBEATS;

% Target sampling frequency after downsampling. All data will be provided
% with this sampling frequency after downsampling. (default: 200)

TARGETFS = 200; % Hz


%% Data import and signal analysis
% Loop through all patients (1-6)
for iPatient = patient
    fprintf(['Computing patient ' num2str(iPatient) '.\n']);
    patientId = ['Pt0' int2str(iPatient)];
    
    %% Import data
    % use existing imported data if available and not older than a day
    
    fprintf('..importing unisens data');
    if exist(['../data/matlab/' patientId '/' patientId '_unisensImport.mat'],'file') && ~FORCEIMPORT
        Data = load(['../data/matlab/' patientId '/' patientId '_unisensImport.mat']);
        if hours(datetime('now') - Data.imported) > 24
            clearvars Data;
            [Data.Signals, Data.StimulationModes, Data.BsValues, Data.BeatDetections] = extractFromUnisens(iPatient);
            Data.imported = datetime('now');
            Data.patient = iPatient;
            save(['../data/matlab/' patientId '/' patientId '_unisensImport.mat'],'-struct','Data');
        else
            fprintf(' (using existing imported dataset)');
        end
    else
        [Data.Signals, Data.StimulationModes, Data.BsValues, Data.BeatDetections] = extractFromUnisens(iPatient);
        Data.imported = datetime('now');
        Data.patient = iPatient;
        save(['../data/matlab/' patientId '/' patientId '_unisensImport.mat'],'-struct','Data');
    end
    fprintf('..\n');
    Metadata = importPatientMetadata('..\data\raw\Patient_data.xlsx');

    %% Preprocessing
    
%     % Removing power line artifacts around 50 Hz
%     fprintf('..removing powerline artifacts..\n');
%     Data = filterPowerline(Data);
    
    % Downsampling to TARGETFS (default: 200 Hz) using MATLAB decimate
    % function with a fir filter with a Hamming window and order 30.
    Data.fs = TARGETFS; % Hz, target sampling frequency for downsampling
    fprintf('..downsampling data..\n');
    Data = downsampleData(Data,Data.fs);

    %% Detection of single beats (saved to Data.BeatDetections.Merged.samplestamp)
    
    % Beat detections from Labchart and Beatscope are merged to gain
    % maximum information. With constant heartrate of 90 or 100 bpm
    % (depending on manufactorer of the pacemaker) artifacts can be removed
    % by searching detections only in a certain time window.
    
    fprintf('..detecting beats..\n');
    Data.BeatDetections.Merged.samplestamp = detectBeats(Data, Metadata, iPatient);
    Data.BeatDetections.Merged.fs = Data.BeatDetections.BsBp.fs;
    
    %% Data struct for the current patient has been completed.
    % Full import and merging of beat detections has been completed. Struct
    % is saved for faster processing later.
    save(['../data/matlab/' patientId '/' patientId '_processedDataStruct.mat'],'-struct','Data');
    
    % for later import use:
    % Data = load(['../data/matlab/' patientId '/' patientId '_processedDataStruct.mat']);
    
    %% Plots of sample beats for debugging
%         %% Plot for waveform comparison of extracted beats
%             stamp = Data.BeatDetections.Merged.samplestamp;
% 
%             % use this mask to select a specific part of the signal
%             startSecond = 391.848; % coughing in pt3
%             stopSecond = 400.856;
%             samplestampmask = logical((stamp > startSecond*1000/5) .* (stamp < stopSecond*1000/5));
% 
%             test = extractBeats(Data.Signals.PpgClip.data, ...
%                                 Data.BeatDetections.Merged.samplestamp(samplestampmask), ...
%                                 Data.Signals.PpgClip.fs, ...
%                                 Metadata.heartRate(iPatient), ...
%                                 true);
%             [test2, quality] = extractGoodBeats(test,Data.Signals.PpgClip.fs,Metadata.heartRate(iPatient), iPatient);
%         %% second plot test 
%         stamp = Data.BeatDetections.Merged.samplestamp;
% 
%         % use this mask to select a specific part of the signal
%         startSecond = 830; % artifact in pt2
%         stopSecond = 840;
%         samplestampmask = logical((stamp > startSecond*1000/5) .* (stamp < stopSecond*1000/5));
% 
%         test = extractBeats(Data.Signals.PpgCuff.data, ...
%                             Data.BeatDetections.Merged.samplestamp(samplestampmask), ...
%                             Data.Signals.PpgClip.fs, ...
%                             Metadata.heartRate(iPatient), ...
%                             true);
%         [test2, quality] = extractGoodBeats(test,Data.Signals.PpgClip.fs,Metadata.heartRate(iPatient), iPatient);
  
    %% Extract Modes and mode changes to 'Results' struct
    % including stimulation intervals, reference interval, change to or
    % from reference interval and the samplestamp of the mode change
    [Results.(patientId).AV, Results.(patientId).VV] = extractModes(Data,Metadata,iPatient);
    
    %% Extract beats around mode changes (amound defined by MAXBEATS)
    % here the beats around mode changes are extracted and good beats are
    % saved to 'Results' struct.
    fprintf('..selecting beats..\n');
    [ Results.(patientId).AV, Results.(patientId).VV ] = ...
        extractModeChangeBeats( Results.(patientId).AV, ...
                                Results.(patientId).VV, ...
                                Data, ...
                                Metadata, ...
                                iPatient, ...
                                MAXBEATS, ...
                                EXCLUDEBEATS );

    %% Create plots for quality control and save them to ../results/plots
    % plots are not opened.
    if QUALITYPLOTS
        fprintf('..creating quality plots..\n');
        qualityPlots( Data, Results, iPatient, MAXBEATS, EXCLUDEBEATS );
    end
    
    %% Extract parameters calculated by Finometer/BeatScope software
    fprintf('..extracting beatscope parameters..\n');
    Results = extractFinoParams( Results, Data, Metadata, iPatient, MAXBEATS, EXCLUDEBEATS );
end

%% Analysis of extracted Data
fprintf('Analysing beats..\n');
% This is implemented in a second loop to be able to run this seperately if
% needed.
Results = analyseBeats(Results, TARGETFS, patient);
Results = calculateDeltas(Results, patient);

% testPlots( Results, patient );

% for iPatient = patient
%     patientId = ['Pt0' int2str(iPatient)];
%     Data = load(['../data/matlab/' patientId '/' patientId '_processedDataStruct.mat']);
%     
%     
% end

%% Save Results Struct for current analysis
save(['../results/matlab/Results_MAX' num2str(MAXBEATS) '_EX' num2str(EXCLUDEBEATS) '.mat'],'-struct','Results');
    
% for later import use:
% Results = load(['../results/matlab/Results_MAX' num2str(MAXBEATS) '_EX' num2str(EXCLUDEBEATS) '.mat']);

%% Restore old path
path(oldpath);

% clearvars patientId FORCEIMPORT MAXBEATS EXCLUDEBEATS oldpath;
fprintf('Done!\n');