% d='/Users/carolinehartley/Desktop/transfusion/';
% files=dir(strcat(d,"*_numerics.csv"));
% 
% for i=1:length(files)
%     files(i).name
%     load_monitor_data(files(i).name, d, d)
% end

clear all
%% find data - must run this section first
% define_subjects_Oxford

%% plot raw traces around transfusion
% t_limits = [-6, 12]; % hours
% t_baseline = [-6, 0]; % hours
% plot_vital_signs_individual(files, t_limits, t_baseline,0) %NB change last number to 0 if don't want to baseline correct or 1 if you do
clear all
close all

% Default
dataset_label = 'Oxford';

[ret, name] = system('hostname');
name = strip(name);
if strcmp(name, 'cmm0958')
    addpath('lib/palm/palm-alpha119/')
    dataset_label = 'Stockholm';
end

%% plot average and find responders and non-responders

if exist(fullfile(pwd, 'functions'), 'dir')
    addpath(fullfile(pwd, 'functions'))
else
    error('check if "functions"-folder is part of the current folder')
end

if strcmp(dataset_label, 'Stockholm')
    define_subjects_Stockholm
end

t_window = 1; % hours
t_overlap = 0.5; % hours
t_limits = [-12, 12]; % hours
t_baseline = [-6, 0]; % hours
check_sig = true;
std_threshold = 1.0;
[signals, responders,signal_increase,signal_decrease,var_labels,subjectid,studyid,sig_quality,tld] = plot_vital_signs(files, t_limits, t_window, t_overlap, t_baseline, ...
       check_sig, dataset_label, std_threshold);
%%
if 1 %create table of results and save as excel files
    increase_responder=zeros(size(responders));
    decrease_responder=zeros(size(responders));
    increase_responder(find(responders==2))=1;
    increase_responder(find(responders==1))=1;
    decrease_responder(find(responders==3))=1;
    decrease_responder(find(responders==1))=1;
    % Create one table for each variable of interest
    for v=1:length(var_labels)
        T=table(subjectid, studyid, tld.pre_post_hb(1,:)',tld.pre_post_hb(2,:)',tld.TESTOD_CurrentVentilation',tld.TESTOD_MostRecentWeight', tld.PMA', tld.BIRTH_Gender',increase_responder(v,:)',decrease_responder(v,:)',signal_increase(v,:)',signal_decrease(v,:)', ...
            'VariableNames',{'Subject ID';'Study ID';'StartHB';'EndHB';'TESTOD_CurrentVentilation'; 'TESTOD_MostRecentWeight';'PMA';'BIRTH_Gender';'Increase Response';'Decrease Response';'Average Signal Increase';'Average Signal Decrease'});
       
        writetable(T,cell2mat(strcat('../results/tables/', var_labels(v),sprintf('_%s.xlsx',dataset_label))));
    end
end
close all

plot_binary_responder

sdfsdf

%% Berlin

define_subjects_Berlin;
t_window = 1; % hours
t_overlap = 0.5; % hours
t_limits = [-6, 12]; % hours
t_baseline = [-6, 0]; % hours
check_sig = true;
dataset_label = 'Berlin';
std_threshold = 3;
ibi_boolean = false;
plot_vital_signs(files, t_limits, t_window, t_overlap, t_baseline, check_sig, dataset_label, std_threshold)