function [ y_test ] = Interp_1D( x_test, x, y )
y_test=zeros(size(x_test));
    for ii=1:length(y_test)
        if (x_test(ii)-x(end))*(x_test(ii)-x(1))>=0
            if abs(x_test(ii)-x(end))>abs(x_test(ii)-x(1))
                y_test(ii)=y(1);
            else
                y_test(ii)=y(end);
            end
        else
            nlim=[1,size(x,1)];
            iter=0;
            while ((nlim(2)-nlim(1))>1)&&(iter<size(x,1))
                iter=iter+1;
                idx=floor((nlim(1)+nlim(2))/2);
                if (x_test(ii)-x(idx))*(x_test(ii)-x(1))>=0
                    nlim(1)=idx;
                else
                    nlim(2)=idx;
                end
            end
            y_test(ii)=(y(nlim(2))-y(nlim(1)))/(x(nlim(2))-x(nlim(1)))*(x_test(ii)-x(nlim(1)))+y(nlim(1));
        end
    end
end