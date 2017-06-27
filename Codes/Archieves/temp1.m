DataDir='D:\Study Stuff\Matlab\SNRenv-SimData-Updated4PSDavg\Output\Simulation\20170605-1_imp\psd\';

replaceWhat='temp';
replaceWith='SSN';

allfiles=dir([DataDir '*.mat']);


for fileVar=1:length(allfiles)
    oldName=allfiles(fileVar).name;
    if ~isempty(findstr(oldName, replaceWhat))
        newName=strrep(oldName, replaceWhat, replaceWith);
        fprintf('%s --> %s\n', oldName, newName);
        movefile([DataDir oldName], [DataDir newName]);
    end
end


