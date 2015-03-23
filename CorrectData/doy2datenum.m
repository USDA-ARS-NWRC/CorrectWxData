function n = doy2datenum(Y,DOY,HHMM)

% Calculates the serial date from day of year
% Can account for leap years
%
% INPUTS
%       Y - year
%       DOY - Day of year
%       HHMM - hour minutes
% OUTPUTS
%       n - serial date
%
% 20110106 Scott Havens
% 20150317 Scott Havens - update for speed

st = num2str(HHMM);

for k = 1:length(Y)
    
    d = [Y(k) 1 1 0 0 0];   % January 1, midnight.
    
    % separate minute from hour
    if HHMM(k) == 0
        hh = 0;
        mm = 0;
        
    else
        
        % get the current value
        s = st(k,:);
        hh = str2double(s(1:2));
        mm = str2double(s(3:4));
        
        if isnan(hh)
            hh = 0;
        end
                
    end
    
    
    n(k,1) = datenum(d) + DOY(k) - 1 + (hh + mm/60)/24;


end

