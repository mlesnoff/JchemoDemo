using JLD2, CairoMakie, FreqTables 
using Jchemo, JchemoData

#+
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/forages2.jld2") 
@load db dat
pnames(dat)
  
#+
X = dat.X 
Y = dat.Y
ntot = nro(X)

#+ term = true
@head X
@head Y

#+
y = Y.typ
tab(y)

#+
freqtable(y, Y.test)

#+
wl = names(X)
wl_num = parse.(Float64, wl)

#+
## X is already preprocessed
plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


#+
## Tot ==> Train + Test
s = Bool.(Y.test)
Xtrain = rmrow(X, s)
ytrain = rmrow(y, s)
Xtest = X[s, :]
ytest = y[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)

#+
## X contains high multicolinearities
## ==> a regularization is required for the FDA, 
## for instance:
## 1) by preliminary dimension reduction 
## 2) or using a ridge regularization

## 1) FDA on PCA scores
fm0 = pcasvd(Xtrain; nlv = 10) ;
pnames(fm0)

#+
Ttrain_pca = fm0.T 

#+
fm = fda(Ttrain_pca, ytrain; nlv = 2) ;
#fm = fdasvd(Ttrain_pca, ytrain; nlv = 2) ;
pnames(fm)

#+
Ttrain = fm.T

#+
lev = fm.lev
nlev = length(lev)

#+
plotxy(Ttrain[:, 1:2], ytrain;
    resolution = (800, 400), ellipse = true, 
    title = "FDA").f

#+
## 2) FDA directly on X
## ==> using ridge regularization
## Rq: If lb is too small (e.g. here 1e-10) 
## the model can overfit the discrimination of new observations
lb = 1e-5
fm = fda(Xtrain, ytrain; nlv = 2, lb = lb) ;
#fm = fdasvd(Xtrain, ytrain; nlv = 2, lb = lb) ;
pnames(fm)

#+
lev = fm.lev
nlev = length(lev)

#+
ct = fm.Tcenters


#+
Ttrain = fm.T

#+
f, ax = plotxy(Ttrain[:, 1:2], ytrain;
    title = "FDA", ellipse = true)
scatter!(ax, ct[:, 1], ct[:, 2],
    markersize = 10, color = :red)
f

#+
## Test
Ttest = Jchemo.transform(fm, Xtest)

#+
i = 1  # class 
f, ax = plotxy(Ttrain[:, 1:2], ytrain;
    title = "FDA")
scatter!(ax, ct[:, 1], ct[:, 2],
    markersize = 10, color = :red)
s = ytest .== lev[i]
zT = Ttest[s, :]
scatter!(ax, zT[:, 1], zT[:, 2],
    markersize = 10, color = (:purple, .8))
f

