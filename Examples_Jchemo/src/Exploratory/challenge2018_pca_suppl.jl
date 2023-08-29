using JLD2, CairoMakie, GLMakie
using Jchemo, JchemoData
using FreqTables
CairoMakie.activate!() 

path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/challenge2018.jld2") 
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

z = string.(typ, "-", Y.label)
tab(z)
freqtable(z)
freqtable(typ, test)

## Preprocesssing
f = 21 ; pol = 3 ; d = 2
Xp = savgol(snv(X); f = f, pol = pol, d = d) 

## Splitting: Tot = Train + Test
## The PCA is fitted on Train, and Test will be 
## the supplementary observations.
## Here the splitting is provided by the dataset
## (= variable "typ"), but data Tot could be splitted 
## a posteriori (e.g. random sampling, systematic 
## sampling, etc.) 
s = Bool.(test)
## or: s = test .== 1
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
plotgrid(res.lv, res.pvar; step = 2,
    xlabel = "PC", 
    ylabel = "Prop. variance explained").f

Ttrain = fm.T

## Projection of Test in the Train score space
## Below function 'transform' has to be qualified
## since both packages Jchemo and DataFrames export 
## a function 'transform'.
## This will be the same with common function names
## such as 'predict', 'coef', etc.
Ttest = Jchemo.transform(fm, Xtest)

T = vcat(Ttrain, Ttest)
group = vcat(repeat(["0-Train";], ntrain), 
    repeat(["1-Test";], ntest))
colm = [:blue, (:red, .5)]
i = 3
plotxy(T[:, i:(i + 1)], group; color = colm,
    xlabel = string("PC", i), 
    ylabel = string("PC", i + 1)).f

## SD and OD distances
res = occsdod(fm, Xtrain) ; 
pnames(res)
dtrain = res.d
## Values for Test
dtest = Jchemo.predict(res, Xtest).d

f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], xlabel = "SD", ylabel = "OD")
scatter!(ax, dtrain.dstand_sd, dtrain.dstand_od, label = "Train")
scatter!(ax, dtest.dstand_sd, dtest.dstand_od, 
    color = (:red, .5), label = "Test")
hlines!(ax, 1; color = :grey, linestyle = "-")
vlines!(ax, 1; color = :grey, linestyle = "-")
axislegend(position = :rt)
f

## Same with plotxy
d = vcat(dtrain, dtest)
group = vcat(repeat(["0-Train";], ntrain), 
    repeat(["1-Test";], ntest))
colm = [:blue, (:red, .5)]
plotxy(d.dstand_sd, d.dstand_od, group; color = colm,
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

