using JLD2, CairoMakie
using Jchemo, JchemoData

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

plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 
plotsp(Xp, wl_num;
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
scatter!(ax, wl_num; res.imp; color = (:red, .5))
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

