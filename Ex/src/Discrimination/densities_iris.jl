
using Jchemo, JchemoData
using JLD2, CairoMakie


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data", "iris.jld2") 
@load db dat
pnames(dat)


summ(dat.X)


X = dat.X[:, 1:4] 
y = dat.X[:, 5]
n = nro(X)


@head X


tab(y)


lev = unique(y)


nlev = length(lev)


Ydummy = dummy(y).Y ;
@head Ydummy


nlv = 2
mod = model(plskern; nlv)
fit!(mod, X, Ydummy)


@head T = mod.fm.T


i = 1
plotxy(T[:, i], T[:, i + 1], y; title = "PLS2 space", xlabel = string("LV", i), 
    ylabel = string("LV", i + 1), zeros = true, ellipse = false).f


f = Figure(size = (900, 300))
ax = list(nlev) 
for i = 1:nlev 
    s = y .== lev[i]
    zT = T[s, :]
    ax[i] = Axis(f[1, i]; title = lev[i], xlabel = "LV1", ylabel = "LV2")
    scatter!(ax[i], zT[:, 1], zT[:, 2], color = :red, markersize = 10)
    ## Fictive "new" point to predict
    k = 150
    scatter!(ax[i], T[k, 1], T[k, 2], color = :blue, marker = :star5, markersize = 15)
    ## End
    hlines!(ax[i], 0; linestyle = :dash, color = :grey)
    vlines!(ax[i], 0; linestyle = :dash, color = :grey)
    xlims!(ax[i], -4, 4) ; ylims!(ax[i], -1.7, 1.7)
end
f


weights = mweight(ones(n))
res = matW(T, y, weights)
W = res.W * n / (n - nlev)
npoints = 2^7
x1 = LinRange(-4, 4, npoints)
x2 = LinRange(-2, 2, npoints)
z = mpar(x1 = x1, x2 = x2)
grid = reduce(hcat, z)
f = Figure(size = (900, 400))
ax = list(nlev) 
for i = 1:nlev 
    s = y .== lev[i]
    zT = T[s, :]
    #lims = [[minimum(zT[:, j]) ; maximum(zT[:, j])] for j = 1:nlv]
    #x1 = LinRange(lims[1][1], lims[1][2], npoints)
    #x2 = LinRange(lims[2][1], lims[2][2], npoints)
    zfm = dmnorm(zT; S = W) ;
    zres = predict(zfm, grid) ;
    pred_grid = vec(zres.pred)
    ax[i] = Axis(f[1, i]; title = lev[i], xlabel = "LV1", ylabel = "LV2")
    co = contourf!(ax[i], grid[:, 1], grid[:, 2], pred_grid; levels = 10)
    scatter!(ax[i], zT[:, 1], zT[:, 2], color = :red, markersize = 10)
    k = 150
    scatter!(ax[i], T[k, 1], T[k, 2], color = :blue, marker = :star5, markersize = 15)
    hlines!(ax[i], 0; linestyle = :dash, color = :grey)
    vlines!(ax[i], 0; linestyle = :dash, color = :grey)
    xlims!(ax[i], -4, 4) ; ylims!(ax[i], -1.7, 1.7)
    Colorbar(f[2, i], co; label = "Density", vertical = false)
end
f


res = matW(T, y, weights)
Wi = res.Wi
ni = res.ni
npoints = 2^7
x1 = LinRange(-4, 4, npoints)
x2 = LinRange(-2, 2, npoints)
z = mpar(x1 = x1, x2 = x2)
grid = reduce(hcat, z)
z = mpar(x1 = x1, x2 = x2)
grid = reduce(hcat, z)
f = Figure(size = (900, 400))
ax = list(nlev) 
for i = 1:nlev 
    s = y .== lev[i]
    zT = T[s, :]
    S = Wi[i] * ni[i] / (ni[i] - 1)
    zfm = dmnorm(zT; S = S) ;
    zres = predict(zfm, grid) ;
    pred_grid = vec(zres.pred) 
    ax[i] = Axis(f[1, i]; title = lev[i], xlabel = "LV1", ylabel = "LV2")
    co = contourf!(ax[i], grid[:, 1], grid[:, 2], pred_grid; levels = 10)
    scatter!(ax[i], zT[:, 1], zT[:, 2], color = :red, markersize = 10)
    k = 150
    scatter!(ax[i], T[k, 1], T[k, 2], color = :blue, marker = :star5, markersize = 15)
    hlines!(ax[i], 0; linestyle = :dash, color = :grey)
    vlines!(ax[i], 0; linestyle = :dash, color = :grey)
    xlims!(ax[i], -4, 4) ; ylims!(ax[i], -1.7, 1.7)
    Colorbar(f[2, i], co; label = "Density", vertical = false)
end
f


npoints = 2^7
x1 = LinRange(-4, 4, npoints)
x2 = LinRange(-2, 2, npoints)
z = mpar(x1 = x1, x2 = x2)
grid = reduce(hcat, z)
f = Figure(size = (900, 400))
ax = list(nlev) 
for i = 1:nlev 
    s = y .== lev[i]
    zT = T[s, :]
    zfm = dmkern(zT; a_kde = 1) 
    zres = predict(zfm, grid) ;
    pred_grid = vec(zres.pred)
    ax[i] = Axis(f[1, i]; title = lev[i], xlabel = "LV1", ylabel = "LV2")
    co = contourf!(ax[i], grid[:, 1], grid[:, 2], pred_grid; levels = 10)
    scatter!(ax[i], zT[:, 1], zT[:, 2], color = :red, markersize = 10)
    k = 150
    scatter!(ax[i], T[k, 1], T[k, 2], color = :blue, marker = :star5, markersize = 15)
    hlines!(ax[i], 0; linestyle = :dash, color = :grey)
    vlines!(ax[i], 0; linestyle = :dash, color = :grey)
    xlims!(ax[i], -4, 4) ; ylims!(ax[i], -1.7, 1.7)
    Colorbar(f[2, i], co; label = "Density", vertical = false)
end
f

