using JLD2, CairoMakie
using Jchemo, JchemoData
using Loess

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/tecator.jld2") 
@load db dat
pnames(dat)

X = dat.X
Y = dat.Y 
typ = Y.typ
wl = names(X)
wl_num = parse.(Float64, wl) 
ntot = nro(X)
namy = names(Y)[1:3]

plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 
plotsp(Xp, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

s = typ .== "train"
Xtrain = Xp[s, :]
Ytrain = Y[s, namy]
Xtest = rmrow(Xp, s)
Ytest = rmrow(Y[:, namy], s)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)

j = 2  # y-variable
nam = namy[j]
ytrain = Ytrain[:, nam]
ytest = Ytest[:, nam]

gamma = 100 ; nlv = 15
fm = kplsr(Xtrain, ytrain; gamma = gamma, 
    nlv = nlv) ;
## Or Direct KPLSR:
#fm = dkplsr(Xtrain, ytrain; gamma = gamma, nlv = nlv) ;
pnames(fm)

pred = Jchemo.predict(fm, Xtest).pred

Jchemo.predict(fm, Xtest; nlv = 2).pred
Jchemo.predict(fm, Xtest; nlv = 0:2).pred

rmsep(pred, ytest)
bias(pred, ytest)
mse(pred, ytest)

zpred = vec(pred)
plotxy(zpred, ytest; resolution = (500, 400),
    color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f   
    

