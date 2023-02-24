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

## The PCA is done on Train.
## Splitting: Tot = Train + Test
## Here the splitting is provided by the dataset
## (variable "typ").
## But Tot could be splitted a posteriori 
## (e.g. random sampling with function "mtest",
## systematic sampling, etc.) 
s = Bool.(test)
Xtrain = rmrow(Xp, s)
Ytrain = rmrow(Y, s)
Xtest = Xp[s, :]
Ytest = Y[s, :]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)

## Model fitting on Train
nlv = 15
fm = pcasvd(Xtrain, nlv = nlv) ; 
res = summary(fm, Xtrain).explvarx
plotgrid(res.lv, res.pvar; step = 1,
    xlabel = "PC", ylabel = "P. variance explained").f

## Projection of Test in the Train score space
Ttrain = fm.T
Ttest = Jchemo.transform(fm, Xtest)

T = vcat(Ttrain, Ttest)
group = vcat(repeat(["0-Train";], ntrain), repeat(["1-Test";], ntest))
colm = [:blue, (:red, .5)]
i = 3
plotxy(T[:, i], T[:, i + 1], group; color = colm,
    xlabel = string("PC", i), ylabel = string("PC", i + 1)).f

## SD and OD distances
res = occsdod(fm, Xtrain) ; 
pnames(res)
dtrain = res.d
## Values for test
dtest = Jchemo.predict(res, Xtest).d

f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], xlabel = "SD", ylabel = "OD")
scatter!(ax, dtrain.sd_dstand, dtrain.od_dstand, label = "Train")
scatter!(ax, dtest.sd_dstand, dtest.od_dstand, 
    color = (:red, .5), label = "Test")
hlines!(ax, 1; color = :grey, linestyle = "-")
vlines!(ax, 1; color = :grey, linestyle = "-")
axislegend(position = :rt)
f

## Same with plotxy
d = vcat(dtrain, dtest)
group = vcat(repeat(["0-Train";], ntrain), repeat(["1-Test";], ntest))
colm = [:blue, (:red, .5)]
plotxy(d.sd_dstand, d.od_dstand, group; color = colm,
    xlabel = "Stand. SD", ylabel = "Stand. OD").f

## Composite distance SD-OD
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], xlabel = "Standardized distance", 
    ylabel = "Nb. observations")
hist!(ax, dtrain.dstand; bins = 50, label = "Train")
hist!(ax, dtest.dstand; bins = 50, label = "Test")
vlines!(ax, 1; color = :grey, linestyle = "-")
axislegend(position = :rt, framevisible = false)
f

