%% Main script for CRT PPG analysis
%
%
% Author: Johann Roth
% Date: 01.12.2015

clear;

for patient = 1
    fprintf(['Computing patient ' num2str(patient) '.\n']);
    
    %% Import data
    fprintf('..importing unisens data..\n');
    [Data.Signals, Data.StimulationModes, Data.BsValues, Data.BeatDetections] = extractFromUnisens(patient);
    
    Data.Metadata = importPatientMetadata('..\data\raw\Patient_data.xlsx');
    
    %% Preprocessing
    
    % Downsampling to 200 Hz using MATLAB decimate function with a fir
    % filter with a Hamming window and order 30.
    fprintf('..downsampling data..\n');
    Data = downsampleData(Data,200);
    
    %% Extraction of single beats
    
    % Beat detections from Labchart and Beatscope are merged to gain
    % maximum information. With constant heartrate of 90 or 100 bpm
    % (depending on manufactorer of the pacemaker) artifacts can be removed
    % by searching detections only in a certain time window.
    
    fprintf('..extracting beats..\n');
    Beats = detectBeats(Data, patient);
    
    %%
    
    
%     clear Data;
end

fprintf('Done!\n');