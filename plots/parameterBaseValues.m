%% This script creates a table containing mean and std values
% for all parameters and patients (calculated from all beats at reference
% intervals)
%
% Author: Johann Roth
% Date: 11.01.2016


EXCLUDEBEATS = 0;
MAXBEATS = 8;

cFormatSpec = '%.3g';

Results = load(['../results/matlab/Results_MAX' num2str(MAXBEATS) '_EX' num2str(EXCLUDEBEATS) '.mat']);

listParameters = Results.Info.parameters;
listBsParameters = Results.Info.bsParameters;
listParameterLatexNames = Results.Info.parameterLatexNames;
listBsParameterLatexNames = Results.Info.bsParameterLatexNames;
listParameterUnits = Results.Info.parameterUnits;
listBsParameterUnits = Results.Info.bsParameterUnits;
nParameters = length(listParameters);
nBsParameters = length(listBsParameters);
patient = 1:6;
nPatients = length(patient);

%% Initialize table for mean and std values
valueTable  = cell(2*nParameters + nBsParameters + 1, nPatients +1);
valueTable{1,1} = 'Mittelwert +- Standardabw.';

for iPatient = 1:nPatients                      % Pt01 / ... / Pt06
    patientId = ['Pt0' num2str(patient(iPatient))];
    valueTable{1,iPatient+1}    = ['Pt. ' num2str(patient(iPatient))];
    %% Loop through PPG-parameters (Clip signal)
    for iParameter = 1:nParameters
        cParameter = char(listParameters(iParameter));
        cParameterLatexName = char(listParameterLatexNames(iParameter));
        cUnit = char(listParameterUnits(iParameter));
        valueTable{1+iParameter,1}  = [cParameterLatexName ' (Clip) (' cUnit ')'];
        
        cValuesFromRefAV    = Results.(patientId).AV.FromRef.('PpgClip').(cParameter)(:,1,:);
        cValuesToRefAV      = Results.(patientId).AV.ToRef.('PpgClip').(cParameter)(:,2,:);
        cValuesFromRefVV    = Results.(patientId).VV.FromRef.('PpgClip').(cParameter)(:,1,:);
        cValuesToRefVV      = Results.(patientId).VV.ToRef.('PpgClip').(cParameter)(:,2,:);
        
        cValues = [ cValuesFromRefAV(:)
                    cValuesToRefAV(:)
                    cValuesFromRefVV(:)
                    cValuesToRefVV(:) ];
        cValues(isnan(cValues)) = [];
        
        cMeanValue = mean(cValues);
        stdValue = std(cValues);
        valueTable{1+iParameter,1+iPatient} = [num2str(cMeanValue,cFormatSpec) ' +- ' num2str(stdValue,cFormatSpec)];
    end
    %% Loop through PPG-parameters (Cuff signal)
    for iParameter = 1:nParameters
        cParameter = char(listParameters(iParameter));
        cParameterLatexName = char(listParameterLatexNames(iParameter));
        cUnit = char(listParameterUnits(iParameter));
        valueTable{1+nParameters+iParameter,1}  = [cParameterLatexName ' (Cuff) (' cUnit ')'];
        
        cValuesFromRefAV    = Results.(patientId).AV.FromRef.('PpgCuff').(cParameter)(:,1,:);
        cValuesToRefAV      = Results.(patientId).AV.ToRef.('PpgCuff').(cParameter)(:,2,:);
        cValuesFromRefVV    = Results.(patientId).VV.FromRef.('PpgCuff').(cParameter)(:,1,:);
        cValuesToRefVV      = Results.(patientId).VV.ToRef.('PpgCuff').(cParameter)(:,2,:);
        
        cValues = [ cValuesFromRefAV(:)
                    cValuesToRefAV(:)
                    cValuesFromRefVV(:)
                    cValuesToRefVV(:) ];
        cValues(isnan(cValues)) = [];
        
        cMeanValue = mean(cValues);
        stdValue = std(cValues);
        
        valueTable{1+nParameters+iParameter,1+iPatient} = [num2str(cMeanValue,cFormatSpec) ' +- ' num2str(stdValue,cFormatSpec)];
    end
    %% Loop through BeatScope parameters
    for iParameter = 1:nBsParameters
        cParameter = char(listBsParameters(iParameter));
        cParameterLatexName = char(listBsParameterLatexNames(iParameter));
        cUnit = char(listBsParameterUnits(iParameter));
        valueTable{1+2*nParameters+iParameter,1}  = [cParameterLatexName ' (Fino) (' cUnit ')'];
        
        cValuesFromRefAV    = Results.(patientId).AV.FromRef.('BsBp').(cParameter)(:,1,:);
        cValuesToRefAV      = Results.(patientId).AV.ToRef.('BsBp').(cParameter)(:,2,:);
        cValuesFromRefVV    = Results.(patientId).VV.FromRef.('BsBp').(cParameter)(:,1,:);
        cValuesToRefVV      = Results.(patientId).VV.ToRef.('BsBp').(cParameter)(:,2,:);
        
        cValues = [ cValuesFromRefAV(:)
                    cValuesToRefAV(:)
                    cValuesFromRefVV(:)
                    cValuesToRefVV(:) ];
        cValues(isnan(cValues)) = [];
        
        cMeanValue = mean(cValues);
        stdValue = std(cValues);
        
        valueTable{1+2*nParameters+iParameter,1+iPatient} = [num2str(cMeanValue,cFormatSpec) ' +- ' num2str(stdValue,cFormatSpec)];
    end
end