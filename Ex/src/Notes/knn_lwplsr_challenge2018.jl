
using Jchemo, JchemoData
using JLD2, CairoMakie
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/challenge2018.jld2") 
@load db dat
@names dat
X = dat.X 
Y = dat.Y
y = dat.Y.conc  
model1 = snv()
model2 = savgol(npoint = 21, deriv = 2, degree = 3)
model = pip(model1, model2)
fit!(model, X)
Xp = transf(model, X)  
s = Bool.(Y.test)
Xtrain = rmrow(Xp, s)
Ytrain = rmrow(Y, s)
ytrain = rmrow(y, s)
typtrain = rmrow(Y.typ, s)
Xtest = Xp[s, :]
Ytest = Y[s, :]
ytest = y[s]
typtest = Y.typ[s]
## Nearest neighbors
model = plskern(nlv = 3) 
fit!(model, Xtrain, ytrain) 
T = model.fitm.T
Tnew = transf(model, Xtest)
k = 100; i = 10 
res = getknn(T, Tnew[i:i, :]; k = k, metric = :mah)
s = res.ind[1]
#CairoMakie.activate!()  
#GLMakie.activate!()  
f = Figure(size = (700, 500))
mks = 8
ax = Axis3(f[1, 1]; xlabel = "LV1", ylabel = "LV2", zlabel = "LV3", perspectiveness = 0.5) 
scatter!(ax, T[:, 1], T[:, 2], T[:, 3]; markersize = mks, color = (:grey, .3))
scatter!(ax, T[s, 1], T[s, 2], T[s, 3]; markersize = mks, color = (:blue, .3))
scatter!(ax, Tnew[i:i, 1], Tnew[i:i, 2], Tnew[i:i, 3]; markersize = 10, color = (:red, .8))
cols = [:grey; :blue; :red]
elt = [MarkerElement(color = cols[i], marker = '●', markersize = 10) for i in 1:3]
lab = ["Training obs."; "Neighborhood"; "xnew (to predict)"]
#title = "kNN selection"
#Legend(f[1, 2], elt, lab, title; nbanks = 1, rowgap = 10, framevisible = false)
Legend(f[1, 2], elt, lab; nbanks = 1, rowgap = 10, framevisible = false)
f


i = 300
res = getknn(T, Tnew[i:i, :]; k = k, metric = :mah)
s = res.ind[1] 
f = Figure(size = (700, 500))
mks = 10
ax = Axis3(f[1, 1]; xlabel = "LV1", ylabel = "LV2", zlabel = "LV3", perspectiveness = 0.5) 
scatter!(ax, T[:, 1], T[:, 2], T[:, 3]; markersize = mks, color = (:grey, .3))
scatter!(ax, T[s, 1], T[s, 2], T[s, 3]; markersize = mks, color = (:blue, .3))
scatter!(ax, Tnew[i:i, 1], Tnew[i:i, 2], Tnew[i:i, 3]; markersize = 10, color = (:red, .8))
cols = [:grey; :blue; :red]
elt = [MarkerElement(color = cols[i], marker = '●', markersize = 10) for i in 1:3]
lab = ["Training obs."; "Neighborhood"; "xnew (to predict)"]
Legend(f[1, 2], elt, lab; nbanks = 1, rowgap = 10, framevisible = false)
f


?lwplsr

  lwplsr(; kwargs...)
  lwplsr(X, Y; kwargs...)

  k-Nearest-Neighbours locally weighted partial least squares regression (kNN-LWPLSR).

    •  X : X-data (n, p).

    •  Y : Y-data (n, q).

  Keyword arguments:

    •  nlvdis : Number of latent variables (LVs) to consider in the global PLS used for the dimension reduction before computing the dissimilarities. If nlvdis = 0, there is no dimension reduction.

    •  metric : Type of dissimilarity used to select the neighbors and to compute the weights (see function getknn). Possible values are: :eucl (Euclidean), :mah (Mahalanobis), :sam (spectral angular
       distance), :cor (correlation distance).

    •  h : A scalar defining the shape of the weight function computed by function winvs. Lower is h, sharper is the function. See function winvs for details (keyword arguments criw and squared of winvs
       can also be specified here).

    •  k : The number of nearest neighbors to select for each observation to predict.

    •  tolw : For stabilization when very close neighbors.

    •  nlv : Nb. latent variables (LVs) for the local (i.e. inside each neighborhood) models.

    •  scal : Boolean. If true, (a) each column of the global X (and of the global Y if there is a preliminary PLS reduction dimension) is scaled by its uncorrected standard deviation before to compute
       the distances and the weights, and (b) the X and Y scaling is also done within each neighborhood (local level) for the weighted PLSR.

    •  verbose : Boolean. If true, predicting information are printed.

  [...]


using Jchemo
@pars lwplsr


•  metric : Type of distance used for the query. Possible values are :eucl (Euclidean), :mah (Mahalanobis), :sam (spectral angular
       distance), :cor (correlation distance).


using Distributions
x1 = rand(Chisq(10), 100)
x2 = rand(Chisq(40), 10)
d = [sqrt.(x1); sqrt.(x2)]
f = Figure(size = (1000, 200))
ax1 = Axis(f, xlabel = "Distance", ylabel = "Nb. observations",)
hist!(ax1, d, bins = 30)
##
h = 1
w = winvs(d; h) 
ax2 = Axis(f, xlabel = "Distance", ylabel = "Weight", title = "h = 1")
scatter!(ax2, d, w)
##
h = 4
w = winvs(d; h) 
ax3 = Axis(f, xlabel = "Distance", ylabel = "Weight", title = "h = 4")
scatter!(ax3, d, w)
##
h = 10
w = winvs(d; h) 
ax4 = Axis(f, xlabel = "Distance", ylabel = "Weight", title = "h = 10")
scatter!(ax4, d, w)
##
h = Inf
w = winvs(d; h) 
ax5 = Axis(f, xlabel = "Distance", ylabel = "Weight", title = "h = Inf")
scatter!(ax5, d, w)
##
f[1, 1] = ax1
f[1, 2] = ax2
f[1, 3] = ax3
f[1, 4] = ax4
f[1, 5] = ax5
f


## Preliminary loading of packages
using Jchemo       # if not loaded before
using JchemoData   # a library of various benchmark datasets
using JLD2         # a Julia data format 
using CairoMakie   # making graphics 
using FreqTables   # utilities for frequency tables


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/challenge2018.jld2") 
@load db dat
@names dat


X = dat.X
@head X


Y = dat.Y
@head Y


y = Y.conc        # variable to predict (protein concentration)


wlst = names(X)     # wavelengths
wl = parse.(Float64, wlst)


ntot, p = size(X)


freqtable(string.(Y.typ, " - ", Y.label))


plotsp(X, wl; size = (500, 300), nsamp = 30, xlabel = "Wavelength (nm)", ylabel = "Reflectance").f


model1 = snv()
model2 = savgol(npoint = 21, deriv = 2, degree = 3)
model = pip(model1, model2)
fit!(model, X)
@head Xp = transf(model, X)


plotsp(Xp, wl; size = (500, 300), nsamp = 30, xlabel = "Wavelength (nm)").f


lev = mlev(Y.typ)
nlev = length(lev)
ztyp = recod_catbyint(Y.typ)
nlv = 3
model = pcasvd(; nlv)
fit!(model, X)
T = model.fitm.T
colm = cgrad(:tab10, nlev; categorical = true, alpha = .5)
i = 1
f = Figure(size = (700, 500))
ax = Axis3(f[1, 1]; xlabel = string("LV", i), ylabel = string("LV", i + 1), 
        zlabel = string("LV", i + 2), title = "PCA", perspectiveness = .3) 
scatter!(ax, T[:, i], T[:, i + 1], T[:, i + 2]; markersize = 6, 
    color = ztyp, colormap = colm)   
elt = [MarkerElement(color = colm[i], marker = '●', markersize = 10) for i in 1:nlev]
#elt = [PolyElement(polycolor = colm[i]) for i in 1:nlev]
title = "Type"
Legend(f[1, 2], elt, lev, title; nbanks = 1, rowgap = 10, framevisible = false)
f


freqtable(Y.test)


s = Bool.(Y.test)  # same as: s = Y.test .== 1
Xtrain = rmrow(Xp, s)
Ytrain = rmrow(Y, s)
ytrain = rmrow(y, s)
typtrain = rmrow(Y.typ, s)
Xtest = Xp[s, :]
Ytest = Y[s, :]
ytest = y[s]
typtest = Y.typ[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)


model = pcasvd(nlv = 15)
fit!(model, Xtrain)
Ttrain = model.fitm.T
Ttest = transf(model, Xtest)
T = vcat(Ttrain, Ttest)
group = vcat(repeat(["0-Train";], ntrain), repeat(["1-Test";], ntest))
colm = [:blue, (:red, .5)]
i = 1
plotxy(T[:, i], T[:, i + 1], group; size = (500, 300), color = colm, xlabel = "PC1", ylabel = "PC2").f


model_sd = occsd() 
fit!(model_sd, model.fitm)
@names model_sd
sdtrain = model_sd.fitm.d
sdtest = predict(model_sd, Xtest).d
model_od = occod() 
fit!(model_od, model.fitm, Xtrain)
@names model_od
odtrain = model_od.fitm.d
odtest = predict(model_od, Xtest).d
f = Figure(size = (500, 300))
ax = Axis(f; xlabel = "SD", ylabel = "OD")
scatter!(ax, sdtrain.dstand, odtrain.dstand, label = "Train")
scatter!(ax, sdtest.dstand, odtest.dstand, color = (:red, .5), label = "Test")
hlines!(ax, 1; color = :grey, linestyle = :dash)
vlines!(ax, 1; color = :grey, linestyle = :dash)
axislegend(position = :rt)
f[1, 1] = ax
f


summ(y, Y.test)


f = Figure(size = (500, 300))
ax = Axis(f[1, 1]; xlabel = "Protein", ylabel = "Nb. observations")
hist!(ax, ytrain; bins = 50, label = "Train")
hist!(ax, ytest; bins = 50, label = "Test")
axislegend(position = :rt)
f


nval = 300
s = sampsys(1:ntrain, nval)
Xcal = Xtrain[s.train, :]
ycal = ytrain[s.train]
Xval = Xtrain[s.test, :]
yval = ytrain[s.test]
ncal = ntrain - nval
(ntot = ntot, ntrain, ntest, ncal, nval)


## Below, more extended combinations could be considered (this is simplification for the example)
nlvdis = [15]; metric = [:mah] 
h = [1; 2; 4; 6; Inf]
k = [200; 350; 500; 1000]  
nlv = 0:15 
pars = mpar(nlvdis = nlvdis, metric = metric, h = h, k = k)  # the grid
length(pars[1])  # nb. parameter combinations considered


model = lwplsr()
res = gridscore(model, Xcal, ycal, Xval, yval; score = rmsep, pars, nlv, verbose = false)
@head res   # first rows of the result table


group = string.("nlvdis=", res.nlvdis, ", h=", res.h, ", k=", res.k)
plotgrid(res.nlv, res.y1, group; step = 1, xlabel ="Nb. LVs", ylabel = "RMSEP (Validation)").f


u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]


model = lwplsr(nlvdis = res.nlvdis[u], metric = res.metric[u], h = res.h[u], 
    k = res.k[u], nlv = res.nlv[u])
fit!(model, Xtrain, ytrain)
pred = predict(model, Xtest).pred
@head pred


mse(pred, ytest)
rmsep(pred, ytest)    # estimate of generalization error


plotxy(pred, ytest; color = (:red, .5), bisect = true, xlabel = "Predictions", 
    ylabel = "Observed test data", title = "Protein concentration (%)").f

