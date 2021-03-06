clear all;
rng('shuffle');
% Parse ReLe dataset
initialPath = '/home/shirokuma/Desktop/AAAI2017-GP/Discrete';

% Algorithm
gamma = 0.9;
stateDim = 2;
nActions = 11;
nIterations = 10;
lengthScale = [0.5 0.5]';
signalSigma = 1;
noiseSigma = 1;
nExperiments = 100;
algorithms = {'fqi', 'dfqi', 'wfqi'};

nEpisodes = 25;
horizon = 100;
rewardNoiseSigma = 0;

nEpisodesStr = strcat(int2str(nEpisodes), 'Episodes');

J = zeros(nExperiments, length(algorithms));

parfor e = 0:nExperiments - 1
    fprintf('Experiment: %d\n', e + 1);
    
    % Make sars dataset
    sars = collectDataset(rewardNoiseSigma, nEpisodes, horizon, nActions);
    
    for i = 1:length(algorithms)
        algorithm = char(algorithms(i));

        if strcmp(algorithm, 'fqi')
            % Fitted Q-Iteration
            gps = FQI(sars, gamma, stateDim, nActions, nIterations, lengthScale, signalSigma, noiseSigma);
            
            fqiJ = evaluatePolicy(gps, nActions, horizon);
        elseif strcmp(algorithm, 'dfqi')
            % Double Fitted Q-Iteration
            shuffle = false;
            gps = doubleFQI(sars, gamma, stateDim, nActions, nIterations, lengthScale, signalSigma, noiseSigma, shuffle);
            
            dFqiJ = evaluatePolicy(gps, nActions, horizon);
        elseif strcmp(algorithm, 'wfqi')
            % W-Fitted Q-Iteration
            noisyTest = false;
            nSamples = 500;
            gps = WFQI(sars, gamma, stateDim, nActions, nIterations, lengthScale, signalSigma, noiseSigma, noisyTest, nSamples);
            
            wFqiJ = evaluatePolicy(gps, nActions, horizon);
        end
    end
    
    J(e + 1, :) = [fqiJ, dFqiJ, wFqiJ];
end

savePath = strcat(initialPath, '/', nEpisodesStr, '/');
save(strcat(savePath, 'results.txt'), 'J', '-ascii');
