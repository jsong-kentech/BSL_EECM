% 
% Battery Software Lab, KENTECH
% 2023 07 22
% CONFIGURATION


%% Configs from the main file
Config.cellid = cell_id_string;
Config.cycle_last = N_cycle;

% beginning condition
Config.cycle_initial = 1;
Config.SOC0 = 0;

% configs for the cell id
Config.Vmax = 4.45; % [V]
Config.Vmin = 3.0; % [V] 

% configs for simulation
Config.dt = 30; % [sec] time step for simulation
Config.thermal_dyanmics_flag = 0; % on/off thermal model

%% Set up paths

% folders
Config.folder_config = pwd; % path to folder containing config 
Config.folder_model = 'G:\공유 드라이브\Battery Software Lab\EECM\example_1';
Config.folder_engine = [pwd filesep 'engine'];
    % assuming simulation and config are in the same folder,
    % where engine files are in a subfolder.
    addpath(Config.folder_config, Config.folder_engine)

% file fullpaths
Config.path_RRmodel = [Config.folder_model filesep 'example1_RRmodel.mat'];
Config.path_ocv_chg = [Config.folder_model filesep 'example1_OCV_chg.mat'];
Config.path_ocv_dch = [Config.folder_model filesep 'example1_OCV_dis.mat'];
Config.path_ocv = Config.path_ocv_chg;  % temporally use the charging ocv for all purposes
Config.path_aging = [Config.folder_model filesep 'example_1_aging_parameters.mat'];


%% Load RR model
load(Config.path_RRmodel) % variable name: 'DataBank';
Config.RR = DataBank;
clear DataBank

Config.Cap0 = mean(Config.RR.Qmax); % initial cell capacity
Config.I_1C = mean(Config.RR.I_1C); % norminal cell capacity
Config.RR.SOC_grid = linspace(0,1,201)'; % SOC grid defined


% Change the structure 
    % [soc column, R column(s)]
    % soc column are the same for different rates
for i = 1:size(Config.RR.Rss,1)
    for j = 1:size(Config.RR.Rss,2)
        y = zeros(length(Config.RR.SOC_grid),size(Config.RR.Rss{i,j},2));
        y(:,1) = Config.RR.SOC_grid;
        for k = 2:size(Config.RR.Rss{i,j},2) % for case there is more than one R columns
            y(:,k) = interp1(Config.RR.Rss{i,j}(:,1),Config.RR.Rss{i,j}(:,k),y(:,1),'linear','extrap');
        end
        Config.RR.Rss{i,j} = y;
    end
end
    % same for Vref
for i = 1:size(Config.RR.Vref,1)
    for j = 1:size(Config.RR.Vref,2)
        y = zeros(length(Config.RR.SOC_grid),size(Config.RR.Vref{i,j},2));
        y(:,1) = Config.RR.SOC_grid;
        for k = 2:size(Config.RR.Vref{i,j},2) % for case there is more than one Vref columns
            y(:,k) = interp1(Config.RR.Vref{i,j}(:,1),Config.RR.Vref{i,j}(:,k),y(:,1),'linear','extrap');
        end
        Config.RR.Vref{i,j} = y;
    end
end


%% Load OCV 
load(Config.path_ocv) % variable name: 'OCV'
Config.OCV = OCV;
clear OCV


%% Load Aging Parameters
aging_para = load(Config.path_aging); % field name: 'opt_para'
Config.aging_para = aging_para.opt_para;
clear aging_para

Config.V_th = 4.3;

%% Thermal model setting
% skipped



%% Post prcessing settings
% skipped









