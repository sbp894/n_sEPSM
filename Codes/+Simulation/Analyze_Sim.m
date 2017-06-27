function [resultsDir,resultTxt]=Analyze_Sim(ExpControlParams, RootOUTPUTDir, figHandles)

resultsDir=Library.create_output_dir(1,datestr(now,'yyyymmdd'), RootOUTPUTDir); % Create directories
[A,B]=Simulation.get_speech_params(ExpControlParams);
AN=Simulation.get_AN_params(ExpControlParams);
anal=Simulation.get_anal_params(ExpControlParams,AN,resultsDir,figHandles);
cndts=Simulation.get_conditions(A,B,AN,resultsDir);
MaxIter=size(cndts,1);


CFs=AN.CF;
resultTxt=anal.resultTxt;


parfor condition_var = 1:MaxIter
    
    C=Simulation.getCsim(cndts,condition_var,A,B,AN, CFs);
    resultPostfix = sprintf(resultTxt,       C.cF_i/1e3,  C.sentence_i,  C.noise_i, C.level, C.snr_i, C.ftype_i);
    
    if ~exist([resultsDir 'progress' filesep resultPostfix '.mat'],'file')
        
        [stim_S,stim_N,stim_SN] = Library.SNstim_resample(A,B,C,anal);
        [SpikeTrains,paramsIN]=Simulation.get_model_spiketimes(stim_S, stim_N, stim_SN, A, resultPostfix, C, AN, anal, resultsDir);
             
        [PSDenv_STRUCT,PSDtfs_STRUCT,PowerMod_STRUCT,PowerTfs_STRUCT] = ...
            Library.sumcors_bootstrap(SpikeTrains,paramsIN, resultsDir,resultPostfix, anal);
        Library.save_analysis_results(PSDenv_STRUCT,PSDtfs_STRUCT,PowerMod_STRUCT,PowerTfs_STRUCT,resultsDir,resultPostfix,paramsIN);
        Library.update_progress(resultsDir,resultPostfix,MaxIter);
    end
end