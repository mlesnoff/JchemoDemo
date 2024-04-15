
using Jchemo, JchemoData
using JLD2, CairoMakie


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/tecator.jld2") 
@load db dat
pnames(dat)


X = dat.X
Y = dat.Y 
ntot = nro(X)


@head X
@head Y


summ(Y)


namy = names(Y)[1:3]


typ = Y.typ
tab(typ)


wlst = names(X)
wl = parse.(Float64, wlst)


plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


mod1 = model(snv(centr = true, scal = true)
mod2 = model(savgol(npoint = 15, deriv = 2, degree = 3)
mod = pip(mod1, mod2)
fit!(mod, X)
Xp = transf(mod, X)


plotsp(Xp, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


mod = model(pcasvd(nlv = 10)
fit!(mod, X)
pnames(mod)
pnames(mod.fm)


res = summary(mod, Xp) ;
pnames(res)


z = res.explvarx
plotgrid(z.nlv, 100 * z.pvar; step = 1, xlabel = "Nb. PCs", 
    ylabel = "% variance explained").f


T = mod.fm.T
@head T


i = 1
plotxy(T[:, i], T[:, i + 1]; color = (:red, .5), xlabel = "PC1", ylabel = "PC2").f


plotxy(T[:, i], T[:, i + 1], typ; xlabel = "PC1", ylabel = "PC2").f


summ(Y[:, namy]).res


aggstat(Y; vars = namy, groups = :typ)


j = 2
nam = namy[2]  # y-variable


y = Y[:, nam]


mlev(typ)
ztyp = recodcat2int(typ)


tab(string.(ztyp, "-", typ))


f = Figure(size = (500, 400))
ax = Axis(f[1, 1], xticks = (1:3, mlev(typ)), xlabel = "Group", ylabel = nam)
boxplot!(ax, ztyp, y; width = .5, show_notch = true)
f

