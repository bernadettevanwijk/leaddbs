function [X,electrode,err]=ea_mapelmodel2reco(options,elspec,elstruct,side,resultfig)        
err=0;


load([ea_getearoot,'templates',filesep,'electrode_models',filesep,elspec.matfname])
A=[electrode.head_position,1;
    electrode.tail_position,1
    electrode.x_position,1
    electrode.y_position,1]; % points in model
redomarkers=0;
if ~isfield(elstruct,'markers') % backward compatibility to old electrode format
    redomarkers=1;
    
else
    if isempty(elstruct.markers)
        
        redomarkers=1;
    end
end
if redomarkers
    for iside=options.sides
        elstruct.markers(iside).head=elstruct.coords_mm{iside}(1,:);
        elstruct.markers(iside).tail=elstruct.coords_mm{iside}(4,:);
        
        normtrajvector=(elstruct.markers(iside).tail-elstruct.markers(iside).head)./norm(elstruct.markers(iside).tail-elstruct.markers(iside).head);
        orth=null(normtrajvector)*(options.elspec.lead_diameter/2);
        elstruct.markers(iside).x=elstruct.coords_mm{iside}(1,:)+orth(:,1)';
        elstruct.markers(iside).y=elstruct.coords_mm{iside}(1,:)+orth(:,2)'; % corresponding points in reality
    end
end

B=[elstruct.markers(side).head,1;
    elstruct.markers(side).tail,1;
    elstruct.markers(side).x,1;
    elstruct.markers(side).y,1];
setappdata(resultfig,'elstruct',elstruct);
setappdata(resultfig,'elspec',elspec);



X=mldivide(A,B);

% perform tests if A has been transformed to B correctly.
% First we will make sure that the projection from A to B (Ab)
% results in something very similar to B.
Ab=A*X;
vizprec=0.001;
if sum(abs(Ab(:)-B(:)))>vizprec % visualization precision in sums of millimeters.
    err=1;
end

% Second we will make sure that projected markers structure is
% still close to orthogonal:
% figure, plot3(Ab(1,1),Ab(1,2),Ab(1,3),'r*');
% hold on
% plot3(Ab(2,1),Ab(2,2),Ab(2,3),'b*');
% plot3(Ab(3,1),Ab(3,2),Ab(3,3),'k*');
% plot3(Ab(4,1),Ab(4,2),Ab(4,3),'g*');
% axis square
angvizprec=0.5; % angular visualization precision tolerance in sums of degrees
if 90-radtodeg(acos(dot(...
        (Ab(1,1:3)-Ab(2,1:3))/...
        norm(Ab(1,1:3)-Ab(2,1:3)),...
        (Ab(1,1:3)-Ab(3,1:3))/...
        norm((Ab(1,1:3)-Ab(3,1:3)))...
        )+...
        dot(...
        (Ab(1,1:3)-Ab(2,1:3))/...
        norm(Ab(1,1:3)-Ab(2,1:3)),...
        (Ab(1,1:3)-Ab(4,1:3))/...
        norm(Ab(1,1:3)-Ab(4,1:3))) ...
        )) > angvizprec
    err=1;
end

% end tests

X=X';

