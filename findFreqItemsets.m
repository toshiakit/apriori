function [F,S,items] = findFreqItemsets(transactions,minSup,oneItemsets)
%FINDFREQITEMSETS generates frequent itemsets using Apriori method
%   |transactions| is a nested cell array of transaction data or a table
%   with |Value| column that contains such cell array. Each row contains a
%   nested cell array of items in a single transaction. If supplied as a
%   table, it also needs |Key| column with a cell array of transaction ids.
%
%   |minSup| is a scalar that represents the minimum support threshold.
%   Itemsets that meet this criteria are 'frequent' itemsets.
%
%   |oneItemSets| is an optional table that list all single items that
%   appear in |transactions| along with their frequencies. Items are listed
%   in |Key| column and corresponding counts in |Value| column.
%
%   |items| is a cell array of unique items. 
% 
%   |F| is a structure array of frequent itemsets that meet that
%   criteria. Items are represented as indices of cell arrat |items|.
%
%   |S| is a Map object that maps itemsets to their support values. Items
%   are represented as indices of cell arrat |items|.
%
%   To learn more about the underlying alogrithm itself, please consult   
%   with Ch6 of http://www-users.cs.umn.edu/~kumar/dmbook/index.php 

    % check the number of input arguments
    narginchk(2, 3)
    if iscell(transactions)
        transactions = table(num2cell(1:length(transactions))',transactions,'VariableNames',{'Key','Value'});
    end
    
    if nargin == 2
        items = transactions.Value;
        [uniqItems,~,idx] = unique([items{:}]');
        oneItemsets = table(uniqItems,num2cell(accumarray(idx,1)),'VariableNames',{'Key','Value'});
    end
    
    % get the total number of transactions
    N = height(transactions);
    % sort the tables
    transactions = sortrows(transactions,'Key');
    oneItemsets = sortrows(oneItemsets,'Key');
    % get all frequent 1-itemsets
    [F,S,items] = getFreqOneItemsets(oneItemsets,N,minSup);
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
        [Fk, support] = pruneCandidates(transactions,Ck,N,items,minSup);

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
    

    function [F1,S,C1]= getFreqOneItemsets(T,N,minSup)
    % GETFREQ1ITEMSETS geneates all frequent 1-itemsets
    %   1-items are generated from 1-itemset table |T| and pruned with the
    %   minimum support threshold |minSup|.
    
        % get 1-itemset candidates
        C1 = T.Key;
        % get their count
        count = cell2mat(T.Value);
        % calculate support for all candidates
        sup = count ./N;
        % create a map object and store support data
        S = containers.Map();
        for j = 1:length(C1)
            S(num2str(j)) = sup(j);
        end
        % prune candidates by minSup
        freqSet = find(sup >= minSup);
        % store result in a structure array
        F1 = struct('freqSets',freqSet);
    end

    function [Fk,support] = pruneCandidates(T,Ck,N,items,minSup)
    %PRUNECANDIDATES returns frequent k-itemsets 
    %   Compute support for each candidndate in |Ck| by scanning
    %   transactions table |T| to identify itemsets that clear |minSup|
    %   threshold

        % calculate support count for all candidates
        support = zeros(size(Ck,1),1);
        % for each transaction
        for l = 1:N
            % get the item idices
            t = find(ismember(items, T.Value{l}));
            % increment the support count
            support(all(ismember(Ck,t),2)) = support(all(ismember(Ck,t),2)) + 1;
        end
        % calculate support
        support = support./N;
        
        % return the candidates that meet the criteria
        Fk = Ck(support >= minSup,:);
    end

end

