% Specify paths to training and testing files for Female and Male speakers
training_files_Female = dir('C:\Users\Dell\OneDrive\Documents\MATLAB\DSP_Assignment\Train\Female\*.wav');
testing_files_Female = dir('C:\Users\Dell\OneDrive\Documents\MATLAB\DSP_Assignment\Test\Female\*.wav');
training_files_Male = dir('C:\Users\Dell\OneDrive\Documents\MATLAB\DSP_Assignment\Train\Male\*.wav');
testing_files_Male = dir('C:\Users\Dell\OneDrive\Documents\MATLAB\DSP_Assignment\Test\Male\*.wav');

% ------------ Training -----------------------------

% Initialize data storage for features
data_Female = [];
data_Male = [];


% Process Female training files
for i = 1:length(training_files_Female)
    file_path = strcat(training_files_Female(i).folder,'\',training_files_Female(i).name);
    [y, fs] = audioread(file_path); % Read the audio file

    y = y - mean(y);

    % **Apply filtering to reduce noise**
    y = bandpass(y, [300, 3400], fs);  % Filter within typical human voice frequency range

    % Calculate the energy
    energy_Female = sum(y.^2);

    % Divide the signal into 3 parts and calculate the ZCR for each part
    ZCR_Female1 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
    ZCR_Female2 = mean(abs(diff(sign(y(floor(end/3):floor(end*2/3))))))./2;
    ZCR_Female3 = mean(abs(diff(sign(y(floor(end*2/3):end)))))./2;


    % Append all features as a row vector
    features_Female = [ ZCR_Female1  ZCR_Female2  ZCR_Female3 energy_Female];

    % Append the merged features with all other features of the other files
    data_Female = [data_Female; features_Female];
    
end

% Calculate the average of the features
features_Female = mean(data_Female);
disp("Female Time domain Features");
disp(features_Female);

% Process Male training files
for i = 1:length(training_files_Male)
    file_path = strcat(training_files_Male(i).folder,'\',training_files_Male(i).name);
    [y, fs] = audioread(file_path);

    y = y - mean(y);

    % **Apply filtering to reduce noise**
    y = bandpass(y, [300, 3400], fs);  % Filter within typical human voice frequency range

    % Calculate the energy
    energy_Male = sum(y .^2);

    % Divide the signal into 3 parts and calculate the ZCR for each part
    ZCR_Male1 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
    ZCR_Male2 = mean(abs(diff(sign(y(floor(end/3):floor(end*2/3))))))./2;
    ZCR_Male3 = mean(abs(diff(sign(y(floor(end*2/3):end)))))./2;

     % Append all features as a row vector
    features_Male = [ZCR_Male1 ZCR_Male2 ZCR_Male3 energy_Male];

    % Append the merged features with all other features of the other files
    data_Male = [data_Male; features_Male];
    
end

% Calculate the average of the features
features_Male = mean(data_Male);
disp("Male Time domain Features");
disp(features_Male);

% ------------ Evaluation -----------------------------

% Initialize counters for True Positives, True Negatives, False Positives, and False Negatives
% to calculate the accuracy
TP = 0;
TN = 0;
FP = 0;
FN = 0;

% Initialize data storage for correlation coefficients
correlation_Female = zeros(length(testing_files_Female), 1);
correlation_Male = zeros(length(testing_files_Male), 1);

% Process Female testing files
for i = 1:length(testing_files_Female)
    file_path = strcat(testing_files_Female(i).folder, '\', testing_files_Female(i).name);
    [y, fs] = audioread(file_path);

    y = y - mean(y);

    % **Apply filtering to reduce noise**
    y = bandpass(y, [300, 3400], fs);  % Filter within typical human voice frequency range

   
    % Divide the signal into 3 parts and calculate the ZCR for each part
    ZCR_Female1 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
    ZCR_Female2 = mean(abs(diff(sign(y(floor(end/3):floor(end*2/3))))))./2;
    ZCR_Female3 = mean(abs(diff(sign(y(floor(end*2/3):end)))))./2;

    % Calculate the energy
    energy_Female = sum(y.^2);

     % Append all features as a row vector
     features_y = [ZCR_Female1 ZCR_Female2 ZCR_Female3 energy_Female];

    % Calculate correlation coefficient with female training data
    correlation_Female(i) = corr(features_y', features_Female');
    
    if (correlation_Female(i) > 0.5)
        fprintf('Test file [Female] #%d classified as Female, ZCR = %d %d %d , Energy = %d  \n', i,ZCR_Female1, ZCR_Female2, ZCR_Female3 ,energy_Female);
        TP = TP + 1; % True Positive
    else
        fprintf('Test file [Female] #%d classified as Male, ZCR = %d %d %d , Energy = %d \n', i, ZCR_Male1,ZCR_Male2,ZCR_Male3,energy_Male);
        FN = FN + 1; % False Negative
    end
end

% Process Male testing files
for i = 1:length(testing_files_Male)
    file_path = strcat(testing_files_Male(i).folder, '\', testing_files_Male(i).name);
    [y, fs] = audioread(file_path);

    y = y - mean(y);

    % **Apply filtering to reduce noise**
    y = bandpass(y, [300, 3400], fs);  % Filter within typical human voice frequency range

    % Divide the signal into 3 parts and calculate the ZCR for each part
    ZCR_Male1 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
    ZCR_Male2 = mean(abs(diff(sign(y(floor(end/3):floor(end*2/3))))))./2;
    ZCR_Male3 = mean(abs(diff(sign(y(floor(end*2/3):end)))))./2;

    % Calculate the energy
    energy_Male = sum(y.^2);

     % Append all features as a row vector
    features_Male = [ZCR_Male1 ZCR_Male2 ZCR_Male3 energy_Male];

    % Calculate correlation coefficient with male training data
    correlation_Male(i) = corr(features_y', features_Male');
    
    if (correlation_Male(i) > 0.5)
        fprintf('Test file [Male] #%d classified as Male, ZCR = %d %d %d , Energy = %d \n', i, ZCR_Male1,ZCR_Male2,ZCR_Male3,energy_Male);
        TN = TN + 1; % True Negative
    else
        fprintf('Test file [Male] #%d classified as Female, ZCR = %d %d %d , Energy = %d  \n', i,ZCR_Female1, ZCR_Female2, ZCR_Female3 ,energy_Female);
        FP = FP + 1; % False Positive
    end
end


% Calculate accuracy
accuracy = (TP + TN) / (TP + TN + FP + FN);
fprintf('Accuracy: %.2f%%\n', accuracy * 100);
