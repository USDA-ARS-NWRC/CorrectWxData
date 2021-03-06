function [results,dtimes,stations] = Results2Matrix(data,vars)

% return the data in matrix form
% INPUTS:
%   data - structure of results from query where each variable has it's own
%           field
%   vars - variables used in query
%
% OUTPUT:
%   results - [m x n] matrix of results with [dtimes x stations]
%   dtimes [m x 1] vector of datenum
%   stations [n x 1] vector of unique stations
%
% Variables available:
% 'date_time'
% 'air_temp'
% 'dew_point_temperature'
% 'relative_humidity'
% 'wind_speed'
% 'wind_direction'
% 'wind_gust'
% 'solar_radiation'
% 'soil_temp'
% 'sea_level_pressure'
% 'pressure_1500_meter'
% 'altimeter'
% 'pressure'
% 'water_temp'
% 'cloud_layer_1_code'
% 'cloud_layer_2_code'
% 'cloud_layer_3_code'
% 'visibility'
% 'weather_cond_code'
% 'pressure_tendency'
% 'road_sensor_num'
% 'road_temp'
% 'road_subsurface_tmp'
% 'road_freezing_temp'
% 'road_surface_condition'
% 'air_temp_high_6_hour'
% 'air_temp_low_6_hour'
% 'air_temp_high_24_hour'
% 'air_temp_low_24_hour'
% 'peak_wind_speed'
% 'peak_wind_direction'
% 'fuel_temp'
% 'fuel_moisture_ten_hour'
% 'ceiling'
% 'sonic_wind_speed'
% 'pressure_change_code'
% 'precip_smoothed'
% 'soil_temp_ir'
% 'temp_in_case'
% 'soil_moisture'
% 'volt'
% 'created_time_stamp'
% 'last_modified'
% 'snow_smoothed'
% 'precip_accum_ten_minute'
% 'precip_accum_three_hour'
% 'precip_accum_fifteen_minute'
% 'precip_accum_one_hour'
% 'precip_accum_five_minute'
% 'precip_accum_six_hour'
% 'precip_accum_24_hour'
% 'precip_accum_30_minute'
% 'precip_accum'
% 'precip_accum_one_minute'
% 'snow_depth'
% 'snow_accum'
% 'precip_storm'
% 'snow_interval'
% 'T_water_temp'
% 'evapotranspiration'
% 'snow_water_equiv'
% 'precipitable_water_vapor'
% 'net_radiation'
% 'soil_moisture_tension'
% 'air_temp_wet_bulb'
% 'air_temp_2m'
% 'air_temp_10m'
% 'soil_temp1_18'
% 'soil_temp2_18'
% 'soil_temp_20'
% 'net_radiation_sw'
% 'net_radiation_lw'
% 'sonic_air_temp'
% 'sonic_wind_direction'
% 'sonic_vertical_vel'
% 'ground_temp'
% 'sonic_zonal_wind_stdev'
% 'sonic_meridonial_wind_stdev'
% 'sonic_vertical_wind_stdev'
% 'sonic_air_temp_stdev'
% 'vertical_heat_flux'
% 'friction_velocity'
% 'w_ratio'
% 'sonic_ob_count'
% 'sonic_warn_count'
% 'moisture_stdev'
% 'vertical_moisture_flux'
% 'M_dew_point_temperature'
% 'virtual_temp'
% 'gepotential_height'
% 'outgoing_radiation_sw'
% 'clear_sky_solar_radiation'
% 'estimated_snowfall_rate'
% 'grip_1_ice_friction_code'
% 'grip_2_level_of_grip'
% 'photosynthetically_active_radiation'
% 'pm_25_concentration'
% 'air_flow_rate'
% 'internal_relative_humidity'
% 'air_flow_temperature'
% 'ozone_concentration'
% 'precipitation_accumulated_00_UTC'

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% go through the data
dtimes = unique(data.date_time);    % the hourly data
stations = unique(data.station_id); % the stations returned

nTimes = length(dtimes);
nsta = length(stations);
nvars = length(vars);

% create a matrix to store the results
results = NaN(nTimes,nsta,nvars);

for k = 1:nvars
    for n = 1:length(stations)
        
        % station index
        sind = ismember(data.station_id, stations{n});
        
        % the data
        d = data.(vars{k})(sind);
        
        % if all NaN's don't do anything
        if sum(isnan(d)) ~= sum(sind)
            
            % the times
            dt = data.date_time(sind);
            [C,ia,ic] = unique(dt);
            d = d(ia);
            
            
            % time index
            tind = find(ismember(dtimes, C));
            
            results(tind,n,k) = d;
        end
    end
end




% for n = 1:length(data.station_id)
%     
%     % get the time index
%     tind = strcmp(data.date_time(n),dtimes);
%     
%     % get the station index
%     sind = strcmp(data.station_id(n),stations);
%     
%     % insert the variables
%     for k = 1:nvars
%         
%         results(tind,sind,k) = data.(vars{k})(n);
%         
%     end
%     
% end

dtimes = datenum(dtimes);
