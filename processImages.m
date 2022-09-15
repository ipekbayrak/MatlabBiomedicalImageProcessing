 clear
    x = imread('output/mdb003_LH.jpg');
    originalIm = imread('input/mdb003.pgm');
     
    originalIm = imresize(originalIm,size(x,1)/size(originalIm,1));
    image =x;
    bw = im2bw(x);
  
    
    
    
     %h = figure;
    
    %imshow(bw)

    s = regionprops(bw, 'Orientation', 'MajorAxisLength', ...
        'MinorAxisLength', 'Eccentricity', 'Centroid');

   

    phi = linspace(0,2*pi,50);
    cosphi = cos(phi);
    sinphi = sin(phi);

    imarray = {};
    plotarrayX = {};
    plotarrayY = {};
    
    textarray = {};
    
    xbarbarray = {};
    ybaraarray = {};
    
    aa = {};
    ba = {};
    
    for k = 1:length(s)
         
        xbar = s(k).Centroid(1);
        ybar = s(k).Centroid(2);

        a = s(k).MajorAxisLength/2;
        b = s(k).MinorAxisLength/2;
        
        orientation = s(k).Orientation;

        theta = pi*s(k).Orientation/180;
        R = [ cos(theta)   sin(theta)
             -sin(theta)   cos(theta)];

        xy = [a*cosphi; b*sinphi];
        xy = R*xy;

        x = xy(1,:) + xbar;
        y = xy(2,:) + ybar;
        
    
        
        %treshold ile çok küçük çemberler engellendi
        if s(k).MinorAxisLength>5
        if s(k).MajorAxisLength>60
            %plot(x,y,'r','LineWidth',2);
            YourText = sprintf(strcat('Oriantation: ', num2str(s(k).Orientation),'\nArea: ',num2str(a*b*pi)));
            %hText = text(xbar-b,ybar-a,YourText,'Color',[0 0 1],'FontSize',10);
            
         plotarrayX = [plotarrayX {x}];
         plotarrayY = [plotarrayY {y}];
         
        textarray =[textarray {YourText}];
        
        xbarbarray = [xbarbarray {xbar}];
        ybaraarray = [ybaraarray {ybar}];
        
        aa = [aa {a}];
        ba = [ba {b}];
        
  
        cx = xbar;
        cy = ybar;
        
        r_sq = [a, b] .^ 2;  %# Ellipse radii squared (y-axis, x-axis)
        [X, Y] = meshgrid(1:size(image, 2), 1:size(image, 1));
        ellipse_mask = (r_sq(2) * (X - cx) .^ 2 + r_sq(1) * (Y - cy) .^ 2 <= prod(r_sq));
        RotateEllipse = rotateAround(ellipse_mask,ybar,xbar,orientation,'bilinear')
        %RotateEllipse = imrotate(ellipse_mask,45,'bicubic');
        
        %figure;
        %imshow(RotateEllipse,[])
        
        %RotateEllipse = imrotate(ellipse_mask,45);
        %RotateEllipse = im2bw(RotateEllipse);
        %# Apply the mask to the image
        A_cropped = bsxfun(@times, originalIm, uint8(RotateEllipse(1:size(image, 1),1:size(image, 2)) ) );
        imarray =[imarray {A_cropped}];
     
            
        end
        end
    end
    
        new_image =~bw;
        new_image = im2uint8(new_image);
        
         
        for x = 1 : length(imarray)
           
             for i = 1 : size(imarray{x},1)
                for j = 1 : size(imarray{x},2)
                    if imarray{x}(i,j) ~= 0 % karanlik yerler siyahlar
                        new_image(i,j) = imarray{x}(i,j); % beyaz yap
                    end
                end
             end
           
        end
       
        
           figure;
           imshow (new_image,[]);
           
           hold on
           
           for p = 1 : length(plotarrayX)
              plot(plotarrayX{p},plotarrayY{p},'r','LineWidth',2);
           end
           
           for t = 1 : length(textarray)
               
               ya=xbarbarray{t}-150;
               ab=ybaraarray{t};
               hText = text(ya,ab ,textarray{t},'Color',[0 0 1],'FontSize',12);
           end
           
           
         
         hold off
         