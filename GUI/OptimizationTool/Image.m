classdef Image < handle
    %IMAGE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pc
        classMasks@logical
        results
        name
        path
        processed@logical
    end
    
    methods
        function obj = Image(path)
            obj.path = path;
            [pathstr, obj.name, ext] = fileparts(path);
            obj.pc = imread(path);

            sizeImages = [size(obj.pc,1) size(obj.pc,2)];
            obj.classMasks(1,:,:) = logical(zeros(sizeImages));
            obj.classMasks(2,:,:) = logical(zeros(sizeImages));
        end
    end
    
end

