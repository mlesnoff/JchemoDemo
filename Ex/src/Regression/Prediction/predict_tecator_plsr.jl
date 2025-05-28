
using Jchemo, JchemoData
using JLD2, CairoMakie


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/tecator.jld2") 
@load db dat
@names dat


X = dat.X
Y = dat.Y 
typ = Y.typ ;
tab(typ)


wlst = names(X) ;
wl = parse.(Float64, wlst) 
#plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


model1 = snv()
model2 = savgol(npoint = 15, deriv = 2, degree = 3)
model = pip(model1, model2)
fit!(model, X)
@head Xp = transf(model, X) 
#plotsp(Xp, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


s = typ .== "train" ;
Xtrain = Xp[s, :] ; 
Ytrain = Y[s, :] ;
Xtest = rmrow(Xp, s) ;
Ytest = rmrow(Y, s) ;
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)


namy = names(Y)[1:3]
j = 2  
nam = namy[j]    # work on the j-th y-variable
ytrain = Ytrain[:, nam] ;
ytest = Ytest[:, nam] ;


nlv = 15
model = plskern(; nlv)    # which is the same as below:
#model = plskern(nlv = 15)
fit!(model, Xtrain, ytrain)
@names model
fitm = model.fitm ;
@names fitm


@head pred = predict(model, Xtest).pred


@head predict(model, Xtest; nlv = 2).pred


predict(model, Xtest; nlv = 0:2).pred


rmsep(pred, ytest)


bias(pred, ytest)


mse(pred, ytest)


r = residreg(pred, ytest) # residuals


plotxy(pred, ytest; size = (500, 400), color = (:red, .5), bisect = true, title = string("Test set - variable ", nam), 
    xlabel = "Prediction", ylabel = "Observed").f


plotxy(ytest, r; size = (500, 400), color = (:red, .5), zeros = true, title = string("Test set - variable ", nam), 
    xlabel = "Observed (Test)", ylabel = "Residuals").f


zpred = vec(pred) ;
zr = vec(r) ;


model_lo = loessr(span = 1/2) 
fit!(model_lo, zpred, ytest)
pred_lo = predict(model_lo, sort(zpred)).pred ;
f, ax = plotxy(zpred, ytest; size = (500, 400), bisect = true, title = string("Test set - variable ", nam), 
    xlabel = "Predicted", ylabel = "Observed") ;
lines!(ax, sort(zpred), vec(pred_lo); color = :red)
f


model_lo = loessr(span = 1/2) 
fit!(model_lo, zpred, zr)
pred_lo = predict(model_lo, sort(zpred)).pred ;
f, ax = plotxy(zpred, zr; size = (500, 400), title = string("Test set - variable ", nam), 
    xlabel = "Predictions", ylabel = "Residuals") ;
lines!(ax, sort(zpred), vec(pred_lo); color = :red)
hlines!(ax, 0; color = :grey)
f

