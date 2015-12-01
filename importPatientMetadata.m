function [ PopulationData ] = importPatientMetadata( filePath )
%IMOPRTPATIENTMETADATA imports patient meta data from Excel spreadsheet
%    This function returns the struct PopulationData containing all relevant
%    patient data.
%      Parameters:
%          filePath (string)
%              path with the xlsx file
%      Returns:
%          PopulationData (struct)
%              Struct containing population data extracted from the specified
%              Excel file
%    
%    '..\data\raw\Patient_data.xlsx'
%   
% Author: Johann Roth
% Date: 26.11.2015

%% Import the data
[~, ~, tableData] = xlsread(filePath,'Tabelle1');
tableData(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),tableData)) = {''};

%% Create struct containing relevant data
PopulationData.Info.numberOfPatients = 6;
PopulationData.Info.studyInfo = 'Pilot study for PPG-based optimization of CRT pacemakers and defibrillators';
PopulationData.isMale = logical(cell2mat(tableData(5,2:7)));
PopulationData.age = cell2mat(tableData(4,2:7));
PopulationData.bodySize = cell2mat(tableData(6,2:7));
PopulationData.bodyWeight = cell2mat(tableData(7,2:7));
PopulationData.bmi = cell2mat(tableData(8,2:7));
PopulationData.deviceManufacturer = tableData(27,2:7);
PopulationData.deviceIsDefi = cellfun(@(x) strcmp(x,'CRT-D'), tableData(28,2:7));
PopulationData.monthsSinceImplant = cell2mat(tableData(29,2:7));
PopulationData.isPostOp = (PopulationData.monthsSinceImplant == 0);
PopulationData.heartRate = cell2mat(tableData(44,2:7));
PopulationData.referenceAV = cell2mat(cellfun(@(x) str2double(x(1:3)), tableData(41,2:7), 'UniformOutput', false));

clear tableData;

end