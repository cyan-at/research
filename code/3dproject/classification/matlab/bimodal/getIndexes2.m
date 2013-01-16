function [ indexes ] = getIndexes2( row, column, numRows, numColumns, patchSize )
%GETINDEXES
%remember that it goes down columnsz
if (patchSize == 1)
    indexes = zeros(1,1);
    indexes(1) = numRows * (row-1) + column;
elseif (patchSize == 2)
    indexes = zeros(1,4);
    indexes(1) = numRows * (row-1) + column; %top left
    indexes(2) = numRows * (row) + column; %bottom left
    indexes(3) = indexes(1) + 1; %top right
    indexes(4) = indexes(2) + 1; %bottom right
    indexes = indexes';
elseif (patchSize == 3)
    indexes = zeros(1,9);
    indexes(1) = numRows * (row-1) + column; %top left
    indexes(2) = numRows * (row) + column; %middle left
    indexes(3) = numRows * (row+1) + column; %bottom left
    indexes(4) = indexes(1) + 1; %top middle
    indexes(5) = indexes(2) + 1; %middle middle
    indexes(6) = indexes(3) + 1; %bottom middle
    indexes(7) = indexes(4) + 1; %top right
    indexes(8) = indexes(5) + 1; %middle right
    indexes(9) = indexes(6) + 1; %bottom right
    indexes = indexes';
end

end

