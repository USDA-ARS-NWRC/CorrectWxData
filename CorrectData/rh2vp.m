function VP = rh2vp(Ta,RH)
% HPM 02/13/12
% ARH 05/07/14
% Scott Havens 12/10/2015
% This function calls the IPW command "rh2vp" and optionally plots output
%     INPUT:   
%         Ta  = air temp [deg C]
%         RH  = relative humidity [0-1]
%     OUTPUT: 
%         VP = vapor pressure [mb]

F1 = [Ta RH]; % matrix output
save('F1','F1','-ascii') % put Ta and RH into a file for input

% Run C-code:
[~,VP] = system('rh2vp -c < F1'); % convert air temp and RH to vapor pressure
%the -c option clips vapor pressure to be less than the saturation vapor pressure

system('rm F1');

if ischar(VP)
    VP = str2num(VP);
end

end