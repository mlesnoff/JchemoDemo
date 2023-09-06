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
s = Bool.(Y.test)
Xtrain = rmrow(X, s)
ytrain = rmrow(y, s)
Xtest = X[s, :]
ytest = y[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)

#+
gamma = .001
fm = kplsrda(Xtrain, ytrain; nlv = 15, 
    gamma = gamma, scal = true) ;
pnames(fm)

#+
pnames(fm.fm)

#+
typeof(fm.fm)

#+
res = Jchemo.predict(fm, Xtest)
pnames(res)

#+
pred = res.pred

#+
res.posterior

#+
err(pred, ytest)

#+
cf = confusion(pred, ytest) ;
cf.cnt

#+
cf.pct

#+
plotconf(cf).f

