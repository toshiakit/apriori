function [B, items] = numeralize(A)
%NUMERALIZE Summary of this function goes here
%   Detailed explanation goes here

items = unique([A{:}]);
B = cell(size(A));
for i = 1:size(A,1)
    B{i} = find(ismember(items,A{i,:}));
end

end

