%%
% Updated on 27 June, 2017
% The Front-End will save modulation power data for all conditions. If
% fewer conditions are used, the back-end has to be changed. The variable 
% SIMData has to be 6-D structure. But with fewer conditions, its dimension
% reduces. Ex. instead of 1x1x1x2x1x1, it becomes 1x2. SimData is
% automatically squeezed. 
% 
% function master_main(DataDir):
%       Data Analysis: Input DataDir name, the function looks for the directory under NELData and does the analysis
% function master_main(Simulation1DataAnal0):
%       if 1, Simulation.
%       if 0, Data Analysis, User will be asked for input directory.
% function master_main():
%       Default: Simulation
%
% Created by SP [5/18/16]

%% Set up Conditions
function master_main(varargin)

if nargin==0
    Simulation1DataAnal0=1;
elseif ischar(varargin{1})
    Simulation1DataAnal0=0;
    DataDir=strcat(RootDataDir ,varargin{1});
elseif varargin{1}==0 || varargin{1}==1
    Simulation1DataAnal0=varargin{1};
    if ~Simulation1DataAnal0
        DataDir=uigetdir(RootDataDir);
    end
elseif isnumeric(varargin{1})
    Simulation1DataAnal0=0;
    ChinID=varargin{1};
    allfiles=dir(sprintf('%s*%d*',RootDataDir,ChinID));
    if ~isempty(allfiles)
        DataDir=[RootDataDir allfiles.name];
    end
else
    error('Type help master_main to see usage');
end

%% Front-End
RootOUTPUTDir=[pwd filesep 'OUTPUT' filesep];
figHandles=Library.get_figHandles;

if Simulation1DataAnal0 % Simulate
    ExpControlParams=Simulation.get_ExpControlParams;
    [resultsDir,resultTxt]=Simulation.Analyze_Sim(ExpControlParams, RootOUTPUTDir, figHandles);
    save([resultsDir 'ExpControlParams.mat'],'ExpControlParams');
else
    [resultsDir,resultTxt]=DataAnal.Analyze_Data(DataDir);
end

%% Back-End
parse_saved_data_for_all_conds_SNRenv(resultsDir,resultTxt);
if exist('ChinID','var')
    %     create_summary(ChinID);
    % %     plot_summary(ChinID);
end