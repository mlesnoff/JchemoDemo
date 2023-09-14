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

lev = unique(typ)
nlev = length(lev)

freqtable(string.(typ, "-", Y.label))

freqtable(typ, test)

plotsp(X, wl_num; nsamp = 30).f

f = 21 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) ;

plotsp(Xp, wl_num; nsamp = 30).f

## Tot = Train + Test
s = Bool.(test)
Xtrain = rmrow(Xp, s)
Ytrain = rmrow(Y, s)
ytrain = rmrow(y, s)
Xtest = Xp[s, :]
Ytest = Y[s, :]
ytest = y[s]
ntrain = nro(Xtrain)
ntest = nro(Xtest)
(ntot = ntot, ntrain, ntest)

## PCAs on X
fm = pcasvd(Xp, nlv = 15) ; 
pnames(fm)
T = fm.T

res = summary(fm, Xp) ;
pnames(res)

z = res.explvarx

plotgrid(z.lv, 100 * z.pvar; step = 1,
    xlabel = "nb. PCs", ylabel = "% variance explained").f

i = 1
plotxy(T[:, i:(i + 1)]; color = (:red, .5),
    xlabel = string("PC", i), ylabel = string("PC", i + 1)).f

colm = cgrad(:Dark2_5, nlev; categorical = true)
plotxy(T[:, i:(i + 1)], typ; color = colm,
    xlabel = string("PC", i), ylabel = string("PC", i + 1)).f

## Train vs Test
fm = pcasvd(Xtrain, nlv = 15) ; 

Ttrain = fm.T
@head Ttrain

Ttest = Jchemo.transform(fm, Xtest)
@head Ttest 

zT = vcat(Ttrain, Ttest)
group = vcat(repeat(["0-Train";], ntrain), 
    repeat(["1-Test";], ntest))
colm = [:blue, (:red, .5)]
i = 1
plotxy(zT[:, i:(i + 1)], group; color = colm,
    xlabel = "PC1", ylabel = "PC2").f

res_sd = occsd(fm) ; 
sdtrain = res_sd.d
sdtest = Jchemo.predict(res_sd, Xtest).d

res_od = occod(fm, Xtrain) ;
odtrain = res_od.d
odtest = Jchemo.predict(res_od, Xtest).d

f = Figure(resolution = (500, 400))
ax = Axis(f, xlabel = "SD", ylabel = "OD")
scatter!(ax, sdtrain.dstand, odtrain.dstand, 
    label = "Train")
scatter!(ax, sdtest.dstand, odtest.dstand, 
    color = (:red, .5), label = "Test")
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
ax = Axis(f[1, 1], xlabel = nam, ylabel = "Nb. observations")
hist!(ax, sdtrain.d; bins = 50, label = "Train")
hist!(ax, sdtest.d; bins = 50, label = "Test")
vlines!(ax, zres.cutoff; color = :grey, linestyle = "-")
axislegend(position = :rt)
f

## Variable y
summ(y)

summ(y, test)

aggstat(y, test).X

aggstat(Y; vars = :conc, groups = :test)

f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], xlabel = "Protein", ylabel = "Nb. observations")
hist!(ax, ytrain; bins = 50, label = "Train")
hist!(ax, ytest; bins = 50, label = "Test")
axislegend(position = :rt)
f

f = Figure(resolution = (500, 400))
offs = [100; 0]
ax = Axis(f[1, 1], xlabel = "Protein", 
    ylabel = "Nb. observations",
    yticks = (offs, ["Train" ; "Test"]))
hist!(ax, ytrain; offset = offs[1], bins = 50)
hist!(ax, ytest; offset = offs[2], bins = 50)
f

f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], xlabel = "Protein", ylabel = "Density")
density!(ax, ytrain; color = :blue, label = "Train")
density!(ax, ytest; color = (:red, .5), label = "Test")
axislegend(position = :rt)
f

f = Figure(resolution = (500, 400))
offs = [.1; 0]
ax = Axis(f[1, 1], xlabel = "Protein", ylabel = "Density",
    yticks = (offs, ["Train" ; "Test"]))
density!(ax, ytrain; offset = offs[1], color = (:slategray, 0.5),
    bandwidth = 0.2)
density!(ax, ytest; offset = offs[2], color = (:slategray, 0.5),
    bandwidth = 0.2)
f

f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], 
    xticks = (0:1, ["Train", "Test"]),
    xlabel = "Group", ylabel = "Protein")
boxplot!(ax, test, y; width = .3, 
    show_notch = true)
f

