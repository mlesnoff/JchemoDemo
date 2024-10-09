
using Jchemo, JchemoData
using JLD2, CairoMakie
using FreqTables


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/forages2.jld2") 
@load db dat
pnames(dat)


X = dat.X 
Y = dat.Y
ntot = nro(X)


@head X
@head Y


y = Y.typ
tab(y)


test = Y.test
tab(test)


freqtable(y, test)


wlst = names(X)
wl = parse.(Float64, wlst)


s = Bool.(test)
Xtrain = rmrow(X, s)
Ytrain = rmrow(Y, s)
Xtest = X[s, :]
Ytest = Y[s, :]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)


plotsp(X, wl; nsamp = 10, xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


model = pcasvd; nlv = 10)
fit!(model, X)
pnames(model)
pnames(model.fitm)


@head T = model.fitm.T


res = summary(model, X) ;
pnames(res)


z = res.explvarx
plotgrid(z.nlv, 100 * z.pvar; step = 1, xlabel = "nb. PCs", ylabel = "% variance explained").f


i = 1
plotxy(T[:, i], T[:, i + 1]; color = (:red, .5), xlabel = "PC1", ylabel = "PC2").f


plotxy(T[:, i], T[:, i + 1], y; ellipse = true, xlabel = "PC1", ylabel = "PC2").f


## Train vs Test
model = pcasvd; nlv = 15)
fit!(model, Xtrain)
Ttrain = model.fitm.T
@head Ttrain


Ttest = transf(model, Xtest)


T = vcat(Ttrain, Ttest)
group = vcat(repeat(["0-Train";], ntrain), repeat(["1-Test";], ntest))
i = 1
plotxy(T[:, i], T[:, i + 1], group; xlabel = "PC1", ylabel = "PC2").f


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


summ(Y)


summ(Y, test)


nam = "ndf"
#nam = "dm"
aggstat(Y[:, nam], test).X


aggstat(Y; vars = nam, groups = :test)


y = Float64.(Y[:, nam])  # To remove type "Missing" for the given variable
s = Bool.(test)
ytrain = rmrow(y, s)
ytest = y[s]


f = Figure(size = (500, 400))
ax = Axis(f[1, 1]; xlabel = nam, ylabel = "Nb. observations")
hist!(ax, ytrain; bins = 50, label = "Train")
hist!(ax, ytest; bins = 50, label = "Test")
axislegend(position = :rt)
f


f = Figure(size = (500, 400))
offs = [30; 0]
ax = Axis(f[1, 1]; xlabel = nam, ylabel = "Nb. observations", yticks = (offs, ["Train" ; "Test"]))
hist!(ax, ytrain; offset = offs[1], bins = 50)
hist!(ax, ytest; offset = offs[2], bins = 50)
f


f = Figure(size = (500, 400))
ax = Axis(f[1, 1]; xlabel = nam, ylabel = "Density")
density!(ax, ytrain; color = :blue, label = "Train")
density!(ax, ytest; color = (:red, .5), label = "Test")
axislegend(position = :rt)
f


f = Figure(size = (500, 400))
offs = [.08; 0]
ax = Axis(f[1, 1]; xlabel = nam, ylabel = "Density", yticks = (offs, ["Train" ; "Test"]))
density!(ax, ytrain; offset = offs[1], color = (:slategray, 0.5), bandwidth = 0.2)
density!(ax, ytest; offset = offs[2], color = (:slategray, 0.5), bandwidth = 0.2)
f


f = Figure(size = (500, 400))
ax = Axis(f[1, 1]; xticks = (0:1, ["Train", "Test"]), xlabel = "Group", ylabel = nam)
boxplot!(ax, test, y; width = .5, show_notch = true)
f

