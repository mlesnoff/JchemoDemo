
using Jchemo, JchemoData
using JLD2, DataFrames, CairoMakie, GLMakie
using LinearAlgebra, Random
using ManifoldLearning


n = 1000
noise = .5  # "vertical" noise (axis3)
#noise = 2
segments = 4
hlims = (-10.0, 10.0)  # seems to impact only axis2
rng = TaskLocalRNG()
#rng = MersenneTwister(1234)
Xt, L = ManifoldLearning.swiss_roll(n, noise; segments, hlims, rng)
@head X = Xt'


labs = vec(L)
tab(labs)


CairoMakie.activate!()  
#GLMakie.activate!()    # for interactive axe-rotation


mks = 10
i = 1
plotxyz(X[:, i], X[:, i + 1], X[:, i + 2], labs; size = (700, 500), markersize = 10, 
    xlabel = string("x", i), ylabel = string("x", i + 1), zlabel = string("x", i + 2), 
    title = "Swiss roll").f


nlv = 2
model = pcasvd(; nlv)
fit!(model, X)
@head T = model.fitm.T


i = 1
plotxy(T[:, i], T[:, i + 1]; color = labs,
    xlabel = string("LV", i), ylabel = string("LV", i + 1), title = "Pca").f


nlv = 2
n_neighbors = 15; min_dist = .5 
model = umap(; nlv, n_neighbors, min_dist)
fit!(model, X)
@head T = model.fitm.T


i = 1
plotxy(T[:, i], T[:, i + 1]; color = labs,
    xlabel = string("LV", i), ylabel = string("LV", i + 1), title = "Umap").f


p = 30
maxoutdim = 2
M = ManifoldLearning.fit(TSNE, X'; p, maxoutdim) 
Tt =  ManifoldLearning.predict(M) 
@head T = Tt'


i = 1
plotxy(T[:, i], T[:, i + 1]; color = labs,
    xlabel = string("LV", i), ylabel = string("LV", i + 1), title = "t-SNE").f


nlv = 2
kern = :krbf; gamma = 1e-2
model = kpca(; nlv, kern, gamma)
fit!(model, X)
@head T = model.fitm.T


i = 1
plotxy(T[:, i], T[:, i + 1]; color = labs,
    xlabel = string("LV", i), ylabel = string("LV", i + 1), title = "Kpca").f


nlv = 2
kern = :kpol
gamma = 1; degree = 3; coef0 = 10
model = kpca(; nlv, kern, degree, gamma, coef0)
fit!(model, X)
@head T = model.fitm.T  
i = 1
plotxy(T[:, i], T[:, i + 1]; color = labs,
    xlabel = string("LV", i), ylabel = string("LV", i + 1), title = "Kpca").f

