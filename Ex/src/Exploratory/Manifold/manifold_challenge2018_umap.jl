
using Jchemo, JchemoData
using JLD2, DataFrames, CairoMakie, GLMakie
using FreqTables


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/challenge2018.jld2") 
@load db dat
@names dat


X = dat.X
@head X


Y = dat.Y
@head Y


wlst = names(X) 
wl = parse.(Int, wlst)


plotsp(X, wl; nsamp = 500, xlabel = "Wavelength (nm)").f


model1 = snv()
model2 = savgol(npoint = 21, deriv = 2, degree = 3)
model = pip(model1, model2)
fit!(model, X)
Xp = transf(model, X)
@head Xp


plotsp(Xp, wl; nsamp = 500, xlabel = "Wavelength (nm)").f


typ = Y.typ
freqtable(string.(typ, " - ", Y.label))


test = Y.test  # training/test (0/1) observations
tab(test) 
freqtable(typ, test)


s = Bool.(test) # same as: s = Y.test .== 1
Xtrain = rmrow(Xp, s)
typtrain = rmrow(typ, s)
Xtest = Xp[s, :]
typtest = typ[s]
ntot = nro(X)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)


nlv = 3
n_neighbors = 40; min_dist = .4 
model = umap(; nlv, n_neighbors, min_dist)
#model = umap(; nlv, n_neighbors, min_dist, psamp = .5)  # faster but less accurate  
fit!(model, Xtrain)
@head T = model.fitm.T


CairoMakie.activate!()  
#GLMakie.activate!()    # for interactive axe-rotation


i = 1
plotxyz(T[:, i], T[:, i + 1], T[:, i + 2]; size = (600, 500), color = (:red, .3), markersize = 10, xlabel = string("LV", i), 
    ylabel = string("LV", i + 1), zlabel = string("LV", i + 2), title = "Umap score space").f


lev = mlev(typtrain)
nlev = length(lev)
colm = cgrad(:tab10, nlev; categorical = true, alpha = .5)
i = 1
plotxyz(T[:, i], T[:, i + 1], T[:, i + 2], typtrain; size = (700, 500), color = colm, markersize = 10, xlabel = string("LV", i), 
    ylabel = string("LV", i + 1), zlabel = string("LV", i + 2), title = "Umap score space").f


@head Ttest = transf(model, Xtest)


f, ax = plotxyz(T[:, i], T[:, i + 1], T[:, i + 2], typtrain; size = (700, 500), color = colm, markersize = 10, xlabel = string("LV", i), 
    ylabel = string("LV", i + 1), zlabel = string("LV", i + 2), title = "Umap score space")
scatter!(ax, Ttest[:, i], Ttest[:, i + 1], Ttest[:, i + 2]; markersize = 6, color = :black)
f

