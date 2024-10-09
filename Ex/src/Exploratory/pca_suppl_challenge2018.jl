
using Jchemo, JchemoData
using JLD2, CairoMakie
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


wlst = names(X)
wl = parse.(Float64, wlst)


freqtable(string.(typ, "-", Y.label))


freqtable(typ, test)


plotsp(X, wl; nsamp = 30).f


model1 = snv()
model2 = savgol(npoint = 21, deriv = 2, degree = 3)
model = pip(model1, model2)
fit!(model, X)
Xp = transf(model, X)


plotsp(Xp, wl; nsamp = 30).f


s = Bool.(test)
Xtrain = rmrow(Xp, s)
Ytrain = rmrow(Y, s)
ytrain = rmrow(y, s)
typtrain = rmrow(typ, s)
Xtest = Xp[s, :]
Ytest = Y[s, :]
ytest = y[s]
typtest = typ[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)


nlv = 15
model = pcasvd; nlv)
fit!(model, Xtrain)


res = summary(model, Xtrain).explvarx


plotgrid(res.nlv, res.pvar; step = 2, xlabel = "PC", ylabel = "Prop. variance explained").f


@head Ttrain = model.fitm.T


@head Ttest = transf(model, Xtest)


T = vcat(Ttrain, Ttest)
group = vcat(repeat(["0-Train";], ntrain), repeat(["1-Test";], ntest))
colm = [:blue, (:red, .5)]
i = 3
plotxy(T[:, i], T[:, i + 1], group; color = colm, xlabel = string("PC", i), 
    ylabel = string("PC", i + 1)).f


mod_d = occsdod() 
fit!(mod_d, model.fitm, Xtrain)
pnames(mod_d)
pnames(mod_d.fitm)


dtrain = mod_d.fitm.d


dtest = predict(mod_d, Xtest).d


f = Figure(size = (500, 400))
ax = Axis(f[1, 1]; xlabel = "SD", ylabel = "OD")
scatter!(ax, dtrain.dstand_sd, dtrain.dstand_od; label = "Train")
scatter!(ax, dtest.dstand_sd, dtest.dstand_od; color = (:red, .5), label = "Test")
hlines!(ax, 1; color = :grey, linestyle = :dash)
vlines!(ax, 1; color = :grey, linestyle = :dash)
axislegend(position = :rt)
f


d = vcat(dtrain, dtest)
group = vcat(repeat(["0-Train";], ntrain), repeat(["1-Test";], ntest))
colm = [:blue, (:red, .5)]
plotxy(d.dstand_sd, d.dstand_od, group; color = colm, xlabel = "Stand. SD", ylabel = "Stand. OD").f


f = Figure(size = (500, 400))
ax = Axis(f[1, 1]; xlabel = "Standardized distance", ylabel = "Nb. observations")
hist!(ax, dtrain.dstand; bins = 50, label = "Train")
hist!(ax, dtest.dstand; bins = 50, label = "Test")
vlines!(ax, 1; color = :grey, linestyle = :dash)
axislegend(position = :rt, framevisible = false)
f

