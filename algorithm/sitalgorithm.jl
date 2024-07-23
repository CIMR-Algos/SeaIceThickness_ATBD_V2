using Pkg
#Pkg.activate("sit_atbd_env_jl")
using ForwardDiff
import YAML
using Markdown
using Printf
using StaticArrays


I(p)=f(x)=p[2]-(p[2]-p[1])*exp(-x/p[3])
Q(p)=f(x)=p[2]-(p[2]-p[1])*exp(-(x/p[3])^p[4])

cfdd(temp,duration)=1.33*(-(temp+1.8)*duration)^0.58
#reading fit parameters from file

fI(x)=I(pI)(x)
fQ(x)=Q(pQ)(x)

params=YAML.load_file("fit_params.yml")
const tbh_params,tbv_params,pI,pQ=getindex.(Ref(params),["ph","pv","pI","pQ"])


ff(p)=return f(x)=p[2]-(p[2]-p[1])*exp(-x/p[3])
sit_h=ff(tbh_params)
sit_v=ff(tbv_params)

Fw_TB(x,p)=SA[ff(p[1])(x), ff(p[2])(x)]
Fw_IQ(x)=[fI(x[1]), fQ(x[1])]

Fw_TB(x)=Fw_TB(x[1],(tbh_params,tbv_params))


function retrieval(Ta,Se,Sa,xa,F)
    # easy retrieval method
    # Ta is a vector of length of input for one single retrieval length N
    # Se is the error covariance matrix of the input, i.e. length N x N
    # Sa is the error covariance matrix of the output, i.e. length M x M (the error of the background value)
    # xa is a background value where Sa is the error of, i.e. a vector of length M
    # F is a forward model receiving a input vector of length N and return an output of length M
    # ymin and ymax are the limits of the oupt regime where ot search in, both are of length M
    # returns Y, the output vector
    
    #defining error function to menimize as χ² 
    iSa=inv(Sa)
    iSe=inv(Se)
    χ²(y,x,iSe,iSa,xa,F)=(y.-F(x))'*(iSe*(y.-F(x)))+(xa.-x)'*(iSa*(xa.-x))
   if length(xa)==0
        xi=[maximize(x->-χ²(Ta,x,iSe,iSa,xa,F),0,10000).res.minimizer]
    else
        res=optimize(x->χ²(Ta,x,iSe,iSa,xa,F),xa)
        xi=res.minimizer
    end
#    @show χ²(Ta,y,Se,Sa,xa)
    M=ForwardDiff.jacobian(F,xi)
    xerr=inv(iSa+M'*iSe*M)
#    @show χ²(Ta,xi,iSe,iSa,xa,F)
    return xi[1],xerr[1]
end
    


retrieval(h,v)=retrieval([h,v],[25 15;15 25.0],fill(20000.,1,1),[100.],Fw_TB)

function lm_retrieval(Ta,Sₑ,Sₐ,xₐ,F)
    #Levenberg Marquardt method after Rodgers (2000)
    #target: find x so that F(x)=Ta, given
    #Ta: measurement vector
    #Sₑ: error covariance of measurement
    #Sₐ: error covariance of physical state 
    #xₐ: expected physical state (also used as start, i.e. first guess)
    #F: the forward model translating measument space into state space
    Sₐ⁻¹=inv(Sₐ)
    Sₑ⁻¹=inv(Sₑ)
    #function to minimize with changing input x
    J(y,x,Sₑ⁻¹,Sₐ⁻¹,xₐ,F)=(y.-F(x))'*(Sₑ⁻¹*(y.-F(x)))+(xₐ.-x)'*(Sₐ⁻¹*(xₐ.-x)) 
    xᵢ=copy(xₐ)
    Jᵢ=J(Ta,xᵢ,Sₑ⁻¹,Sₐ⁻¹,xₐ,F)
    γ=1e-5 #set to 0 for gauss newton
    for i=1:2000 
        Kᵢ=ForwardDiff.jacobian(F,xᵢ)
        Ŝ⁻¹=Sₐ⁻¹+Kᵢ'*Sₑ⁻¹*Kᵢ #eq 5.13
        xᵢ₊₁=xᵢ+((1+γ)*Sₐ⁻¹+Kᵢ'*Sₑ⁻¹*Kᵢ)\(Kᵢ'*Sₑ⁻¹*(Ta-F(xᵢ))-Sₐ⁻¹*(xᵢ-xₐ)) #eq 5.36
        Jᵢ₊₁=J(Ta,xᵢ₊₁,Sₑ⁻¹,Sₐ⁻¹,xₐ,F)
        d²=(xᵢ-xᵢ₊₁)'*Ŝ⁻¹*(xᵢ-xᵢ₊₁) #eq 5.29
        if Jᵢ₊₁<Jᵢ 
            γ/=2
        else
            γ*=10
            continue
        end
        xᵢ=xᵢ₊₁
        if d²<1e-10
            break
        end
        Jᵢ=Jᵢ₊₁
    end
    Kᵢ=ForwardDiff.jacobian(F,xᵢ)
    Ŝ=inv(Sₐ⁻¹+Kᵢ'*Sₑ⁻¹*Kᵢ) # eq 5.38
    
    return xᵢ,Ŝ
end


retrievallm(h,v)=first.(lm_retrieval(SA[h,v],SA[25 15;15 25.0],SMatrix{1,1,Float64,1}(20000.0),SA[100.],Fw_TB))


function owerr_2(x,tbs=nothing) #new openwater error
    if tbs==nothing
        tbh,tbv=Fw_TB(x)
    else
        tbh,tbv=tbs
    end
    owtbh=67.7
    owtbv=148.9
    owf=-0.05
    ntbh=(tbh*(1-owf)+(owtbh*owf))
    ntbv=(tbv*(1-owf)+(owtbv*owf))
    owf=0.05
    sit_minus=retrievallm(ntbh,ntbv)[1]
    ntbh=(tbh*(1-owf)+(owtbh*owf))
    ntbv=(tbv*(1-owf)+(owtbv*owf))
    sit_plus=retrievallm(ntbh,ntbv)[1]
    return ((x-sit_plus)^2+(x-sit_minus)^2)^0.5
end


sittime(sit,temp)=-(max(0,sit)/1.33)^(1/0.58)/(temp+1.8)

function cfdd_unc(sit)
    t=sittime(sit,-25)
    return (cfdd(-25,t+1)-cfdd(-25,t))*0.68
end


function comb_error_2(tbh,tbv)
    sit,err=retrievallm(tbh,tbv)
    return sit,sqrt(cfdd_unc(sit)^2+err^2+owerr_2(sit,(tbh,tbv))^2)
end


