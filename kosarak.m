% |loadData.m| processes the text file into a cell array of vectors. Each 
% row contains a number that represents a web page. 

clearvars; close all; clc;
clickstream = loadData('clickstream10k.dat');

minSup = 0.03; % minimum support threshold 0.03
fprintf('Processing dataset with minimum support threshold = %.2f\n...\n', minSup)
[F,S] = findFreqItemsets(clickstream, minSup);
fprintf('Frequent Itemsets Found: %d\n', sum(arrayfun(@(x) size(x.freqSets,1), F)))
fprintf('Max Level              : k = %d\n', length(F))
fprintf('Number of Support Data : %d\n\n', length(S))

%%
% Now let's generate association rules.

minConf = 0.8;
rules = generateRules(F,S,minConf);
fprintf('Minimum Confidence     : %.2f\n', minConf)
fprintf('Rules Found            : %d\n\n', length(rules))

% for i = 1:length(rules)
%     disp([sprintf('{%3d}',rules(i).Ante),' => ',...
%         sprintf('{%3d}', rules(i).Conseq),...
%         sprintf('     Conf: %.2f ',rules(i).Conf),...
%         sprintf('Lift: %.2f ',rules(i).Lift),...
%         sprintf('Sup: %.2f',rules(i).Sup)])
% end

%%

nodes = unique([[rules.Ante],[rules.Conseq]]);

% create an adjacency matrix
AdjMat = zeros(length(nodes));
for i = 1:length(rules)
    for j = 1:length(rules(i).Ante)
        for k = 1:length(rules(i).Conseq)
            source = rules(i).Ante(j);
            target = rules(i).Conseq(k);
            AdjMat(nodes == source,nodes == target) =...
                AdjMat(nodes == source,nodes == target) + 1;
        end
    end
end

% convert the nodes to cell array of string
ids = arrayfun(@(x) num2str(x), nodes,'UniformOutput',false);
% create a biograph object from the matrix
graph = biograph(AdjMat,ids,'ShowWeights','on');
% optimize the graph layout
dolayout(graph);
% visualize the graph. 
view(graph)