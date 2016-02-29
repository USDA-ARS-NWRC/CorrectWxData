function metadata = organizeMetadata(data)
% 20151209 Scott Havens
%
% The structure returned by the db is one sturcture with a cell array of
% all the values.  I want this to be the other way around

f = fieldnames(data);
N = length(data.primary_id);

metadata = cell2struct(cell(size(f)), f, 1);

for n = 1:N
    for k = 1:length(f)
        if iscell(data.(f{k}))
            metadata(n).(f{k}) = data.(f{k}){n};
        else
            metadata(n).(f{k}) = data.(f{k})(n);
        end
    end
    [x,y] = deg2utm(metadata(n).latitude, metadata(n).longitude);
    metadata(n).X = x;
    metadata(n).Y = y;
end