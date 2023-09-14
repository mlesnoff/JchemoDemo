using JLD2, CairoMakie
using Jchemo, JchemoData

```julia
path_pack = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_pack, "data/tecator.jld2") 
@load db dat
pnames(dat)

```julia
X = dat.X
Y = dat.Y 
ntot, p = size(X)

```julia term = true
@head X
@head Y
```julia
summ(Y)

```julia
namy = names(Y)[1:3]

```julia
typ = Y.typ
tab(typ)

```julia
wl = names(X)
wl_num = parse.(Float64, wl) 

```julia
plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

```julia
f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 

plotsp(Xp, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

```julia
s = typ .== "train"
Xtrain = Xp[s, :]
Ytrain = Y[s, namy]
Xtest = rmrow(Xp, s)
Ytest = rmrow(Y[:, namy], s)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)

```julia
j = 2  
nam = namy[j]    # y-variable
ytrain = Ytrain[:, nam]
ytest = Ytest[:, nam]

```julia
segm = segmkf(ntrain, 4; rep = 5)

```julia
nlvdis = [10; 15] ; metric = ["mahal"] 
h = [1; 2; 5; Inf] ; k = [30; 50; 100]  
nlv = ["1:5", "1:10"]
pars = mpar(nlvdis = nlvdis, metric = metric, 
    h = h, k = k, nlv = nlv) 

```julia
length(pars[1])

```julia
res = gridcv(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = lwplsravg, 
    pars = pars, verbose = false).res 

```julia
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]

```julia
fm = lwplsravg(Xtrain, ytrain; nlvdis = res.nlvdis[u],
    metric = res.metric[u], h = res.h[u], k = res.k[u], 
    nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred 
@show rmsep(pred, ytest)

```julia
plotxy(pred, ytest; resolution = (500, 400),
    color = (:red, .5), bisect = true, 
    xlabel = "Prediction", ylabel = "Observed (Test)").f  

    