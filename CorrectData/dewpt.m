function DPT = dewpt(ea)
% ARH 05/12/14
% This function calls the IPW command "dewpt" and calculates dew point 
% temperatures from input vapor presure values.
%     INPUT:
%         ea  = vapor pressure [Pa]
%     OUTPUT:
%         DPT = dew point temperature [C]


F1 = ea; % matrix output
save F1 F1 '-ascii' % save the input vapor pressure as a text file

% Run C-code:
[~,result] = system('dewpt < F1');
system('rm F1');

DPT = str2num(result);

end
