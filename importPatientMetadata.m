%% Import patient meta data from Excel spreadsheet
% This Script generates the struct patientData containing all relevant
% patient data.
%
% Author: Johann Roth
% Date: 26.11.2015

%% Import the data
[~, ~, tableData] = xlsread('..\data\raw\Patient_data.xlsx','Tabelle1');
tableData(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),tableData)) = {''};

%% Create struct containing relevant data
PopulationData.Info.numberOfPatients = 6;
PopulationData.Info.studyInfo = 'Pilot study for PPG-based optimization of CRT pacemakers and defibrillators';
PopulationData.Data.isMale = logical(cell2mat(tableData(5,2:7)));
PopulationData.Data.age = cell2mat(tableData(4,2:7));
PopulationData.Data.bodySize = cell2mat(tableData(6,2:7));
PopulationData.Data.bodyWeight = cell2mat(tableData(7,2:7));
PopulationData.Data.bmi = cell2mat(tableData(8,2:7));
PopulationData.Data.deviceManufacturer = tableData(27,2:7);
PopulationData.Data.deviceIsDefi = cellfun(@(x) strcmp(x,'CRT-D'), tableData(28,2:7));
PopulationData.Data.monthsSinceImplant = cell2mat(tableData(29,2:7));
PopulationData.Data.isPostOp = (PopulationData.Data.monthsSinceImplant == 0);
PopulationData.Data.heartRate = cell2mat(tableData(44,2:7));
PopulationData.Data.referenceAV = cell2mat(cellfun(@(x) str2double(x(1:3)), tableData(41,2:7), 'UniformOutput', false));

clear tableData;