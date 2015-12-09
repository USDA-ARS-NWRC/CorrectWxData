function data = readASCII(filename,delimiter,headerLines)

% Read in an ASCII file with filename.  This will return a header and the
% data
%
% INPUTS:
%   filename - filename of the ASCII file either with full path or relative
%   delimiter [optional] - default to space
%   headerLines [optional] - defaults to 6, number of header lines
%
% OUTPUTS:
%   data - matrix of the data read from the file
%   data - header infromation along with x and y vectors
%
% 2015-02-02 Scott Havens
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parse the input arguments
if nargin < 3
    headerLines = 6;
end

if nargin < 2
    delimiter = ' ';
end

% read the ASCII file
A = importdata(filename,delimiter,headerLines);

% look through the headers
for n = 1:length(A.textdata)
    tmp = regexp(A.textdata{n},delimiter,'split');
    tmp(cellfun(@isempty,tmp)) = [];
    data.(tmp{1}) = str2num(tmp{2});
end

% add the vector for the x and y
[m,n] = size(A.data);
data.x = data.xllcorner + [0:n-1]*data.cellsize;
data.y = data.yllcorner + [0:m-1]*data.cellsize;

data.data = A.data;