% Specify paths to training and testing files for Female and Male speakers
training_files_Female = dir('C:\Users\Dell\OneDrive\Documents\MATLAB\DSP_Assignment\Train\Female\*.wav');
testing_files_Female = dir('C:\Users\Dell\OneDrive\Documents\MATLAB\DSP_Assignment\Test\Female\*.wav');
training_files_Male = dir('C:\Users\Dell\OneDrive\Documents\MATLAB\DSP_Assignment\Train\Male\*.wav');
testing_files_Male = dir('C:\Users\Dell\OneDrive\Documents\MATLAB\DSP_Assignment\Test\Male\*.wav');

% ------------ Training -----------------------------

% Initialize data storage for features
data_Female = [];
data_Male = [];

% Specify parameters for pwelch
window = hamming(1024);  % You can choose a different window type
noverlap = 512;  % Overlapping samples between adjacent segments


% Process Female training files
for i = 1:length(training_files_Female)
    file_path = strcat(training_files_Female(i).folder,'\',training_files_Female(i).name);
    [y, fs] = audioread(file_path); % Read the audio file

    y = y - mean(y);
    y = bandpass(y, [300, 3400], fs);

    % Calculate PSD using pwelch
     [psd_Female, f] = pwelch(y, window, noverlap, [], fs);

    % Append all features as a row vector
    features_Female = psd_Female;

    % Append the merged features with all other features of the other files
    data_Female = [data_Female; features_Female];
    
end

% Calculate the average of the features
features_Female = mean(data_Female);
fprintf('The Frequency domain features of Female is \n');
disp(features_Female);

% Process Male training files
for i = 1:length(training_files_Male)
    file_path = strcat(training_files_Male(i).folder,'\',training_files_Male(i).name);
    [y, fs] = audioread(file_path);

   
     % Calculate PSD using pwelch
     [psd_Male, f] = pwelch(y, window, noverlap, [], fs);

    % Append all features as a row vector
    features_Male = psd_Male;
    
    % Append the merged features with all other features of the other files
    data_Male = [data_Male; features_Male];
end

% Calculate the average of the features
features_Male = mean(data_Male);
fprintf('The Frequency domain features of Male is \n');
disp(features_Male);

% ------------ Evaluation -----------------------------

% Initialize counters for True Positives, True Negatives, False Positives, and False Negatives
% to calculate the accuracy
TP = 0;
TN = 0;
FP = 0;
FN = 0;

% Process Female testing files
for i = 1:length(testing_files_Female)
    file_path = strcat(testing_files_Female(i).folder,'\',testing_files_Female(i).name);
    [y, fs] = audioread(file_path);


     % Calculate PSD using pwelch
     [psd_Female, f] = pwelch(y, window, noverlap, [], fs);

    % Append all features as a row vector
    features_y = psd_Female;

    % Make the decision based on cosine distance
    if(pdist([mean(features_y); mean(features_Female)], 'cosine') < pdist([mean(features_y); mean(features_Male)], 'euclidean'))
        fprintf('Test file [Female] #%d classified as Female, PSD = %d \n', i,mean(features_y));
        TP = TP + 1; % True Positive
    else
        fprintf('Test file [Female] #%d classified as Male, PSD = %d \n', i,mean(features_y));
        FN = FN + 1; % False Negative
    end
end

% Process Male testing files
for i = 1:length(testing_files_Male)
    file_path = strcat(testing_files_Male(i).folder,'\',testing_files_Male(i).name);
    [y, fs] = audioread(file_path);

     % Calculate PSD using pwelch
     [psd_Male, f] = pwelch(y, window, noverlap, [], fs);

    % Append all features as a row vector
    features_y = psd_Male;

    % Make the decision based on cosine distance
    if(pdist([mean(features_y); mean(features_Male)], 'cosine') > pdist([mean(features_y); mean(features_Female)], 'euclidean'))
        fprintf('Test file [Male] #%d classified as Female, PSD = %d\n', i , mean(features_y));
        FP = FP + 1; % False Positive
    else
        fprintf('Test file [Male] #%d classified as Male, PSD = %d\n', i,mean(features_y));
        TN = TN + 1; % True Negative
    end
end

% Calculate accuracy
accuracy = (TP + TN) / (TP + TN + FP + FN);
fprintf('Accuracy: %.2f%%\n', accuracy * 100);
