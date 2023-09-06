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
## "PLSDA" gathers different methods 
nlv = 15
fm = plsrda(Xtrain, ytrain; nlv = nlv) ;
#fm = plslda(Xtrain, ytrain; nlv = nlv) ;
#fm = plsqda(Xtrain, ytrain; nlv = nlv) ;
#fm = plsqda(Xtrain, ytrain; nlv = nlv, prior = "prop") ;

## Ridge (RR-DA) 
#fm = rrda(Xtrain, ytrain; lb = 1e-5) ;

#+
pnames(fm)

#+
pnames(fm.fm)

#+
res = Jchemo.predict(fm, Xtest) ;
pnames(res)

#+
pred = res.pred

#+
res.posterior   # prediction of the dummy table

#+
err(pred, ytest)

#+
freqtable(ytest, vec(pred))

#+
cf = confusion(pred, ytest) ;
pnames(cf)

#+
cf.cnt

#+
cf.pct

#+
cf.accuracy 

#+
plotconf(cf).f

#+
## PLSDA with averaging
nlv = "0:20"
fm = plsrdaavg(Xtrain, ytrain; nlv = nlv) ;
pred = Jchemo.predict(fm, Xtest).pred
err(pred, ytest)
