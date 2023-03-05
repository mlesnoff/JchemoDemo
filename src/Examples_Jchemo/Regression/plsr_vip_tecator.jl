using JLD2, CairoMakie
using Jchemo, JchemoData
using Loess

mypath = dirname(dirname(pathof(JchemoData)))
db = joinpath(mypath, "data", "tecator.jld2") 
@load db dat
pnames(dat)

X = dat.X
Y = dat.Y 
wl = names(X)
wl_num = parse.(Float64, wl) 
ntot, p = size(X)
typ = Y.typ
namy = names(Y)[1:3]

plotsp(X, wl_num,
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 
plotsp(Xp, wl_num,
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

s = typ .== "train"
Xtrain = Xp[s, :]
Ytrain = Y[s, namy]
Xtest = rmrow(Xp, s)
Ytest = rmrow(Y[:, namy], s)
ntrain = nro(Xtrain)
ntest = nro(Xtest)
ntot = ntrain + ntest
(ntot = ntot, ntrain, ntest)

## Work on the second y-variable 
j = 2
nam = namy[j]
ytrain = Ytrain[:, nam]
ytest = Ytest[:, nam]

#### PLSR
segm = segmkf(ntrain, 5; rep = 30)
nlv = 0:20
res = gridcvlv(Xtrain, ytrain; segm = segm,
    fun = plskern, score = rmsep, nlv = nlv).res
plotgrid(res.nlv, res.y1; step = 2,
    xlabel = "Nb. LVs", ylabel = "REMSP_CV").f
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = plskern(Xtrain, ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest).pred
println(rmsep(pred, ytest))
plotxy(vec(pred), ytest; color = (:red, .5), 
    bisect = true).f

z = rd(ytrain, fm.T) 
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1]; xticks = 1:9,
    xlabel = "LV", ylabel = "R2( ytrain, t )")
barplot!(ax, vec(z); width = .5,
    color = (:red, .5))
f

#### ISEL
nint = 10
res = isel(Xtrain, ytrain, wl_num; nint = nint, 
    rep = 30, fun = plskern, nlv = 5) ;
res.res_rep
res.res0_rep
zres = res.res
zres0 = res.res0
f = Figure(resolution = (650, 300))
ax = Axis(f[1, 1],
    xlabel = "Wawelength (nm)", ylabel = "RMSEP_Val",
    xticks = zres.lo)
scatter!(ax, zres.mid, zres.y1; color = (:red, .5))
vlines!(ax, zres.lo; color = :grey,
    linestyle = :dash, linewidth = 1)
hlines!(ax, zres0.y1, linestyle = :dash)
f

s = (wl_num .>= 910) .& (wl_num .<= 950)
wl[s]
segm = segmkf(ntrain, 5; rep = 30)
nlv = 0:20
res = gridcvlv(Xtrain[:, s], ytrain; segm = segm,
    fun = plskern, score = rmsep, nlv = nlv).res
plotgrid(res.nlv, res.y1; step = 2,
    xlabel = "Nb. LVs", ylabel = "REMSP_CV").f
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = plskern(Xtrain[:, s], ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest[:, s]).pred
println(rmsep(pred, ytest))
plotxy(vec(pred), ytest; color = (:red, .5), 
    bisect = true).f

nint = 10
res = isel(Xtrain, ytrain, wl_num; nint = nint, 
    rep = 30, fun = krr, gamma = 100, lb = .001) ;
res.res_rep
res.res0_rep
zres = res.res
zres0 = res.res0
f = Figure(resolution = (650, 300))
ax = Axis(f[1, 1],
    xlabel = "Wawelength (nm)", ylabel = "RMSEP_Val",
    xticks = zres.lo)
scatter!(ax, zres.mid, zres.y1; color = (:red, .5))
vlines!(ax, zres.lo; color = :grey,
    linestyle = :dash, linewidth = 1)
hlines!(ax, zres0.y1, linestyle = :dash)
f

#### VIP
nlv = 9
fm = plskern(Xtrain, ytrain; nlv = nlv) ;
res = vip(fm)
#z = abs.(vec(coef(fm).B))
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1];
    xlabel = "Wavelength (nm)", 
    ylabel = "VIP")
scatter!(ax, wl_num, res.imp; color = (:red, .5))
u = [910; 950]
vlines!(ax, u; color = :grey, linewidth = 1)
hlines!(ax, 1)
f

res.W2
plotsp(res.W2[:, 1:2]', wl_num;
    xlabel = "Wavelength (nm)", ylabel = "w ²").f

s = res.imp .> 1.5
wl[s]
segm = segmkf(ntrain, 4; rep = 30)
nlv = 0:50
res = gridcvlv(Xtrain[:, s], ytrain; segm = segm,
    fun = plskern, score = rmsep, nlv = nlv).res
plotgrid(res.nlv, res.y1; step = 1).f
u = findall(res.y1 .== minimum(res.y1))[1] 
res[u, :]
fm = plskern(Xtrain[:, s], ytrain; nlv = res.nlv[u]) ;
pred = Jchemo.predict(fm, Xtest[:, s]).pred
rmsep(pred, ytest)

#### COVSELR
segm = segmkf(ntrain, 5; rep = 30)
nlv = 1:20
pars = mpar(nlv = nlv, typ = ["cov"])
res = gridcv(Xtrain, ytrain; segm = segm,
    score = rmsep, fun = covselr, pars = pars,
    verbose = true).res  
u = findall(res.y1 .== minimum(res.y1))[1]
res[u, :]
plotgrid(res.nlv, res.y1; step = 2,
    xlabel = "Nb. LVs", ylabel = "REMSP_CV").f
fm = covselr(Xtrain, ytrain; nlv = res.nlv[u],
    typ = "cov") ;
pred = Jchemo.predict(fm, Xtest).pred
println(rmsep(pred, ytest))
plotxy(vec(pred), ytest; color = (:red, .5), 
    bisect = true).f

nlv = 10
res = covsel(Xtrain, ytrain; 
    nlv = nlv) ;
sel = res.sel
selw = wl_num[sel.sel]
C = res.C

f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], yticks = 1:10,
    xlabel = "Wavelength (nm)", 
    ylabel = "Importance order of the variable in Covsel")
scatter!(ax, selw, 1:10)
u = [910; 950]
vlines!(ax, u; linewidth = 1, color = :grey)
f

i = 1
u = [910; 950]
f, ax = plotsp(sqrt.(C[:, i]'), wl_num;
    xlabel = "Wavelength (nm)", ylabel = "abs.(cov)")
vlines!(ax, u; linewidth = 1, color = :grey)
f

u = [910; 950]
f = Figure(resolution = (1000, 1000))
k = 1
for i in 1:2, j in 1:5
    ax = Axis(f[j, i]; ylabel = "abs.(cov)", 
        title = string(k, "- wl=", wl[sel.sel[k]]))
    #lines!(ax, wl_num, sqrt.(C[:, k]))
    scatter!(ax, wl_num, sqrt.(C[:, k]))
    vlines!(ax, u)
    vlines!(ax, selw[k]; color = :red, linestyle = :dash)
    k += 1
end
f

#### Bagging RFR
fm = rfr_xgb(Xtrain, ytrain; rep = 100, 
    subsample = .7,
    colsample_bynode = 1/3,
    max_depth = 2000, min_child_weight = 5) ;
pred = Jchemo.predict(fm, Xtest).pred ;
println(rmsep(pred, ytest))
plotxy(vec(pred), ytest; color = (:red, .5), 
    bisect = true).f
res = vi_xgb(fm)
nam = "total_gain"
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1];
    xlabel = "Wavelength (nm)", 
    ylabel = "Importance")
scatter!(ax, wl_num, res[:, nam]; color = (:red, .5))
u = [910; 950]
vlines!(ax, u; color = :grey,
    linewidth = 1)
f

fm = baggr(Xtrain, ytrain; rep = 100, 
    rowsamp = .7, colsamp = 1,
    fun = treer_xgb, 
    subsample = 1, colsample_bynode = 1/3,
    max_depth = 2000, min_child_weight = 5) ;
pred = Jchemo.predict(fm, Xtest).pred ;
println(rmsep(pred, ytest))
res = vi_baggr(fm, Xtrain, ytrain)
z = vec(res.imp)
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1];
    xlabel = "Wavelength (nm)", 
    ylabel = "Importance")
scatter!(ax, wl_num, z; color = (:red, .5))
u = [910; 950]
vlines!(ax, u; color = :grey, linewidth = 1)
f

#### Bagging Xgboostr
fm = xgboostr(Xtrain, ytrain; rep = 100, 
    eta = .1, 
    subsample = .7, colsample_bynode = 1/3,
    max_depth = 2000, min_child_weight = 5,
    lambda = 1) ;
pred = Jchemo.predict(fm, Xtest).pred ;
println(rmsep(pred, ytest))
plotxy(vec(pred), ytest; color = (:red, .5), 
    bisect = true).f
res = vi_xgb(fm)
nam = "total_gain"
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1];
    xlabel = "Wavelength (nm)", 
    ylabel = "Importance")
scatter!(ax, wl_num, res[:, nam]; color = (:red, .5))
u = [910; 950]
vlines!(ax, u; color = :grey, linewidth = 1)
f

#### Bagging KRR
fm = baggr(Xtrain, ytrain; rep = 1, 
    rowsamp = 2/3, colsamp = 1,
    fun = krr,
    gamma = 100, lb = .001) ;
pred = Jchemo.predict(fm, Xtest).pred 
println(rmsep(pred, ytest))
res = vi_baggr(fm, Xtrain, ytrain)
z = vec(res.imp)
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1];
    xlabel = "Wavelength (nm)", 
    ylabel = "Importance")
scatter!(ax, wl_num, z; color = (:red, .5))
u = [910; 950]
vlines!(ax, u; color = :grey, linewidth = 1)
f

fm = baggr(Xtrain, ytrain; rep = 50,
           rowsamp = 2/3, colsamp = 1,
           fun = kplsr,
           nlv = 15, gamma = 100) ;
pred = Jchemo.predict(fm, Xtest).pred ;
println(rmsep(pred, ytest))
res = vi_baggr(fm, Xtrain, ytrain)
z = vec(res.imp)
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1];
    xlabel = "Wavelength (nm)", 
    ylabel = "Importance")
scatter!(ax, wl_num, z; color = (:red, .5))
u = [910; 950]
vlines!(ax, u; color = :grey, linewidth = 1)
f

#### Bagging PLSR
nlv = 9
fm = baggr(Xtrain, ytrain; rep = 100,
    rowsamp = .7, colsamp = 1, withr = false, 
    fun = plskern, nlv = nlv) ; 
pred = Jchemo.predict(fm, Xtest).pred ;
println(rmsep(pred, ytest))
res = vi_baggr(fm, Xtrain, ytrain)
z = vec(res.imp)
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1];
    xlabel = "Wavelength (nm)", 
    ylabel = "Importance")
scatter!(ax, wl_num, z; color = (:red, .5))
u = [910; 950]
vlines!(ax, u; color = :grey, linewidth = 1)
f

#### VIPERM
res = viperm(Xtrain, ytrain; perm = 50, 
    score = rmsep, fun = plskern, nlv = 9)
z = vec(res.imp)
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1];
    xlabel = "Wavelength (nm)", 
    ylabel = "Importance")
scatter!(ax, wl_num, vec(z); color = (:red, .5))
u = [910; 950]
vlines!(ax, u; color = :grey, linewidth = 1)
f

res = Jchemo.viperm(Xtrain, ytrain; perm = 50,
    score = rmsep, 
    fun = rfr_xgb, rep = 10, 
    colsample_bynode = 1/3,
    max_depth = 2000, min_child_weight = 5)
z = vec(res.imp)
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1];
    xlabel = "Wavelength (nm)", 
    ylabel = "Importance")
scatter!(ax, wl_num, vec(z); color = (:red, .5))
u = [910; 950]
vlines!(ax, u; color = :grey, linewidth = 1)
f

