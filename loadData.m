function [transactions, items] = loadData(filename,preview)
%LOADDATA reads transaction data from a text file
%   Each line in the text file is a transaction, and each transaction 
%   contains a list of numeric Id of items separated by space. It returns 
%   a binary matrix |transactions| and the vector of item Ids. 

switch nargin
    case 1 % preview the data by default
        preview = true;
end

% store each line of the file into cell array
fid = fopen(filename);
lines = textscan(fid,'%s','delimiter','\n');
lines = lines{1}; % flatten the cell array
fclose(fid);

% convert each row into a nested cell array of numbers
transactions = cell(size(lines));

for i = 1:length(lines)
    line = textscan(lines{i},'%d');
    transactions{i} = line{1}';
end

items = unique([transactions{:}]);

% preview the data
if preview
    disp('Showing the first five rows of the dataset...')
    for i = 1:5
        disp(transactions{i})
    end
end

end

