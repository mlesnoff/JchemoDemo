using JLD2, CairoMakie
using Jchemo

using JchemoData
mypath = dirname(dirname(pathof(JchemoData)))
db = joinpath(mypath, "data", "iris.jld2") 
@load db dat
pnames(dat)
summ(dat.X)
  
X = dat.X[:, 1:4] 
y = dat.X[:, 5]
n = nro(X)
  
head(X)
tab(y)
lev = unique(y)
nlev = length(lev)

Ydummy = dummy(y).Y
nlv = 2
fm = plskern(X, Ydummy; nlv = nlv) ; 
T = fm.T
i = 1
plotxy(T[:, i:(i + 1)], y;
    title = "PLS2 space", 
    xlabel = string("LV", i), ylabel = string("LV", i + 1),
    zeros = true, ellipse = false).f

#### Scatters  
f = Figure(resolution = (900, 300))
ax = list(nlev) 
for i = 1:nlev 
    s = y .== lev[i]
    zT = T[s, :]
    ax[i] = Axis(f[1, i]; title = lev[i],
        xlabel = "LV1", ylabel = "LV2")
    scatter!(ax[i], zT[:, 1], zT[:, 2],
        color = :red, markersize = 10)
    k = 150
    scatter!(ax[i], T[k, 1], T[k, 2],
        color = :blue, marker = :star5, markersize = 15)
    hlines!(ax[i], 0; linestyle = "-", color = :grey)
    vlines!(ax[i], 0; linestyle = "-", color = :grey)
    xlims!(ax[i], -4, 4) ; ylims!(ax[i], -1.7, 1.7)
end
f

#### LDA
W = matW(T, y).W
npoints = 2^7
x1 = LinRange(-4, 4, npoints)
x2 = LinRange(-2, 2, npoints)
f = Figure(resolution = (900, 300))
ax = list(nlev) 
for i = 1:nlev 
    s = y .== lev[i]
    zT = T[s, :]
    #lims = [[minimum(zT[:, j]) ; maximum(zT[:, j])] for j = 1:nlv]
    #x1 = LinRange(lims[1][1], lims[1][2], npoints)
    #x2 = LinRange(lims[2][1], lims[2][2], npoints)
    z = mpar(x1 = x1, x2 = x2)
    grid = reduce(hcat, z)
    m = nro(grid)
    fm = dmnorm(zT; S = W) ;
    res = Jchemo.predict(fm, grid) ;
    pred_grid = vec(res.pred)
    ax[i] = Axis(f[1, i]; title = lev[i],
        xlabel = "LV1", ylabel = "LV2")
    co = contour!(ax[i], grid[:, 1], grid[:, 2], pred_grid; levels = 10)
    scatter!(ax[i], zT[:, 1], zT[:, 2],
        color = :red, markersize = 10)
    k = 150
    scatter!(ax[i], T[k, 1], T[k, 2],
        color = :blue, marker = :star5, markersize = 15)
    hlines!(ax[i], 0; linestyle = "-", color = :grey)
    vlines!(ax[i], 0; linestyle = "-", color = :grey)
    xlims!(ax[i], -4, 4) ; ylims!(ax[i], -1.7, 1.7)
    if i == nlev
        Colorbar(f[1, nlev + 1], co; label = "Density")
    end
end
f

#### QDA
npoints = 2^7
x1 = LinRange(-4, 4, npoints)
x2 = LinRange(-2, 2, npoints)
f = Figure(resolution = (900, 300))
ax = list(nlev) 
for i = 1:nlev 
    s = y .== lev[i]
    zT = T[s, :]
    z = mpar(x1 = x1, x2 = x2)
    grid = reduce(hcat, z)
    m = nro(grid)
    fm = dmnorm(zT) ;
    res = Jchemo.predict(fm, grid) ;
    pred_grid = vec(res.pred)
    ax[i] = Axis(f[1, i]; title = lev[i],
        xlabel = "LV1", ylabel = "LV2")
    co = contour!(ax[i], grid[:, 1], grid[:, 2], pred_grid; levels = 10)
    scatter!(ax[i], zT[:, 1], zT[:, 2],
        color = :red, markersize = 10)
    k = 150
    scatter!(ax[i], T[k, 1], T[k, 2],
        color = :blue, marker = :star5, markersize = 15)
    hlines!(ax[i], 0; linestyle = "-", color = :grey)
    vlines!(ax[i], 0; linestyle = "-", color = :grey)
    xlims!(ax[i], -4, 4) ; ylims!(ax[i], -1.7, 1.7)
    if i == nlev
        Colorbar(f[1, nlev + 1], co; label = "Density")
    end
end
f

#### Non-parametric
npoints = 2^7
x1 = LinRange(-4, 4, npoints)
x2 = LinRange(-2, 2, npoints)
f = Figure(resolution = (900, 300))
ax = list(nlev) 
for i = 1:nlev 
    s = y .== lev[i]
    zT = T[s, :]
    z = mpar(x1 = x1, x2 = x2)
    grid = reduce(hcat, z)
    m = nro(grid)
    fm = dmkern(zT; a = 1) ;
    res = Jchemo.predict(fm, grid) ;
    pred_grid = vec(res.pred)
    ax[i] = Axis(f[1, i]; title = lev[i],
        xlabel = "LV1", ylabel = "LV2")
    co = contour!(ax[i], grid[:, 1], grid[:, 2], pred_grid; levels = 10)
    scatter!(ax[i], zT[:, 1], zT[:, 2],
        color = :red, markersize = 10)
    k = 150
    scatter!(ax[i], T[k, 1], T[k, 2],
        color = :blue, marker = :star5, markersize = 15)
    hlines!(ax[i], 0; linestyle = "-", color = :grey)
    vlines!(ax[i], 0; linestyle = "-", color = :grey)
    xlims!(ax[i], -4, 4) ; ylims!(ax[i], -1.7, 1.7)
    if i == nlev
        Colorbar(f[1, nlev + 1], co; label = "Density")
    end
end
f
