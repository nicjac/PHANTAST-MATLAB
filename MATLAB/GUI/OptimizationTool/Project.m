classdef Project < handle
    %PROJECT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        images
        results
        searchedParameters
        name
    end
    
    methods
        function obj = Project()
            obj.images = Image.empty();
        end
    end
    
end

