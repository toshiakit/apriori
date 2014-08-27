function Ck = aprioriGen(freqSets, k)
% APRIORIGEN generates candidate k-itemsets using Apriori algorithm
%   This function implements F_k-1 x F_k-1 method, which merges two pairs
%   (k-1)-itemsets to generate new k-itemsets if the first (k-2) items are
%   identical between the pair.
%
%   To learn more about the underlying alogrithm itself, please consult   
%   with Ch6 of http://www-users.cs.umn.edu/~kumar/dmbook/index.php 

    % generate candidate 2-itemsets
    if k == 2
        Ck = combnk(freqSets,2);
    else
        % generate candidate k-itemsets (k > 2)     
        Ck = [];
        numSets = size(freqSets,1);
        % generate two pairs of frequent itemsets to merge
        for i = 1:numSets
            for j = i+1:numSets
                % compare the first to k-2 items
                pair1 = sort(freqSets(i,1:k-2));
                pair2 = sort(freqSets(j,1:k-2));
                % if they are the same, merge
                if isequal(pair1,pair2)
                    Ck = [Ck; union(freqSets(i,:),freqSets(j,:))];
                end
            end
        end
    end
end

