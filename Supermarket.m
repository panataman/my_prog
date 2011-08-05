classdef Supermarket < handle
	%SUPERMARKET Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
	    refrigerators
	end
	methods
		function obj = Supermarket(fridges, number_steps, days)
		    for i = 1 : length(fridges{1})
		        obj.refrigerators = [obj.refrigerators ...
		            Refrigerator( ... 
				fridges{1}{i},  ... 
				number_steps, ...
				days ...
			    )];
		
			end % end for
		end % end function Supermarket
	end % end methods
end % end classdef
