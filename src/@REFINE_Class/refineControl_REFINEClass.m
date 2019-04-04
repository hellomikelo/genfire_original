%%  refineControl %%

%% Control function for running angular refinements
%%  refinement_pars    - parameters produced using getRefinementPars
%%  num_refinements    - integer number of refinement loops to run 

%%outputs:
%%  refine_results      - output structure containing refinement parameters and resulting metrics

%% Author: Alan (AJ) Pryor, Jr.
%% Jianwei (John) Miao Coherent Imaging Group
%% University of California, Los Angeles
%% Copyright (c) 2015-2016. All Rights Reserved.

function obj = refineControl_REFINEClass(obj, num_refinements)
for refine_num = 1:num_refinements
    fprintf('Refinement iteration #%d\n',refine_num)
    
    obj = refineOrientation_REFINEClass(obj); 
    
    obj = updateProjections_REFINEClass(obj);

    obj.RECONSTRUCTOR = obj.RECONSTRUCTOR.CheckPrepareData();
    obj.RECONSTRUCTOR = obj.RECONSTRUCTOR.runGridding();
    
    obj.RECONSTRUCTOR = obj.RECONSTRUCTOR.runGENFIREiteration_GENFIREClass();

end
end