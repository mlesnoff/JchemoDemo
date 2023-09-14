using JLD2, CairoMakie, StatsBase
using Jchemo, JchemoData

```julia
path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/tecator.jld2") 
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
summ(Y)

```julia
namy = names(Y)[1:3]

```julia
typ = Y.typ
tab(typ)

```julia
wl = names(X)
wl_num = parse.(Float64, wl) 

```julia
plotsp(X, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

```julia
## Preprocessing
f = 15 ; pol = 3 ; d = 2 
Xp = savgol(snv(X); f = f, pol = pol, d = d) 

plotsp(Xp, wl_num;
    xlabel = "Wavelength (nm)", ylabel = "Absorbance").f

```julia
#### PCA
fm = pcasvd(Xp, nlv = 10) ; 
pnames(fm)

```julia
res = summary(fm, Xp) ;
pnames(res)

```julia
z = res.explvarx
plotgrid(z.lv, 100 * z.pvar; step = 1,
    xlabel = "Nb. PCs", ylabel = "% variance explained").f

```julia term = true
T = fm.T
@head T

```julia
i = 1
plotxy(T[:, i:(i + 1)]; color = (:red, .5),
    xlabel = "PC1", ylabel = "PC2").f

```julia
plotxy(T[:, i:(i + 1)], typ; 
    xlabel = "PC1", ylabel = "PC2").f

```julia
## Variables y
summ(Y[:, namy]).res

```julia
aggstat(Y; vars = namy, groups = :typ)

```julia
j = 2
nam = namy[2]  # y-variable

```julia
y = Y[:, 2]

```julia
mlev(typ)
ztyp = recodcat2int(typ)

```julia
tab(string.(ztyp, "-", typ))

```julia
f = Figure(resolution = (500, 400))
ax = Axis(f[1, 1], 
    xticks = (1:3, mlev(typ)),
    xlabel = "Group", ylabel = nam)
boxplot!(ax, ztyp, y; width = .5, 
    show_notch = true)
f

