using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData

#+
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/tecator.jld2") 
@load db dat
pnames(dat)

#+
X = dat.X
Y = dat.Y 
ntot = nro(X)

#+ term = true
@head X
@head Y

#+
summ(Y)

#+
namy = names(Y)[1:3]

#+
typ = Y.typ
tab(typ)

#+
wl = names(X)
wl_num = parse.(Float64, wl) 

#+
plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

#+
## Preprocessing
f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 

plotsp(Xp, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

#+
#### PCA
fm = pcasvd(Xp, nlv = 10) ; 
pnames(fm)

#+
res = summary(fm, Xp) ;
pnames(res)

#+
z = res.explvarx
plotgrid(z.lv, 100 * z.pvar; step = 1,
    xlabel = "Nb. PCs", ylabel = "% variance explained").f

#+ term = true
T = fm.T
@head T

#+
i = 1
plotxy(T[:, i:(i + 1)]; color = (:red, .5),
    xlabel = "PC1", ylabel = "PC2").f

#+
plotxy(T[:, i:(i + 1)], typ; 
    xlabel = "PC1", ylabel = "PC2").f

#+
## Variables y
summ(Y[:, namy]).res

#+
aggstat(Y; vars = namy, groups = :typ)

#+
j = 2
nam = namy[2]  # y-variable

#+
y = Y[:, 2]

#+
mlev(typ)
ztyp = recodcat2int(typ)

#+
tab(string.(ztyp, "-", typ))

#+
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], 
    xticks = (1:3, mlev(typ)),
    xlabel = "Group", ylabel = nam)
boxplot!(ax, ztyp, y; width = .5, 
    show_notch = true)
f

