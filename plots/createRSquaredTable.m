EXCLUDEBEATS = 0;
MAXBEATS = 8;

Results = load(['../results/matlab/Results_MAX' num2str(MAXBEATS) '_EX' num2str(EXCLUDEBEATS) '.mat']);

listParameters = Results.Info.parameters;
listBsParameters = Results.Info.bsParameters;
nParameters = length(listParameters);
nBsParameters = length(listBsParameters);
patient = 1:6;
nPatients = length(patient);



%% Create cell array containing rSquared values (AV, FromRef AND ToRef, PPGClip)
cMode = 'AV';
cSignal = 'PpgClip';

rSquaredTable = cell(nParameters + nBsParameters + 1, nPatients + 1);
for iPatient = 1:nPatients                      % Pt01 / ... / Pt06
    patientId = ['Pt0' num2str(patient(iPatient))];
    rSquaredTable{1,iPatient+1} = ['Pt. ' num2str(patient(iPatient))];
    % Loop through PPG-parameters
    for iParameter = 1:nParameters
        cParameter = char(listParameters(iParameter));
        rSquaredTable{1+iParameter,1} = cParameter;
        fromRefScatterplotData = Results.(patientId).(cMode).FromRef.(cSignal).ScatterplotData.(cParameter);
        toRefScatterplotData = Results.(patientId).(cMode).ToRef.(cSignal).ScatterplotData.(cParameter);
        scatterplotData = [fromRefScatterplotData; toRefScatterplotData];
        if isempty(scatterplotData)
            rSquaredTable{1+iParameter,iPatient + 1} = 0;
        else
        x = scatterplotData(:,1);
        y = scatterplotData(:,3);
        [~,~,rSquared,~] = calculateRegression(x,y);
        rSquaredTable{1+iParameter,iPatient + 1} = rSquared;
        end
    end
    % Loop through BeatScope parameters
    for iParameter = 1:nBsParameters
        cParameter = char(listBsParameters(iParameter));
        rSquaredTable{1+nParameters+iParameter,1} = cParameter;
        fromRefScatterplotData = Results.(patientId).(cMode).FromRef.BsBp.ScatterplotData.(cParameter);
        toRefScatterplotData = Results.(patientId).(cMode).ToRef.BsBp.ScatterplotData.(cParameter);
        scatterplotData = [fromRefScatterplotData; toRefScatterplotData];
        if isempty(scatterplotData)
            rSquaredTable{1+iParameter,iPatient + 1} = 0;
        else
        x = scatterplotData(:,1);
        y = scatterplotData(:,3);
        [~,~,rSquared,~] = calculateRegression(x,y);
        rSquaredTable{1+nParameters+iParameter,iPatient + 1} = rSquared;
        end
    end 
end
   % create HeatMap for the table
   figure;
   rSquaredTable(1,:) = [];
   rSquaredTable(:,1) = [];
   cell2mat(rSquaredTable);
   