
using Jchemo, JchemoData
using JLD2, CairoMakie


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/tecator.jld2") 
@load db dat
@names dat


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


model1 = snv()
model2 = savgol(npoint = 15, deriv = 2, degree = 3)
model = pip(model1, model2)
fit!(model, X)
Xp = transf(model, X)


plotsp(Xp, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


model = pcasvd(nlv = 10)
fit!(model, X)
@names model
@names model.fitm


res = summary(model, Xp) ;
@names res


z = res.explvarx
plotgrid(z.nlv, 100 * z.pvar; step = 1, xlabel = "Nb. PCs", ylabel = "% variance explained").f


@head T = model.fitm.T


i = 1
plotxy(T[:, i], T[:, i + 1]; color = (:red, .5), xlabel = "PC1", ylabel = "PC2").f


plotxy(T[:, i], T[:, i + 1], typ; xlabel = "PC1", ylabel = "PC2").f


summ(Y[:, namy]).res


aggstat(Y; vary = namy, vargroup = :typ)


j = 2
nam = namy[2]  # y-variable


y = Y[:, nam]


mlev(typ)
ztyp = recod_catbyint(typ)


tab(string.(ztyp, "-", typ))


f = Figure(size = (500, 400))
ax = Axis(f[1, 1]; xticks = (1:3, mlev(typ)), xlabel = "Group", ylabel = nam)
boxplot!(ax, ztyp, y; width = .5, show_notch = true)
f

