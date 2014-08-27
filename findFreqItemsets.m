function [F,S] = findFreqItemsets(T, minSup)
%FINDFREQITEMSETS generates frequent itemsets using Apriori method
%   |T| is a nested cell array of transaction data. Each row contains 
%   indices of the items in a single transaction as a vector. 
%   |minSup| is a scalar that represents the minimum support threshold. 
%   Itemsets that meet this criteria are 'frequent' itemsets.
%   |F| is a structure array of frequent itemsets that meet that criteria.
%   |S| is a Map object that maps itemsets to their support values. 
%
%   To learn more about the underlying alogrithm itself, please consult   
%   with Ch6 of http://www-users.cs.umn.edu/~kumar/dmbook/index.php 

    % get all frequent 1-itemsets
    [F,S] = getFreqOneItemsets(T, minSup);
    if isempty(F.freqSets)
        fprintf('No frequent itemset found at minSup = %.2f\n',minSup)
        return
    end
    
    % get all frequent k-itemsets where k >= 2
    k = 2;
    while true
        % generate candidate itemsets
        Ck = aprioriGen(F(k-1).freqSets, k);
        % prune candidates below minimum support threshold
        [Fk, support] = pruneCandidates(T,Ck,minSup);

        % update support data; if empty, exit the loop
        if ~isempty(support)
            % create a map object to store suppor data
            mapS = containers.Map();
            % convert vectors to chars for use as keys
            for i = 1:length(support)
                mapS(num2str(Ck(i,:))) = support(i);
            end
            % update S
            S = [S; mapS];
        else
            break;
        end
        % store the frequent itemsets above minSup
        % if empty, exit the loop
        if ~isempty(Fk)
            F(k).freqSets = Fk;
            k = k + 1;
        else
            break;
        end
    end
    

    function [F1,S]= getFreqOneItemsets(T, minSup)
    % GETFREQ1ITEMSETS geneates all frequent 1-itemsets
    %   1-items are generated from transactions |T| and pruned with the
    %   minimum support threshold |minSup|. |T| is a nested cell array of 
    %   vectors.

        % number of transactions
        N = length(T);
        % get 1-itemset candidates and their indices
        [C1,~,idx] = unique([T{:}]);
        % calculate support for all candidates
        sup = accumarray(idx,1)./N;
        % create a map object to store suppor data
        S = containers.Map();
        % convert vectors to chars for use as keys 
        for j = 1:length(C1)
            S(num2str(C1(j))) = sup(j);
        end
        % prune candidates by minSup
        freqSet = C1(sup >= minSup)';
        % store result in a structure array
        F1 = struct('freqSets',freqSet);
    end

    function [Fk,support] = pruneCandidates(T,Ck,minSup)
    %PRUNECANDIDATES returns frequent k-itemsets 
    %   Compute support for each candidndate in |Ck| by scanning 
    %   transactions |T| and identify itemsets that clear |minSup|
    %   threshold

        % number of transactions
        N = size(T,1);
        % calculate support count for all candidates
        support = zeros(size(Ck,1),1);
        % for each transaction
        for l = 1:N
            % get the item idices
            t = T{l};
            % increment the support count
            support(all(ismember(Ck,t),2)) = support(all(ismember(Ck,t),2)) + 1;
        end
        % calculate support
        support = support./N;
        
        % return the candidates that meet the criteria
        Fk = Ck(support >= minSup,:);
    end

end

