
using Jchemo, JchemoData
using JLD2, CairoMakie


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data", "iris.jld2") 
@load db dat
@names dat


summ(dat.X)


@head X = dat.X[:, 1:4] 
@head y = dat.X[:, 5]    # the classes (species)
ntot = nro(X)


tab(y)


lev = mlev(y)
nlev = length(lev)


ntest = 30
s = samprand(ntot, ntest)
Xtrain = X[s.train, :] ;
ytrain = y[s.train] ;
Xtest = X[s.test, :] ;
ytest = y[s.test] ;
ntrain = ntot - ntest
(ntot = ntot, ntrain, ntest)
tab(ytrain)
tab(ytest)


Ytrain_dummy = dummy(ytrain).Y


nlv = 2
model = plskern(; nlv)
fit!(model, Xtrain, Ytrain_dummy)


@head Ttrain = model.fitm.T
@head Ttest = transf(model, Xtest)


i = 1
plotxy(Ttrain[:, i], Ttrain[:, i + 1], ytrain; title = "PLS2 space -Train", xlabel = string("LV", i), 
    ylabel = string("LV", i + 1), leg_title = "Species", zeros = true, ellipse = false).f


k = 1  # example of the projection of the first obs. of Test


f = Figure(size = (900, 300)) ;
ax = list(nlev) ;
for i in eachindex(lev) 
    zs = ytrain .== lev[i]
    zT = Ttrain[zs, :]
    ax[i] = Axis(f[1, i]; title = lev[i], xlabel = "PLS-LV1", ylabel = "PLS-LV2")
    scatter!(ax[i], zT[:, 1], zT[:, 2], color = :red, markersize = 10)
    ## New point to predict
    scatter!(ax[i], Ttest[k, 1], Ttest[k, 2], color = :blue, marker = :star5, markersize = 15)
    ## End
    hlines!(ax[i], 0; linestyle = :dash, color = :grey)
    vlines!(ax[i], 0; linestyle = :dash, color = :grey)
    xlims!(ax[i], -4, 4) ; ylims!(ax[i], -1.7, 1.7)
end
f


weights = mweight(ones(ntrain))   # observation weights
res = matW(Ttrain, ytrain, weights)
W = res.W * ntrain / (ntrain - nlev)
npoints = 2^7
x1 = LinRange(-4, 4, npoints)
x2 = LinRange(-2, 2, npoints)
z = mpar(x1 = x1, x2 = x2)
grid = reduce(hcat, z)
f = Figure(size = (900, 400)) ;
ax = list(nlev) ;
for i in eachindex(lev) 
    zs = ytrain .== lev[i]
    zT = Ttrain[zs, :]
    #lims = [[minimum(zT[:, j]) ; maximum(zT[:, j])] for j = 1:nlv]
    #x1 = LinRange(lims[1][1], lims[1][2], npoints)
    #x2 = LinRange(lims[2][1], lims[2][2], npoints)
    zfitm = dmnorm(colmean(zT), W)   # Gaussian estimate
    zres = predict(zfitm, grid) 
    pred_grid = vec(zres.pred)
    ax[i] = Axis(f[1, i]; title = lev[i], xlabel = "LV1", ylabel = "LV2")
    co = contourf!(ax[i], grid[:, 1], grid[:, 2], pred_grid; levels = 10)
    scatter!(ax[i], zT[:, 1], zT[:, 2], color = :red, markersize = 10)
    scatter!(ax[i], Ttest[k, 1], Ttest[k, 2], color = :blue, marker = :star5, markersize = 15)
    hlines!(ax[i], 0; linestyle = :dash, color = :grey)
    vlines!(ax[i], 0; linestyle = :dash, color = :grey)
    xlims!(ax[i], -4, 4) ; ylims!(ax[i], -1.7, 1.7)
    Colorbar(f[2, i], co; label = "Density", vertical = false)
end
f


res = matW(Ttrain, ytrain, weights)
Wi = res.Wi
ni = res.ni
npoints = 2^7 ;
x1 = LinRange(-4, 4, npoints) ;
x2 = LinRange(-2, 2, npoints) ;
z = mpar(x1 = x1, x2 = x2) ;
grid = reduce(hcat, z) ;
z = mpar(x1 = x1, x2 = x2) ;
grid = reduce(hcat, z) ;
f = Figure(size = (900, 400)) ;
ax = list(nlev) ;
for i in eachindex(lev) 
    zs = ytrain .== lev[i]
    zT = Ttrain[zs, :]
    zS = Wi[i] * ni[i] / (ni[i] - 1)
    zfitm = dmnorm(colmean(zT), zS) ;   # Gaussian estimate
    zres = predict(zfitm, grid) ;
    pred_grid = vec(zres.pred) 
    ax[i] = Axis(f[1, i]; title = lev[i], xlabel = "LV1", ylabel = "LV2")
    co = contourf!(ax[i], grid[:, 1], grid[:, 2], pred_grid; levels = 10)
    scatter!(ax[i], zT[:, 1], zT[:, 2], color = :red, markersize = 10)
    scatter!(ax[i], Ttest[k, 1], Ttest[k, 2], color = :blue, marker = :star5, markersize = 15)
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
f = Figure(size = (900, 400)) ;
ax = list(nlev) ;
for i in eachindex(lev) 
    zs = ytrain .== lev[i]
    zT = Ttrain[zs, :]
    zfitm = dmkern(zT; a = .5)   # KDE estimate
    zres = predict(zfitm, grid) ;
    pred_grid = vec(zres.pred)
    ax[i] = Axis(f[1, i]; title = lev[i], xlabel = "LV1", ylabel = "LV2")
    co = contourf!(ax[i], grid[:, 1], grid[:, 2], pred_grid; levels = 10)
    scatter!(ax[i], zT[:, 1], zT[:, 2], color = :red, markersize = 10)
    scatter!(ax[i], Ttest[k, 1], Ttest[k, 2], color = :blue, marker = :star5, markersize = 15)
    hlines!(ax[i], 0; linestyle = :dash, color = :grey)
    vlines!(ax[i], 0; linestyle = :dash, color = :grey)
    xlims!(ax[i], -4, 4) ; ylims!(ax[i], -1.7, 1.7)
    Colorbar(f[2, i], co; label = "Density", vertical = false)
end
f

