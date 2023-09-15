
using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData
using FreqTables


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/challenge2018.jld2") 
@load db dat
pnames(dat)


X = dat.X 
Y = dat.Y
ntot, p = size(X)


@head X
@head Y


summ(Y)


y = Y.conc
typ = Y.typ
label = Y.label 
test = Y.test
tab(test)


wl = names(X)
wl_num = parse.(Float64, wl)


freqtable(string.(typ, "-", Y.label))


freqtable(typ, test)


plotsp(X, wl_num; nsamp = 30).f


f = 21 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) ;


s = Bool.(test)
Xtrain = rmrow(Xp, s)
ytrain = rmrow(y, s)
Xtest = Xp[s, :]
ytest = y[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)


nlv = 15
fm = pcasvd(Xtrain, nlv = nlv) ;


res = summary(fm, Xtrain).explvarx


plotgrid(res.lv, res.pvar; step = 2,
    xlabel = "PC", 
    ylabel = "Prop. variance explained").f


Ttrain = fm.T ;
@head Ttrain


Ttest = Jchemo.transform(fm, Xtest)
@head Ttest


T = vcat(Ttrain, Ttest)
group = vcat(repeat(["0-Train";], ntrain), 
    repeat(["1-Test";], ntest))
colm = [:blue, (:red, .5)]
i = 3
plotxy(T[:, i], T[:, i + 1], group; color = colm,
    xlabel = string("PC", i), 
    ylabel = string("PC", i + 1)).f


res = occsdod(fm, Xtrain) ; 
pnames(res)


dtrain = res.d


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


d = vcat(dtrain, dtest)
group = vcat(repeat(["0-Train";], ntrain), 
    repeat(["1-Test";], ntest))
colm = [:blue, (:red, .5)]
plotxy(d.dstand_sd, d.dstand_od, group; color = colm,
    xlabel = "Stand. SD", ylabel = "Stand. OD").f


f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], xlabel = "Standardized distance", 
    ylabel = "Nb. observations")
hist!(ax, dtrain.dstand; bins = 50, label = "Train")
hist!(ax, dtest.dstand; bins = 50, label = "Test")
vlines!(ax, 1; color = :grey, linestyle = "-")
axislegend(position = :rt, framevisible = false)
f

