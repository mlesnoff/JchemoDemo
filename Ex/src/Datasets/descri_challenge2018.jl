
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


plotsp(X, wl; nsamp = 30, xlabel = "Wavelength (nm)").f


model1 = snv)
model2 = savgol; npoint = 21, deriv = 2, degree = 3)
model = pip(model1, model2)
fit!(model, X)
Xp = transf(model, X)


plotsp(Xp, wl; nsamp = 30, xlabel = "Wavelength (nm)").f


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


model = pcasvd; nlv = 10)
fit!(model, Xp)
pnames(model)
pnames(model.fitm)


@head T = model.fitm.T


res = summary(model, Xp) ;
pnames(res)


z = res.explvarx


plotgrid(z.nlv, 100 * z.pvar; step = 1, xlabel = "nb. PCs", ylabel = "% variance explained").f


i = 1
plotxy(T[:, i], T[:, i + 1]; color = (:red, .5), xlabel = string("PC", i), 
    ylabel = string("PC", i + 1)).f


lev = mlev(typ)
nlev = length(lev)
colm = cgrad(:Dark2_5, nlev; categorical = true)
plotxy(T[:, i], T[:, i + 1], typ; color = colm, xlabel = string("PC", i), 
    ylabel = string("PC", i + 1)).f


model = pcasvd; nlv = 15)
fit!(model, Xtrain)


Ttrain = model.fitm.T
@head Ttrain


Ttest = transf(model, Xtest)
@head Ttest


T = vcat(Ttrain, Ttest)
group = vcat(repeat(["0-Train";], ntrain), repeat(["1-Test";], ntest))
colm = [:blue, (:red, .5)]
i = 1
plotxy(T[:, i], T[:, i + 1], group; color = colm, xlabel = "PC1", ylabel = "PC2").f


mod_sd = occsd) 
fit!(mod_sd, model.fitm)
pnames(mod_sd)
sdtrain = mod_sd.fitm.d
sdtest = predict(mod_sd, Xtest).d


mod_od = occod) 
fit!(mod_od, model.fitm, Xtrain)
pnames(mod_od)
odtrain = mod_od.fitm.d
odtest = predict(mod_od, Xtest).d


f = Figure(size = (500, 400))
ax = Axis(f; xlabel = "SD", ylabel = "OD")
scatter!(ax, sdtrain.dstand, odtrain.dstand, label = "Train")
scatter!(ax, sdtest.dstand, odtest.dstand, color = (:red, .5), label = "Test")
hlines!(ax, 1; color = :grey, linestyle = :dash)
vlines!(ax, 1; color = :grey, linestyle = :dash)
axislegend(position = :rt)
f[1, 1] = ax
f


zres = mod_sd ; nam = "SD"
#zres = mod_od ; nam = "OD"
pnames(zres.fitm)
sdtrain = zres.fitm.d
sdtest = predict(zres, Xtest).d
f = Figure(size = (500, 400))
ax = Axis(f[1, 1]; xlabel = nam, ylabel = "Nb. observations")
hist!(ax, sdtrain.d; bins = 50, label = "Train")
hist!(ax, sdtest.d; bins = 50, label = "Test")
vlines!(ax, zres.fitm.cutoff; color = :grey, linestyle = :dash)
axislegend(position = :rt)
f


summ(y)


summ(y, test)


aggstat(y, test).X


aggstat(Y; vars = :conc, groups = :test)


f = Figure(size = (500, 400))
ax = Axis(f[1, 1]; xlabel = "Protein", ylabel = "Nb. observations")
hist!(ax, ytrain; bins = 50, label = "Train")
hist!(ax, ytest; bins = 50, label = "Test")
axislegend(position = :rt)
f


f = Figure(size = (500, 400))
offs = [100; 0]
ax = Axis(f[1, 1]; xlabel = "Protein",  ylabel = "Nb. observations", 
    yticks = (offs, ["Train" ; "Test"]))
hist!(ax, ytrain; offset = offs[1], bins = 50)
hist!(ax, ytest; offset = offs[2], bins = 50)
f


f = Figure(size = (500, 400))
ax = Axis(f[1, 1]; xlabel = "Protein", ylabel = "Density")
density!(ax, ytrain; color = :blue, label = "Train")
density!(ax, ytest; color = (:red, .5), label = "Test")
axislegend(position = :rt)
f


f = Figure(size = (500, 400))
offs = [.1; 0]
ax = Axis(f[1, 1]; xlabel = "Protein", ylabel = "Density", yticks = (offs, ["Train" ; "Test"]))
density!(ax, ytrain; offset = offs[1], color = (:slategray, 0.5), bandwidth = 0.2)
density!(ax, ytest; offset = offs[2], color = (:slategray, 0.5), bandwidth = 0.2)
f


f = Figure(size = (500, 400))
ax = Axis(f[1, 1]; xticks = (0:1, ["Train", "Test"]), xlabel = "Group", ylabel = "Protein")
boxplot!(ax, test, y; width = .3, show_notch = true)
f

