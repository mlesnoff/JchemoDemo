
using Jchemo, JchemoData
using JLD2, DataFrames
using GLMakie, CairoMakie
using LinearAlgebra, Random
using Distances
using FreqTables
using ManifoldLearning


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/challenge2018.jld2") 
@load db dat
pnames(dat)


X = dat.X 
Y = dat.Y
ntot, p = size(X)


@head X
@head Y


summ(Y)


y = Y.conc
typ = Y.typ
label = Y.label 
test = Y.test
tab(test)


wlst = names(X)
wl = parse.(Float64, wlst)


freqtable(string.(typ, "-", Y.label))


freqtable(typ, test)


plotsp(X, wl; nsamp = 30).f


mod1 = model(snv)
mod2 = model(savgol; npoint = 21, deriv = 2, degree = 3)
mod = pip(mod1, mod2)
fit!(mod, X)
Xp = transf(mod, X)


plotsp(Xp, wl; nsamp = 30).f


s = Bool.(test)
Xtrain = rmrow(Xp, s)
Ytrain = rmrow(Y, s)
ytrain = rmrow(y, s)
typtrain = rmrow(typ, s)
Xtest = Xp[s, :]
Ytest = Y[s, :]
ytest = y[s]
typtest = typ[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)


nlv = 3
n_neighbors = 40 ; min_dist = .4 
mod = model(umap; nlv, n_neighbors, min_dist)
fit!(mod, Xtrain)
@head T = transf(mod, Xtrain)


CairoMakie.activate!()  
#GLMakie.activate!() 
ztyp = recod_catbyint(typtrain)
i = 1
scatter(T[:, i], T[:, i + 1], T[:, i + 2]; markersize = 5, 
    color = ztyp, colormap = :tab20, 
    axis = (type = Axis3, xlabel = string("LV", i), ylabel = string("LV", i + 1), 
        zlabel = string("LV", i + 2), title = "UMAP", perspectiveness = .3))


CairoMakie.activate!()  
#GLMakie.activate!() 
ztyp = recod_catbyint(typtrain)
i = 1
colsh = :tab10
f = Figure()
ax = Axis3(f[1, 1]; xlabel = string("LV", i), ylabel = string("LV", i + 1), 
        zlabel = string("LV", i + 2), title = "UMAP", perspectiveness = .3) 
scatter!(ax, T[:, i], T[:, i + 1], T[:, i + 2]; markersize = 5, 
    color = ztyp, colormap = colm)   
lev = mlev(typtrain)
nlev = length(lev)
colm = cgrad(colsh, nlev; alpha = .7, categorical = true) 
elt = [MarkerElement(color = colm[i], marker = '●', markersize = 10) for i in 1:nlev]
#elt = [PolyElement(polycolor = colm[i]) for i in 1:nlev]
title = "Group"
Legend(f[1, 2], elt, lev, title; nbanks = 1, rowgap = 10, framevisible = false)
f


nlv = 3
n_neighbors = 40 ; min_dist = .4 
nlv = 3
n_neighbors = 40 ; min_dist = .4 
mod = model(umap; nlv, n_neighbors, min_dist)
fit!(mod, Xtrain)
@head T = transf(mod, Xtrain)
@head Ttest = transf(mod, Xtrain)


CairoMakie.activate!()  
#GLMakie.activate!() 
ztyp = recod_catbyint(typtrain)
i = 1
colsh = :tab10
f = Figure()
ax = Axis3(f[1, 1]; xlabel = string("LV", i), ylabel = string("LV", i + 1), 
        zlabel = string("LV", i + 2), title = "UMAP", perspectiveness = .3) 
scatter!(ax, T[:, i], T[:, i + 1], T[:, i + 2]; markersize = 5, 
    color = ztyp, colormap = colm) 
scatter!(ax, Ttest[:, i], Ttest[:, i + 1], Ttest[:, i + 2], color = :black, 
    colormap = :tab20, markersize = 7)  
lev = mlev(typtrain)
nlev = length(lev)
colm = cgrad(colsh, nlev; alpha = .7, categorical = true) 
elt = [MarkerElement(color = colm[i], marker = '●', markersize = 10) for i in 1:nlev]
#elt = [PolyElement(polycolor = colm[i]) for i in 1:nlev]
title = "Group"
Legend(f[1, 2], elt, lev, title; nbanks = 1, rowgap = 10, framevisible = false)
f

