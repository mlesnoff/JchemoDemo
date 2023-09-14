using JLD2, CairoMakie, FreqTables 
using Jchemo, JchemoData

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/forages2.jld2") 
@load db dat
pnames(dat)
  
X = dat.X 
Y = dat.Y
ntot = nro(X)

@head X
@head Y

y = Y.typ
tab(y)

freqtable(y, Y.test)

wl = names(X)
wl_num = parse.(Float64, wl)

## X is already preprocessed
plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

s = Bool.(Y.test)
Xtrain = rmrow(X, s)
ytrain = rmrow(y, s)
Xtest = X[s, :]
ytest = y[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)

K = 3
segm = segmkf(ntrain, K; rep = 10)

## PLS-LDA
nlv = 1:50
rescv = gridcvlv(Xtrain, ytrain; segm = segm,
    score = err, fun = plslda, nlv = nlv) ; 
res = rescv.res

plotgrid(res.nlv, res.y1; step = 5,
    xlabel = "Nb. LVs", ylabel = "Err-CV").f

u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

fm = plslda(Xtrain, ytrain; nlv = res.nlv[u]) ;
res = Jchemo.predict(fm, Xtest) ;
pred = res.pred
err(pred, ytest)

confusion(pred, ytest).pct

## PLS-KDE-DA
pars = mpar(a = [.5, 1, 1.5])

nlv = 1:50
rescv = gridcvlv(Xtrain, ytrain; segm = segm,
    score = err, fun = plskdeda, pars = pars, nlv = nlv) ; 
res = rescv.res

group = string.("a = ", res.a)
plotgrid(res.nlv, res.y1, group; step = 2,
    xlabel = "Nb. LVs", ylabel = "Err-CV").f

u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

fm = plskdeda(Xtrain, ytrain; nlv = res.nlv[u],
    a = res.a[u]) ;
res = Jchemo.predict(fm, Xtest) ;
pred = res.pred
err(pred, ytest)

confusion(pred, ytest).pct
