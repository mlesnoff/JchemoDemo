using JLD2, CairoMakie
using StatsBase, FreqTables 
using Jchemo, JchemoData

```julia
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/forages2.jld2") 
@load db dat
pnames(dat)
  
```julia
X = dat.X 
Y = dat.Y
ntot = nro(X)

```julia term = true
@head X
@head Y

```julia
y = Y.typ
tab(y)

```julia
test = Y.test
tab(test)

```julia
freqtable(y, test)

```julia
wl = names(X)
wl_num = parse.(Float64, wl)

```julia
# Tot ==> Train + Test
s = Bool.(test)
Xtrain = rmrow(X, s)
Ytrain = rmrow(Y, s)
Xtest = X[s, :]
Ytest = Y[s, :]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)

```julia
## Spectra X 
## (already pre-processed SavGol(Snv; f = 21, p = 3, d=2))
plotsp(X, wl_num; nsamp = 10,
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

```julia
#### PCAs on X
fm = pcasvd(X; nlv = 15) ; 
pnames(fm)

```julia term = true
T = fm.T
@head T 

```julia
res = summary(fm, X) ;
pnames(res)

```julia
z = res.explvarx
plotgrid(z.lv, 100 * z.pvar; step = 1,
    xlabel = "nb. PCs", ylabel = "% variance explained").f

```julia
i = 1
plotxy(T[:, i:(i + 1)]; color = (:red, .5),
    xlabel = "PC1", ylabel = "PC2").f

```julia
plotxy(T[:, i:(i + 1)], y; ellipse = true,
    xlabel = "PC1", ylabel = "PC2").f

```julia term = true
## Train vs Test
fm = pcasvd(Xtrain, nlv = 15) ; 
Ttrain = fm.T
@head Ttrain

```julia
Ttest = Jchemo.transform(fm, Xtest)

```julia
zT = vcat(Ttrain, Ttest)
group = vcat(repeat(["0-Train";], ntrain), repeat(["1-Test";], ntest))
i = 1
plotxy(zT[:, i:(i + 1)], group;
    xlabel = "PC1", ylabel = "PC2").f

```julia
res_sd = occsd(fm) ; 
pnames(res_sd)

```julia
sdtrain = res_sd.d

```julia
sdtest = Jchemo.predict(res_sd, Xtest).d

```julia
res_od = occod(fm, Xtrain) ;
pnames(res_od)

```julia
odtrain = res_od.d

```julia
odtest = Jchemo.predict(res_od, Xtest).d

```julia
f = Figure(resolution = (500, 400))
ax = Axis(f, xlabel = "SD", ylabel = "OD")
scatter!(ax, sdtrain.dstand, odtrain.dstand, label = "Train")
scatter!(ax, sdtest.dstand, odtest.dstand, color = (:red, .5), label = "Test")
hlines!(ax, 1; color = :grey, linestyle = "-")
vlines!(ax, 1; color = :grey, linestyle = "-")
axislegend(position = :rt)
f[1, 1] = ax
f

```julia
zres = res_sd ; nam = "SD"
#zres = res_od ; nam = "OD"
sdtrain = zres.d

```julia
sdtest = Jchemo.predict(zres, Xtest).d

```julia
f = Figure(resolution = (500, 400))
ax = Axis(f, xlabel = nam, ylabel = "Nb. observations")
hist!(ax, sdtrain.d; bins = 50, label = "Train")
hist!(ax, sdtest.d; bins = 50, label = "Test")
vlines!(ax, zres.cutoff; color = :grey, linestyle = "-")
axislegend(position = :rt)
f[1, 1] = ax
f

```julia
## Variable y
summ(Y)

```julia
summ(Y, test)

```julia
nam = "ndf"
#nam = "dm"
aggstat(Y[:, nam], test; fun = mean).X

```julia
aggstat(Y; vars = nam, groups = :test)

```julia
y = Float64.(Y[:, nam])  # To remove type "Missing" for the given variable
s = Bool.(test)
ytrain = rmrow(y, s)
ytest = y[s]

```julia
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], xlabel = "Protein", ylabel = "Nb. observations")
hist!(ax, ytrain; bins = 50, label = "Train")
hist!(ax, ytest; bins = 50, label = "Test")
axislegend(position = :rt)
f

```julia
f = Figure(resolution = (500, 400))
offs = [30; 0]
ax = Axis(f[1, 1], xlabel = "Protein", 
    ylabel = "Nb. observations",
    yticks = (offs, ["Train" ; "Test"]))
hist!(ax, ytrain; offset = offs[1], bins = 50)
hist!(ax, ytest; offset = offs[2], bins = 50)
f

```julia
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], xlabel = nam, ylabel = "Density")
density!(ax, ytrain; color = :blue, label = "Train")
density!(ax, ytest; color = (:red, .5), label = "Test")
axislegend(position = :rt)
f

```julia
f = Figure(resolution = (500, 400))
offs = [.08; 0]
ax = Axis(f[1, 1], xlabel = nam, ylabel = "Density",
    yticks = (offs, ["Train" ; "Test"]))
density!(ax, ytrain; offset = offs[1], color = (:slategray, 0.5),
    bandwidth = 0.2)
density!(ax, ytest; offset = offs[2], color = (:slategray, 0.5),
    bandwidth = 0.2)
f

```julia
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], 
    xticks = (0:1, ["Train", "Test"]),
    xlabel = "Group", ylabel = nam)
boxplot!(ax, test, y; width = .5, 
    show_notch = true)
f
