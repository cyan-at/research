%Russell Cohen & Mason Glidden 2009
%fastRectInt(r1,r2): Computes the the intersecting area of two arbirary
%quadrilaterals.  Returns a value from 0->1, 0: No Intersection,
%1:Rectangles are identical.
%r1 and r2 may be specified as either:
%[x,y,x,y,x,y,x,y...] (4 vertexes) or [x,y,width,height]
function int = fastRectInt(r1, r2)
	if(length(r1) == 4)
		r1 = [r1(1), r1(2), r1(1)+r1(3), r1(2), r1(1)+r1(3), r1(2)+r1(4), ...
			r1(1), r1(2)+r1(4)]; %write out x,y,width,heigh to the full format
	end
	if(length(r2) == 4)
		r2 = [r2(1), r2(2), r2(1)+r2(3), r2(2), r2(1)+r2(3), r2(2)+r2(4), ...
			r2(1), r2(2)+r2(4)]; %write out x,y,width,heigh to the full format
	end
	
	int = 0;
	boundingBox = 0;
	
	r1 = polyLong2PolyShort(r1);
	r2 = polyLong2PolyShort(r2);
	maxX1 = max(r1(:, 1));
	maxY1 = max(r1(:, 2));
	minX1 = min(r1(:, 1));
	minY1 = min(r1(:, 2));
	maxX2 = max(r2(:, 1));
	maxY2 = max(r2(:, 2));
	minX2 = min(r2(:, 1));
	minY2 = min(r2(:, 2));
	
	maxX = max(maxX1, maxX2);
	maxY = max(maxY1, maxY2);
	minX = min(minX1, minX2);
	minY = min(minY1, minY2);
	
	total = (maxX - minX) * (maxY - minY);
	
	if(minX1 <= maxX2) %Do a fast bounding box intersection to quickly rule out no intersection 
		%
		if(maxX1 >= minX1)
			if(maxY1 >= minY2)
				if(minY1 <= maxY2)
	                boundingBox = 1;
				end
			end
		end
	end
	%compute the actual colliding area, if their bounding boxes intersect
	if boundingBox == 1		
		m1 = poly2mask(r2(:,1)', r2(:,2)', maxY, maxX);
		m2 = poly2mask(r1(:,1)', r1(:,2)', maxY, maxX);	
		sumIntersection = sum(sum( m1&m2 ));
		if  sumIntersection ~= 0
			int = sumIntersection/total;
		end
	end
end