%MFIND   Find matching rows or columns in a matrix
%
%   [ I B ] = mfind(M, X)
%
%   Find the row or column vector X within the matrix M.
%   If X is a row vector, I will contain the column indexes where X is a row in M.
%   If X is a column vector, I will contain the row indexes where X is a column in M.
%   B will contain the boolean matching rows or columns.
%   If no match if found, I will be empty.
%
%   Example:
%      a = [1 2; 3 4; 5 6];
%
%      [i b] = mfind(a, [3 4])
%      i = 2
%      b = [ 0; 1; 0 ]
%
%      [i b] = mfind(a, [1; 3; 5])
%      i = 1
%      b = [ 1 0 ]
%
%   v1.0.1 - 29/03/2011 - Marcello Ferro <marcello.ferro@ilc.cnr.it>
%
function [I B] = mfind(M, X)

% find a row or a column?
if(size(X,2) == 1);
    % boolean indexes
    B = ismember(M', X', 'rows')';
else
    % boolean indexes
    B = ismember(M, X, 'rows');
end

% row/column indexes
I = find(B == true);

