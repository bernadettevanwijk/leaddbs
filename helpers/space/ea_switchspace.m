function ea_switchspace(~,~,spacename)

answ=questdlg('Please be aware that switching the default template space is a critical and more or less complicated step. Not all functions may perfectly work if you switch to a different default template as opposed to the ICBM2009b Nonlinear Asymmetric series. Are you sure you wish to switch to a different space?','Switch anatomical space','Sure','Cancel','Cancel');

if strcmp(answ,'Sure')
    ea_storemachineprefs('space',spacename);
    disp('Restarting Lead Neuroimaging Suite...');
    close all
    lead;
end



