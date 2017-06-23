function [resultsDir,resultTxt]=Analyze_Sim(ExpControlParams, RootOUTPUTDir)

% global figHandles ExpControlParams
% BootstrapLoopMax=ExpControlParams.BootstrapLoopMax;%300;
% BootstrapLoopReport=ExpControlParams.BootstrapLoopReport;
% nPSDs2Avg=ExpControlParams.nPSDs2Avg;

resultsDir=Library.create_output_dir(1,datestr(now,'yyyymmdd'), RootOUTPUTDir); % Create directories
Fs = 100e3; % Model sampling frequency
[A,B]=Simulation.get_speech_params(Fs, ExpControlParams);
AN=Simulation.get_AN_params(ExpControlParams);
anal=Simulation.get_anal_params(Fs,AN,resultsDir);
cndts=Simulation.get_conditions(A,B,AN,resultsDir);
MaxIter=size(cndts,1);
CFs=AN.CF;
resultTxt=anal.resultTxt;

FixSNlevel=ExpControlParams.fixSPL;
BootstrapLoopMax=ExpControlParams.BootstrapLoopMax;%300;
BootstrapLoopReport=ExpControlParams.BootstrapLoopReport;
nPSDs2Avg=ExpControlParams.nPSDs2Avg;

parfor condition_var = 1:MaxIter
    
    C=getCsim(cndts,condition_var,A,B,AN, CFs);
    resultPostfix = sprintf(resultTxt,       C.cF_i/1e3,  C.sentence_i,  C.noise_i, C.level, C.snr_i, C.ftype_i);
    
    if ~exist([resultsDir 'progress' filesep resultPostfix '.mat'],'file')
        
        [stim_S,stim_N,stim_SN] = Library.SNstim_resample(A,B,C,anal);
        %         [stim_S,stim_N,stim_SN] = Library.SNstim_resampleSP(A,B,C,anal);
        [SpikeTrains,paramsIN]=Simulation.get_model_spiketimes(stim_S, stim_N, stim_SN, A, resultPostfix, C, AN, anal, resultsDir, FixSNlevel);
        
        
        if ~isempty(SpikeTrains)
            [PSDenv_STRUCT,PSDtfs_STRUCT,PowerMod_STRUCT,PowerTfs_STRUCT] = Library.sumcors_bootstrap(SpikeTrains,paramsIN, resultsDir,resultPostfix, BootstrapLoopMax, BootstrapLoopReport, nPSDs2Avg);
%             [PSDenv_STRUCT,PSDtfs_STRUCT,PowerMod_STRUCT,PowerTfs_STRUCT] = sumcors_bootstrapDTU(SpikeTrains,paramsIN, resultsDir,resultPostfix, BootstrapLoopMax, BootstrapLoopReport, nPSDs2Avg, figHandles );
            Simulation.save_analysis_results(PSDenv_STRUCT,PSDtfs_STRUCT,PowerMod_STRUCT,PowerTfs_STRUCT,resultsDir,resultPostfix,paramsIN);
            Simulation.update_progress(resultsDir,resultPostfix,MaxIter);
        else
            disp(['Whoa!' num2str(condition_var)]);
        end
    end
end