%%  updateProjections %%

%%updates input projections and angles based upon results of refinement
%%inputs:
%%  original_projections - original N x N x num_projections array that produced the model
%%  refinement_pars      - output of refineOrientation

%%outputs:
%%  projections   - new projections
%%  euler_angles  - new euler angles

%% Author: Alan (AJ) Pryor, Jr.
%% Jianwei (John) Miao Coherent Imaging Group
%% University of California, Los Angeles
%% Copyright (c) 2015-2016. All Rights Reserved.

function obj = updateProjections_REFINEClass(obj)
[dimx,dimy,num_proj] = size(obj.refineFullProjections);
ncx = round((dimx+1)/2);
ncy = round((dimy+1)/2);
bin_factor = obj.bin_factor;
euler_angles = zeros(num_proj,3);
original_projections = obj.refineFullProjections;

ShiftAr = zeros(num_proj,2);
for proj_num = 1:num_proj
    centers_x = obj.x_centers(proj_num,:);
    centers_y = obj.y_centers(proj_num,:);
    metrics   = obj.metrics(proj_num,:);
    phis      = obj.phis(proj_num,:);
    thetas    = obj.thetas(proj_num,:);
    psis      = obj.psis(proj_num,:);
    if obj.maximize
        best_ind = find(metrics==max(metrics(:)),1);
    else
        best_ind = find(metrics==min(metrics(:)),1);
    end
    best_center_x = centers_x(best_ind);
    best_center_y = centers_y(best_ind);
    euler_angles(proj_num,1) = phis(best_ind);
    euler_angles(proj_num,2) = thetas(best_ind);
    euler_angles(proj_num,3) = psis(best_ind);
    shiftX = ncx - (best_center_x * bin_factor - (bin_factor - 1)); % to understand the subtraction, consider that the center pixel of a 100x100 array is 51, and if this
    % was an array that had been binned by 4 then the original array was
    % 400x400 and the center should be at 201 which is 51*4-3
    shiftY = ncy - (best_center_y * bin_factor - (bin_factor - 1));
    original_projections(:,:,proj_num) = circshift(original_projections(:,:,proj_num),[shiftX, shiftY]);
    ShiftAr(proj_num,:) = [shiftX, shiftY];
end
obj.refineFullProjections = original_projections;

% recalculate the angles to make the reference index angles be at the same
% given orientation
euler_angles = reorient_Angles(euler_angles,obj.RefineReferenceAngleInd,obj.RefineZeroCenterFlag,obj.RefineReferenceAngletoSet);

obj.refineAngles = euler_angles;

if obj.FullEvolutionRecord==1
  obj.AngleEvolution(:,:,end+1) = euler_angles;
  obj.ShiftEvolution(:,:,end+1) = ShiftAr;
end