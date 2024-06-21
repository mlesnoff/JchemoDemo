using Jchemo, JchemoData
using JLD2, DataFrames
using GLMakie, CairoMakie
using LinearAlgebra, Random
using Distances
using ManifoldLearning
using UMAP

n = 1000
noise = .5  # "vertical" noise (axis3)
#noise = 2
segments = 4
hlims = (-10.0, 10.0)  # seems to impact only axis2
rng = TaskLocalRNG()
#rng = MersenneTwister(1234)
Xt, L = ManifoldLearning.swiss_roll(n, noise; segments, hlims, rng)
X = Xt'
labs = vec(L)
tab(labs) 

GLMakie.activate!() 
#CairoMakie.activate!()  
mks = 10
i = 1
scatter(X[:, i], X[:, i + 1], X[:, i + 2], 
    markersize = mks, 
    color = labs, #colormap = (:Dark2_5, .7),
    axis = (type = Axis3, xlabel = string("LV", i), ylabel = string("LV", i + 1), 
        zlabel = string("LV", i + 2), title = "Swiss roll"))

#### PCA

nlv = 2
mod = model(pcasvd; nlv)
fit!(mod, X)
@head T = mod.fm.T  
CairoMakie.activate!()
i = 1
plotxy(T[:, i], T[:, i + 1]; color = labs,
    xlabel = string("LV", i), ylabel = string("LV", i + 1), title = "PCA").f  

### UMAP

nlv = 2
n_neighbors = 15 ; min_dist = .5 
Tt = UMAP.umap(X', nlv; n_neighbors, 
    metric = Euclidean(), min_dist = min_dist) ;
@head T = Tt' 
CairoMakie.activate!()
i = 1
plotxy(T[:, i], T[:, i + 1]; color = labs,
    xlabel = string("LV", i), ylabel = string("LV", i + 1), title = "UMAP").f  

#### TSNE

p = 30
maxoutdim = 2
M = ManifoldLearning.fit(TSNE, X'; p, maxoutdim) 
Tt =  ManifoldLearning.predict(M) 
@head T = Tt' 
CairoMakie.activate!()
i = 1
plotxy(T[:, i], T[:, i + 1]; color = labs,
    xlabel = string("LV", i), ylabel = string("LV", i + 1), title = "t-SNE").f  

### KPCA

nlv = 2
kern = :krbf
gamma = 1e-2
mod = model(kpca; nlv, kern, gamma)
fit!(mod, X)
@head T = mod.fm.T  
CairoMakie.activate!()
i = 1
plotxy(T[:, i], T[:, i + 1]; color = labs,
    xlabel = string("LV", i), ylabel = string("LV", i + 1), title = "KPCA").f  

nlv = 2
kern = :kpol
gamma = 1 ; degree = 3 ; coef0 = 10
mod = model(kpca; nlv, kern, degree, gamma, coef0)
fit!(mod, X)
@head T = mod.fm.T  
CairoMakie.activate!()
i = 1
plotxy(T[:, i], T[:, i + 1]; color = labs,
    xlabel = string("LV", i), ylabel = string("LV", i + 1), title = "KPCA").f  




