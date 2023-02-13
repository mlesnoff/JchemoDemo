using JLD2, CairoMakie, GLMakie
using Jchemo, JchemoData
using FreqTables

mypath = dirname(dirname(pathof(JchemoData)))
db = joinpath(mypath, "data", "challenge2018.jld2") 
@load db dat
pnames(dat)

X = dat.X    
Y = dat.Y
wl = names(X)
wl_num = parse.(Float64, wl)
ntot = nro(X)
summ(Y)
typ = Y.typ
test = Y.test

freqtable(string.(typ, "-", Y.label))
freqtable(typ, test)

## Preprocesssing
f = 21 ; pol = 3 ; d = 2 ;
Xp = savgol(snv(X); f = f, pol = pol, d = d) 

## Train + Test
s = Bool.(test)
Xtrain = rmrow(Xp, s)
Ytrain = rmrow(Y, s)
Xtest = Xp[s, :]
Ytest = Y[s, :]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)

############ END DATA

nlv = 15
fm = pcasvd(Xtrain, nlv = nlv) ; 
res = summary(fm, Xtrain).explvarx
plotgrid(res.lv, res.pvar; step = 1,
    xlabel = "PC", ylabel = "P. variance explained").f

Ttrain = fm.T
Ttest = Jchemo.transform(fm, Xtest)

T = vcat(Ttrain, Ttest)
group = vcat(repeat(["0-Train";], ntrain), repeat(["1-Test";], ntest))
colm = [:blue, (:red, .5)]
i = 3
plotxy(T[:, i], T[:, i + 1], group; color = colm,
    xlabel = "PC1", ylabel = "PC2").f

#### SD and OD distances

res = occsdod(fm, Xtrain) ; 
dtrain = res.d
dtest = Jchemo.predict(res, Xtest).d

f = Figure(resolution = (500, 400))
ax = Axis(f, xlabel = "SD", ylabel = "OD")
scatter!(ax, dtrain.sd_dstand, dtrain.od_dstand, label = "Train")
scatter!(ax, dtest.sd_dstand, dtest.od_dstand, color = (:red, .5), label = "Test")
hlines!(ax, 1; color = :grey, linestyle = "-")
vlines!(ax, 1; color = :grey, linestyle = "-")
axislegend(position = :rt)
f[1, 1] = ax
f

## Same with plotxy
d = vcat(dtrain, dtest)
group = vcat(repeat(["0-Train";], ntrain), repeat(["1-Test";], ntest))
colm = [:blue, (:red, .5)]
plotxy(d.sd_dstand, d.od_dstand, group; color = colm,
    xlabel = "PC1", ylabel = "PC2").f

## Composite distance SD-OD
f = Figure(resolution = (500, 400))
ax = Axis(f, xlabel = "Standardized distance", ylabel = "Nb. observations")
hist!(ax, dtrain.dstand; bins = 50, label = "Train")
hist!(ax, dtest.dstand; bins = 50, label = "Test")
vlines!(ax, 1; color = :grey, linestyle = "-")
axislegend(position = :rt, framevisible = false)
f[1, 1] = ax
f

