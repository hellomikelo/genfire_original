classdef REFINE_Class
  
    properties
      % properties with default values
      ang_step           = 1;
      ang_range          = 5;
      bin_factor         = 1;
      compare_func       = @alignByRFactor; % alternative is @alignByNormXCorr
      forwardProjection_func = @calculate3Dprojection_interp; % alternative is @calculate3Dprojection_Realspaceinterp
      oversampling_ratio = 2;
      num_refinements    = 1;    
      
      %in case of using real-space forward projector, RealProjection = 1
      RealProjection = 0;
      FullEvolutionRecord=0; % if this flag is 1, all euler_angles and shift vectors during all iterations will be recorded
                             % in AngleEvolution ShiftEvolution
      
      RefineReferenceAngleInd = 1; % Angle index for reference angle to be fixed
      RefineReferenceAngletoSet = [0 0 0]; % Reference angle will be fixed to this value
      RefineZeroCenterFlag = 0; % 0 for 0 to 180 deg theta convention
                                % 1 for -90 to 90 deg theta convention
                             
      % mask to be applied to forward projection before comparing with
      % given projections
      FPmask
                             
      % RECONSTRUCTOR is a MATLAB class object for tomographic
      % reconstruction. This can be GENFIRE, EST, SIRT, etc..
      % This will be initialed in constructor method
      RECONSTRUCTOR
      
      % properties which will be initialized in constructor
      ang_search_range
      phi_search_range   
      theta_search_range 
      psi_search_range   
      maximize          
      use_parallel             
      
      % properties which will be determined and used during the refinement process
      refineModel
      refineProjections  % projections used for refinement, possibly binned
      refineAngles
      refineFullProjections  % full projection, not binned      
      centers_x
      x_centers
      centers_y
      y_centers
      metrics  
      phis   
      thetas
      psis
      AngleEvolution
      ShiftEvolution
    end
    
    methods
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % constructor method
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % RECONSTRUCTOR should be set with constructor
      function obj = REFINE_Class(val)
        if  nargin > 0
          if strcmp(val,'GENFIRE')
            obj.RECONSTRUCTOR = GENFIRE_Class();
          else
            error('REFINEMENT: unknown reconstructor name!');
          end
        else
          % default RECONSTRUCTOR is GENFIRE
          obj.RECONSTRUCTOR = GENFIRE_Class();
        end
        
        %set default variables
        obj.ang_search_range    = -obj.ang_range:obj.ang_step:obj.ang_range;%vector of angular displacements to search
        obj.phi_search_range    = obj.ang_search_range;%vector of angular displacements to search phi
        obj.theta_search_range  = obj.ang_search_range;%vector of angular displacements to search theta
        obj.psi_search_range    = obj.ang_search_range;%vector of angular displacements to search psi

      % calculated backprojection. Must be of the form [metric, new_center_x, new_center_y] = function(input_img,calc_img) where
      % metric is the value for R-factor, Xcorr, etc and new_center_x is the
      % optimal location of the center found for input_img based upon comparison
      % with calc_img
        obj.maximize            = false;%determines whether metric from compare_func should be maximized or minimized
                                        % true for NormXcorr false
                                        % for Rfactor
        obj.use_parallel        = true;%use parallel (parfor) where applicable    

      end
      
      
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % declare long methods in external files
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      obj = updateProjections_REFINEClass(obj);
      obj = refineOrientation_parallel_REFINEClass(obj);
      obj = refineOrientation_serial_REFINEClass(obj);      
      
      
      
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % declare short methods in this file
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
      % method for setting serach range from range and step input
      function obj = set_angle_range_step(obj,ang_range,angle_step)
        obj.ang_search_range    = -ang_range:angle_step:ang_range;%vector of angular displacements to search
        obj.phi_search_range    = obj.ang_search_range;%vector of angular displacements to search phi
        obj.theta_search_range  = obj.ang_search_range;%vector of angular displacements to search theta
        obj.psi_search_range    = obj.ang_search_range;%vector of angular displacements to search psi
      end
       
      
      % refineControl method (main workhorse for this REFINE class)
      function obj = refineControl_REFINEClass(obj, num_refinements)
        
        obj=obj.CheckParameters();
        
        for refine_num = 1:num_refinements
            fprintf('Refinement iteration #%d\n',refine_num)
            
            % set initial (or updated) projection and angles in RECONSTRUCTOR for next
            % reconstruction
            obj = obj.set_projections_to_RECONSTRUCTOR;      
            obj = obj.set_angles_to_RECONSTRUCTOR;              
            
            % run RECONSTRUCTOR reconstruction. Note that the
            % RECONSTRUCTOR here can be any tomographic reconstruction
            % object, including EST, GENFIRE, SIRT, etc.
            obj.RECONSTRUCTOR = obj.RECONSTRUCTOR.CheckPrepareData();
            obj.RECONSTRUCTOR = obj.RECONSTRUCTOR.runGridding();
            obj.RECONSTRUCTOR = obj.RECONSTRUCTOR.runGENFIREiteration_GENFIREClass();
            
            % get reconstructed model from RECONSTRUCTOR
            obj = obj.get_model_from_RECONSTRUCTOR();            
           
            % apply binning for refinement
            obj = obj.apply_binning();

            % run orientation refinement
            obj = obj.refineOrientation_REFINEClass(); 

            % update projection and angles 
            obj = obj.updateProjections_REFINEClass();    

        end
      end
      
      % refineOrientation method, depends on parallel or serial
      function obj = refineOrientation_REFINEClass(obj)
      % run serial or parallel depending on what was set
        if obj.use_parallel;
            obj = obj.refineOrientation_parallel_REFINEClass();
        else
            obj = obj.refineOrientation_serial_REFINEClass();
        end

      end

      % copy reconstructed model from RECONSTRUCTOR to refineModel property
      function obj = get_model_from_RECONSTRUCTOR(obj)
        obj.refineModel = obj.RECONSTRUCTOR.reconstruction;
      end
      
      % copy projections from RECONSTRUCTOR to refineFullProjections property
      function obj = get_projections_from_RECONSTRUCTOR(obj)        
        obj.refineFullProjections = obj.RECONSTRUCTOR.InputProjections;        
      end
      
      % copy angles from RECONSTRUCTOR to refineAngles property
      function obj = get_angles_from_RECONSTRUCTOR(obj)
        obj.refineAngles = obj.RECONSTRUCTOR.InputAngles;
      end
      
      % copy current refineFullProjections to RECONSTRUCTOR 
      function obj = set_projections_to_RECONSTRUCTOR(obj)
        obj.RECONSTRUCTOR.InputProjections = obj.refineFullProjections;
      end
      
      % copy current refineAngles to RECONSTRUCTOR 
      function obj = set_angles_to_RECONSTRUCTOR(obj)
        obj.RECONSTRUCTOR.InputAngles = obj.refineAngles;
      end
      
      
      % set parameters for REFINE class
      function obj=set_parameters(obj,varargin)
        if mod(length(varargin),2) ~= 0
            error('REFINEMENT: Additional argument list not divisible by 2. Options should be ''key'',''value'' pairs.')
        end

        % Apply user-provided options
        par_number = 1;
        while par_number < length(varargin)
            if isprop(obj,varargin{par_number})
                if strcmp(varargin{par_number},'ang_search_range')
                  obj.(varargin{par_number}) = varargin{par_number+1};
                  obj.phi_search_range = varargin{par_number+1};
                  obj.theta_search_range = varargin{par_number+1};
                  obj.psi_search_range = varargin{par_number+1};
                else
                  obj.(varargin{par_number}) = varargin{par_number+1};
                end
                par_number = par_number + 2;
            else
                error('REFINEMENT: Invalid option %s provided.',varargin{par_number})
            end
        end
      end
      
      function obj = CheckParameters(obj)                
        % check size of FPmask
        if isempty(obj.FPmask)
          obj.FPmask = ones(size(obj.refineFullProjections));
        else
          if ~isequal(size(obj.FPmask),size(obj.refineFullProjections))
            error('REFINEMENT: size of FPmask and input projections do not match!')
          end
        end
        
      end
      
      % apply binning to obj.refineModel and obj.refineProjections
      function obj = apply_binning(obj)
          obj.refineModel = bin(obj.refineModel,obj.bin_factor,3);
          obj.refineProjections = bin(obj.refineFullProjections,obj.bin_factor,2);
      end
    end
end
           
