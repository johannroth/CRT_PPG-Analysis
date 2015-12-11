%% Script to loop through all patients e.g. to plot data
% 
%
% Author: Johann Roth
% Date: 10.12.2015

%% Add folders to path to find scripts
oldpath = path;
addpath('dataImport','plots','preprocessing','signalAnalysis','unisens');

%% Patient selection (1:6)
% Patients available for the study (1:6 for all patients of clinical study
% in Kiel in october/november 2015)
patient = 1:6;

%% Loop through all patients (1-6)
for iPatient = patient
    fprintf(['Computing patient ' num2str(iPatient) '....\n']);
    patientId = ['Pt0' int2str(iPatient)];
    
    
    
end

%% Restore old path
path(oldpath);
fprintf('Done!\n');