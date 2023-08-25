function [n1,n2] = grid_find(x_test, x)
if (x_test-x(end))*(x_test-x(1))<0
        n1 = 1;
        n2 = length(x);
        iter=0;
        while ((n2-n1)>1)&&(iter<length(x))
            iter=iter+1;
            idx=floor((n1+n2)/2);
            if (x_test-x(idx))*(x_test-x(1))>=0
                n1=idx;
            else
                n2=idx;
            end
        end
        %nlim
    else
        if abs(x_test-x(end))>abs(x_test-x(1))
            n1=round(1);
            n2=round(1);
        else
            n1=round(length(x));
            n2=round(length(x));
        end
end
end

