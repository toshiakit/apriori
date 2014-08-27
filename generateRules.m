function rules = generateRules(F,S,minConf)
%GENERATERULES returns the association rules found from the frequent
%itemsets based on the minimum confidence threshold |minConf|. 
%Association rules are expressed as {ante} => {conseq}.
%   |F| is a structure array of frequent itemsets
%   |S| is a Map object that maps itemsets to their support values
%   |rules| is a structure array of association rules that meet |minConf|
%   criteria, along with confidence, lift and support metrics. 
%
%   To learn more about the underlying alogrithm itself, please consult   
%   with Ch6 of http://www-users.cs.umn.edu/~kumar/dmbook/index.php 

    rules = struct('Ante',{},'Conseq',{},'Conf',{},'Lift',{},'Sup',{});
    % iterate over itemset levels |k| where k >= 2
    for k = 2:length(F)
        % iterate over k-itemsets 
        for n = 2:size(F(k).freqSets,1)
            % get one k-itemset
            freqSet = F(k).freqSets(n,:);
            % get 1-item consequents from the k-itemset
            H1 = freqSet';
            % if the itemset contains more than 3 items
            if k > 2
                % go to ap_genrules()
                rules = ap_genrules(freqSet,H1,S,rules,minConf);
            else
                % go to pruneRules()
                [~,rules] = pruneRules(freqSet,H1,S,rules,minConf);
            end
        end
    end
    
    function rules = ap_genrules(Fk,H,S,rules,minConf)
    %AP_GENRULES generate candidate rules from rule consequent
    %   |Fk| is a row vector representing a frequent itemset
    %   |H| is a matrix that contains a rule consequents per row
    %   |S| is a Map object that stores support values
    %   |rules| is a structure array that stores the rules
    %   |minConf| is the threshold to prune the rules
    
        m = size(H,2); % size of rule consequent
        % if frequent itemset is longer than consequent by more than 1
        if length(Fk) > m+1
            % prune 1-item consequents by |minConf|
            if m == 1
                [~,rules] = pruneRules(Fk,H,S,rules,minConf);
            end
            % use aprioriGen to generate longer consequents
            Hm1 = aprioriGen(H,m+1);
            % prune consequents by |minConf|
            [Hm1,rules] = pruneRules(Fk,Hm1,S,rules,minConf);
            % if we have consequents that meet the criteria, recurse until
            % we run out of such candidates
            if ~isempty(Hm1)
                rules = ap_genrules(Fk,Hm1,S,rules,minConf);
            end
        end
    end

    function [prunedH,rules] = pruneRules(Fk,H,S,rules,minConf)
    %PRUNERULES calculates confidence of given rules and drops rule
    %candiates that don't meet the |minConf| threshold
    %   |Fk| is a row vector representing a frequent itemset
    %   H| is a matrix that contains a rule consequents per row
    %   |S| is a Map object that stores support values
    %   |rules| is a structure array that stores the rules
    %   |minConf| is the threshold to prune the rules
    %   |prunedH| is a matrix of consequents that met |minConf|
        
        % initialize a return variable
        prunedH = [];
        % iterate over the rows of H
        for i = 1:size(H,1);
            % a row in H is a conseq
            conseq = H(i,:);
            % ante = Fk - conseq 
            ante = setdiff(Fk, conseq);
            % retrieve support for Fk
            supFk =S(num2str(Fk));
            % retrieve support for ante
            supAnte =S(num2str(ante));
            % retrieve support for conseq
            supConseq =S(num2str(conseq));
            % calculate confidence
            conf = supFk / supAnte;
            % calculate lift
            lift = supFk/(supAnte*supConseq);
            
            % if the threshold is met
            if conf >= minConf
                % append the conseq to prunedH
                prunedH = [prunedH, conseq];
                % generate a rule
                rule = struct('Ante',ante,'Conseq',conseq,...
                    'Conf',conf,'Lift',lift,'Sup',supFk);
                % append the rule
                if isempty(rules)
                    rules = rule;
                else
                    rules = [rules, rule];
                end             
            end
        end
    end

end

