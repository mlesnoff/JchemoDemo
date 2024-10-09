
using Jchemo, JchemoData
using JLD2, DataFrames
using GLMakie, CairoMakie
using FreqTables


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


model1 = snv()
model2 = savgol(npoint = 21, deriv = 2, degree = 3)
model = pip(model1, model2)
fit!(model, X)
Xp = transf(model, X)


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


lev = mlev(typtrain)
nlev = length(lev)
ztyp = recod_catbyint(typtrain)


nlv = 3
n_neighbors = 40 ; min_dist = .4 
model = umap; nlv, n_neighbors, min_dist)
#model = umap; nlv, n_neighbors, min_dist, psamp = .5)
fit!(model, Xtrain)
@head T = transf(model, Xtrain)


CairoMakie.activate!()  
#GLMakie.activate!()  
i = 1
scatter(T[:, i], T[:, i + 1], T[:, i + 2]; markersize = 6, 
    color = ztyp, colormap = :tab10, 
    axis = (type = Axis3, xlabel = string("LV", i), ylabel = string("LV", i + 1), 
        zlabel = string("LV", i + 2), title = "UMAP", perspectiveness = .3))


CairoMakie.activate!()  
#GLMakie.activate!()  
colm = cgrad(:tab10, nlev; categorical = true, alpha = .5)
#colm = cgrad(:tab10; alpha = .5)[1:nlev]
i = 1
scatter(T[:, i], T[:, i + 1], T[:, i + 2]; markersize = 6, 
    color = ztyp, colormap = colm, 
    axis = (type = Axis3, xlabel = string("LV", i), ylabel = string("LV", i + 1), 
        zlabel = string("LV", i + 2), title = "UMAP", perspectiveness = .3))


CairoMakie.activate!()  
#GLMakie.activate!() 
colm = cgrad(:tab10, nlev; categorical = true, alpha = .5)
i = 1
f = Figure()
ax = Axis3(f[1, 1]; xlabel = string("LV", i), ylabel = string("LV", i + 1), 
        zlabel = string("LV", i + 2), title = "UMAP", perspectiveness = .3) 
scatter!(ax, T[:, i], T[:, i + 1], T[:, i + 2]; markersize = 6, 
    color = ztyp, colormap = colm)   
elt = [MarkerElement(color = colm[i], marker = '●', markersize = 10) for i in 1:nlev]
#elt = [PolyElement(polycolor = colm[i]) for i in 1:nlev]
title = "Group"
Legend(f[1, 2], elt, lev, title; nbanks = 1, rowgap = 10, framevisible = false)
f


nlv = 3
model = umap; nlv)
fit!(model, Xtrain)
@head T = transf(model, Xtrain)
@head Ttest = transf(model, Xtest)


CairoMakie.activate!()  
#GLMakie.activate!() 
colm = cgrad(:tab10, nlev; categorical = true, alpha = .5)
i = 1
f = Figure()
ax = Axis3(f[1, 1]; xlabel = string("LV", i), ylabel = string("LV", i + 1), 
        zlabel = string("LV", i + 2), title = "UMAP", perspectiveness = .3) 
scatter!(ax, T[:, i], T[:, i + 1], T[:, i + 2]; markersize = 6, 
    color = ztyp, colormap = colm) 
scatter!(ax, Ttest[:, i], Ttest[:, i + 1], Ttest[:, i + 2], color = (:black, .2), 
    colormap = colm, markersize = 7)  
elt = [MarkerElement(color = colm[i], marker = '●', markersize = 10) for i in 1:nlev]
#elt = [PolyElement(polycolor = colm[i]) for i in 1:nlev]
title = "Group"
Legend(f[1, 2], elt, lev, title; nbanks = 1, rowgap = 10, framevisible = false)
f

