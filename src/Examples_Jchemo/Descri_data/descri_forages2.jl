using JLD2, CairoMakie, StatsBase, FreqTables
using Jchemo, JchemoData

mypath = dirname(dirname(pathof(JchemoData)))
db = joinpath(mypath, "data", "forages2.jld2") 
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

freqtable(typ, test)

# Tot ==> Train + Test
s = Bool.(test)
Xtrain = rmrow(X, s)
Ytrain = rmrow(Y, s)
Xtest = X[s, :]
Ytest = Y[s, :]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)

## Spectra X 
## (already pre-processed SavGol(Snv; f = 21, p = 3, d=2))
plotsp(X, wl_num; nsamp = 10,
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

#### PCAs on X
fm = pcasvd(X, nlv = 15) ; 
pnames(fm)
T = fm.T

res = summary(fm, X) ;
pnames(res)

z = res.explvarx
plotgrid(z.lv, 100 * z.pvar; step = 1,
    xlabel = "nb. PCs", ylabel = "% variance explained").f

i = 1
plotxy(T[:, i], T[:, i + 1]; color = (:red, .5),
    xlabel = "PC1", ylabel = "PC2").f

plotxy(T[:, i], T[:, i + 1], typ; ellipse = true,
    xlabel = "PC1", ylabel = "PC2").f

## Train vs Test
fm = pcasvd(Xtrain, nlv = 15) ; 
Ttrain = fm.T
Ttest = Jchemo.transform(fm, Xtest)

zT = vcat(Ttrain, Ttest)
group = vcat(repeat(["0-Train";], ntrain), repeat(["1-Test";], ntest))
i = 1
plotxy(zT[:, i], zT[:, i + 1], group;
    xlabel = "PC1", ylabel = "PC2").f

res_sd = occsd(fm) ; 
sdtrain = res_sd.d
sdtest = Jchemo.predict(res_sd, Xtest).d
res_od = occod(fm, Xtrain) ;
odtrain = res_od.d
odtest = Jchemo.predict(res_od, Xtest).d
f = Figure(resolution = (500, 400))
ax = Axis(f, xlabel = "SD", ylabel = "OD")
scatter!(ax, sdtrain.dstand, odtrain.dstand, label = "Train")
scatter!(ax, sdtest.dstand, odtest.dstand, color = (:red, .5), label = "Test")
hlines!(ax, 1; color = :grey, linestyle = "-")
vlines!(ax, 1; color = :grey, linestyle = "-")
axislegend(position = :rt)
f[1, 1] = ax
f

zres = res_sd ; nam = "SD"
#zres = res_od ; nam = "OD"
sdtrain = zres.d
sdtest = Jchemo.predict(zres, Xtest).d
f = Figure(resolution = (500, 400))
ax = Axis(f, xlabel = nam, ylabel = "Nb. observations")
hist!(ax, sdtrain.d; bins = 50, label = "Train")
hist!(ax, sdtest.d; bins = 50, label = "Test")
vlines!(ax, zres.cutoff; color = :grey, linestyle = "-")
axislegend(position = :rt)
f[1, 1] = ax
f

## Variable y
summ(Y)
summ(Y, test)

nam = "ndf"
#nam = "dm"
aggstat(Y[:, nam], test; fun = mean).X
aggstat(Y; vars = nam, groups = :test)

y = Float64.(Y[:, nam])  # To remove type "Missing" 
s = Bool.(test)
ytrain = rmrow(y, s)
ytest = y[s]

f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], xlabel = "Protein", ylabel = "Nb. observations")
hist!(ax, ytrain; bins = 50, label = "Train")
hist!(ax, ytest; bins = 50, label = "Test")
axislegend(position = :rt)
f

f = Figure(resolution = (500, 400))
offs = [30; 0]
ax = Axis(f[1, 1], xlabel = "Protein", 
    ylabel = "Nb. observations",
    yticks = (offs, ["Train" ; "Test"]))
hist!(ax, ytrain; offset = offs[1], bins = 50)
hist!(ax, ytest; offset = offs[2], bins = 50)
f

f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], xlabel = nam, ylabel = "Density")
density!(ax, ytrain; color = :blue, label = "Train")
density!(ax, ytest; color = (:red, .5), label = "Test")
axislegend(position = :rt)
f

f = Figure(resolution = (500, 400))
offs = [.08; 0]
ax = Axis(f[1, 1], xlabel = nam, ylabel = "Density",
    yticks = (offs, ["Train" ; "Test"]))
density!(ax, ytrain; offset = offs[1], color = (:slategray, 0.5),
    bandwidth = 0.2)
density!(ax, ytest; offset = offs[2], color = (:slategray, 0.5),
    bandwidth = 0.2)
f

f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], 
    xticks = (0:1, ["Train", "Test"]),
    xlabel = "Group", ylabel = nam)
boxplot!(ax, test, y; width = .5, 
    show_notch = true)
f
