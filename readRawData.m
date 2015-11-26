%% This script reads raw patient data
% from CRT-optimization study in Kiel and saves data into matlab data
% folder as Pt##_raw.mat where ## is the number of the patient.

patient = 1:6;
fprintf('Read raw data...............................\n');
for i = 1:size(patient,2)
    fprintf(['Reading Pt0' int2str(i)]);
    
    patientId = ['Pt0' int2str(i)];
    patientDataFolder = ['../data/raw/' patientId '/'];
    
    % Read LabChart data
    labChartFile = [patientDataFolder 'LabChart' patientId '.mat'];
    LabChartData = load(labChartFile);
    fprintf('....');
    % Read CRT-Logger annotations
    loggerFile = [patientDataFolder 'CRT-Logger_' patientId '.txt'];
    LoggerData = readLogFile(loggerFile);
    fprintf('....');
    % Read BeatScope data
    bsBeatsFile = [patientDataFolder 'BeatscopeBeats_' patientId '.txt'];
    bsWaveFile = [patientDataFolder 'BeatscopeWave_' patientId '.txt'];
    BsBeatsData = readBeatScopeBeatsFile(bsBeatsFile);
    fprintf('............');
    BsWaveData = readBeatScopeWaveFile(bsWaveFile);
    fprintf('............\n');
    save(['../data/matlab/' patientId '/' patientId '_raw.mat'],'LabChartData','LoggerData','BsBeatsData','BsWaveData');
    clear LabChartData LoggerData BsBeatsData BsWaveData;    
end
clear patientId patientDataFolder loggerFile labChartFile i bsBeatsFile bsWaveFile;
fprintf('Done!.......................................\n');


