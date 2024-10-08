function [de,dl,dc,dh] = cmcde(lab1,lab2,sl,sc)

if (nargin<4)
   %disp('using default values of l:c')
   sl=1; sc=1;
end

de = zeros(1,size(lab1,2));
dl = zeros(1,size(lab1,2));
dc = zeros(1,size(lab1,2));
dh = zeros(1,size(lab1,2));

% first compute the CIELAB deltas
dl = lab2(:,1)-lab1(:,1);
dc = (lab2(:,2).^2 + lab2(:,3).^2).^0.5-(lab1(:,2).^2 + lab1(:,3).^2).^0.5;
dh = ((lab2(:,2)-lab1(:,2)).^2 + (lab2(:,3)-lab1(:,3)).^2 - dc.^2);
dh = (abs(dh)).^0.5;
% get the polarity of the dh term
dh = dh.*dhpolarity(lab1,lab2);

% now compute the CMC weights 
Lweight = [lab1(:,1)<16]*0.511+(1-[lab1(:,1)<16]).*(0.040975*lab1(:,1))./(1 + 0.01765*lab1(:,1));
[h,c] = cart2pol(lab1(:,2), lab1(:,3));
h = h*180/pi;

Cweight = 0.638 + (0.0638*c)./(1 + 0.0131*c);
index = (164<h & h<345);
T = index.*(0.56 + abs(0.2*cos((h+168)*pi/180))) + ...
(1-index).*(0.36 + abs(0.4*cos((h+35)*pi/180)));
F = ((c.^4)./(c.^4 + 1900)).^0.5;
Hweight = Cweight.*(T.*F + 1 - F);

dl = dl./(Lweight*sl);
dc = dc./(Cweight*sc);
dh = dh./Hweight;

de = (dl.^2 + dc.^2 + dh.^2).^0.5;
end


function [p] = dhpolarity(lab1,lab2)
% function [p] = dhpolarity(lab1,lab2)
% computes polarity of hue difference
% p = +1 if the hue of lab2 is anticlockwise
% from lab1 and p = -1 otherwise
[h1,c1] = cart2pol(lab1(:,2), lab1(:,3));
[h2,c2] = cart2pol(lab2(:,2), lab2(:,3));  

h1 = h1*180/pi;
h2 = h2*180/pi;

index = (h1<0);
h1 = (1-index).*h1 + index.*(h1+360);
index = (h2<0);
h2 = (1-index).*h2 + index.*(h2+360);

index = (h1>180);
h1 = (1-index).*h1 + index.*(h1-180);
h2 = (1-index).*h2 + index.*(h2-180);

p = (h2-h1);

index = (p==0);
p = (1-index).*p + index*1;
index = (p>180);
p = (1-index).*p + index.*(p-360);

p = p./abs(p);

end