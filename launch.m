function launch()
close all;
clc;
clear classes;
% tic;
global x_tar y_tar theta_tar;
global f1 f2;

global persuit_E1 persuit_E2 R1_engage R2_engage R3_engage R4_engage R1E1 R1E2 R2E1 R2E2 R3E1 R3E2 R4E1 R4E2 

persuit_E1=0;
persuit_E2=0;
R1_engage=0;
R2_engage=0;
R3_engage=0;
R4_engage=0;
R1E1=0;
R1E2=0;
R2E1=0;
R2E2=0;
R3E1=0;
R3E2=0;
R4E1=0;
R4E2=0;



% global  
x_tar=0;
y_tar=0;
theta_tar=0;
f1=0;
if (isdeployed)
    [path, folder, ~] = fileparts(ctfroot);
    root_path = fullfile(path, folder);
else
    root_path = fileparts(mfilename('fullpath'));
end
addpath(genpath(root_path));
 app = simiam.ui.AppWindow(root_path, 'launcher');
app.load_ui();

end
