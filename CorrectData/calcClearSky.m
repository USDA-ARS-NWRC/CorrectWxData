function clear_sky = calcClearSky(date_time, lat, lon, rad)
% calcuate the modeled clear sky for a point.
%
% INPUTS:
%   date_time - datenum vector of times to calculate clear sky for
%   lat - latitude of point
%   lon - longitude of point
%   rad - structure containing:
%       tau - optical thickness
%       zone - The  time  values  are  in the time zone which is min minutes
%            west of Greenwich (default: 0).  For example, if input times are
%             in Pacific Standard Time, then min would be 480.
%       slope (default=0) - slope of surface
%       aspect (default=0) - aspect of surface
%
% OUTPUTS:
%   clear_sky - modeled clear sky radiation
%
% 2016-02-24 Scott Havens
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

date_time = date_time - (1/24);
len = length(date_time) * 2; % number of calculations
cal = 0;
wb = waitbar(cal/len, 'Calculating sun angle...');

% calculate the sun angle
[zenith, cosz, azimuth] = sunang(date_time, lat, lon, rad.zone, rad.slope, rad.aspect);


% calculate the solar at the top of the atmosphere
S0 = NaN(length(date_time), 1);
day = round(date_time);
dt = unique(day);

cal = length(date_time);
len = len + length(dt);

for n = 1:length(dt)
    
   s = solar(dt(n), rad.um, rad.um2); 
   
   ind = day == dt(n);
   S0(ind) = s;
   
   cal = cal + 1;
   waitbar(cal/len, wb, 'Calculating solar...');
end

% calculate the two stream modeled radiation
cal = cal + 1;
waitbar(cal/len, wb, 'Calculating twostream...');
R = twostream(cosz, S0, rad.tau, rad.omega, rad.g, rad.R0, rad.d);


waitbar(1, wb, 'Calculating twostream...');

clear_sky = R(:,11);


% apply the scaling factor
if isfield(rad, 'scale')
    clear_sky = clear_sky * rad.scale;
end

close(wb)

end

function R = twostream(mu0, S0, tau, omega, g, R0, d)
% Wrapper for the twostream.c IPW function
%     
% Provides twostream solution for single-layer atmosphere over horizontal surface,
% using solution method in: Two-stream approximations to radiative transfer
% in planetary atmospheres: a unified description of existing methods and a new 
% improvement, Meador & Weaver, 1980, or will use the delta-Eddington  method,
% if the -d flag is set (see: Wiscombe & Joseph 1977).
% 
% Inputs:
%     mu0 - The cosine of the incidence angle is cos (from program sunang).
%     0 - Do not force an error if mu0 is <= 0.0; set all outputs to 0.0 and go on. 
%         Program will fail if incidence angle is <= 0.0, unless -0 has been set.
%     tau - The optical depth is tau.  0 implies an infinite optical depth.
%     omega - The single-scattering albedo is omega.
%     g - The asymmetry factor is g.
%     R0 - The reflectance of the substrate is R0.  If R0 is negative, it will be set to zero.    
%     S0 - The direct beam irradiance is S0 This is usually the solar constant for the specified 
%         wavelength band, on the specified date, at the top of the atmosphere, from program solar.
%         If S0 is negative, it will be set to 1/cos, or 1 if cos is not specified.
%     d - The delta-Eddington method will be used.
% 
% Output:
%     R - mu0, tau0, omega, g, rho0, S0, refl, trans, btrans, up_flux, dn_flux, dir, bot
%
% 2016-02-24 Scott Havens
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dflag = '';
if d
    dflag = '-d';
end

i = [mu0 S0]';
d = sprintf('%f %f\n', i(:));

cmd_str = sprintf('echo "%s" | twostream -0 -t %s -w %s -g %s -r %s %s',...
        d, num2str(tau), num2str(omega), num2str(g), num2str(R0), dflag);

[status, out] = system(cmd_str);

if status ~= 0
    error('twostream failure');
    return
end



c = regexp(out, '[\s]*', 'split');

% convert to numbers and remove any empty cells
c = cellfun(@str2num, c, 'UniformOutput', false);
ind = cellfun(@isempty, c);
c(ind) = [];

c(cellfun(@isstruct, c)) = [];  % the 'dir' causes a directory listing

R = cell2mat(reshape(c, 12, length(mu0)))';

end


function s = solar(dt, um, um2)
% calculate the exoatmosphere direct solar irradiance

% date string
dstr = datestr(dt, 'yyyy,mm,dd');

cmd_str = sprintf('solar -w %s,%s -d %s', num2str(um), num2str(um2), dstr);

[status, out] = system(cmd_str);

if status ~= 0
    error('Solar failure');
    return
end

c = regexp(out, ' ', 'split');

s = str2num(c{1});


end

function [zenith, cosz, azimuth] = sunang(dt, lat, lon, zone, slope, aspect)
% Calculate the sunangle for the given date, lat, long, zone, slope, and
% aspect
%
% 2016-02-24 Scott Havens
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% date string
dstr = datestr(dt, 'yyyy,mm,dd,HH,MM,SS');

% degree strings
[d, m, sd] = deg2dms(lat);
lat_str = sprintf('%s,%s,%02.1f', num2str(d), num2str(m), sd);

[d, m, sd] = deg2dms(abs(lon));
d = -1 * abs(d);
lon_str = sprintf('%s,%s,%02.1f', num2str(d), num2str(m), sd);

% prepare the command
d = cellstr(dstr);
dates = sprintf('%s\n',d{:});
cmd_str = sprintf('echo "%s" | sunang -b %s -l %s -s %i -a %i -z %i',...
    dates, lat_str, lon_str, slope, aspect, zone);

[status, out] = system(cmd_str);

if status ~= 0
    error('Sunangle failed')
    return
end


c = regexp(out, '[\s]*', 'split');
c = cellfun(@str2num, c, 'UniformOutput', false);
if length(c) ~= length(dt)*3
    c(end) = [];
end

c = cell2mat(reshape(c,3, length(dt)))';
zenith = c(:,1);
cosz = c(:,2);
azimuth = c(:,3);



end