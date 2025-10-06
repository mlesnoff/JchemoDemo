
using Jchemo, JchemoData
using JLD2, DataFrames, CairoMakie


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/tecator.jld2") 
@load db dat
@names dat


X = dat.X
@head X


Y = dat.Y
@head Y


wlst = names(X) 
wl = parse.(Int, wlst)


plotsp(X, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


model1 = snv()
model2 = savgol(npoint = 15, deriv = 2, degree = 3)
model = pip(model1, model2)
fit!(model, X)
Xp = transf(model, X)
@head Xp


plotsp(Xp, wl; xlabel = "Wavelength (nm)", ylabel = "Absorbance").f


summ(Y).res


typ = Y.typ
tab(typ)


## Training/test (0/1) observations
typ2 = ones(Int, nro(typ))
typ2[typ .== "train"] .= 0
tab(typ2)


summ(Y, typ2)


namy = names(Y)[1:3]
j = 2
nam = namy[2]
y = Y[:, nam]
s = typ2 .== 0
ytrain = y[s] 
ytest = rmrow(y, s)


f = Figure(size = (400, 300))
ax = Axis(f[1, 1]; xlabel = uppercase(nam), ylabel = "Nb. observations")
hist!(ax, ytrain; bins = 50, label = "Train")
hist!(ax, ytest; bins = 50, label = "Test")
axislegend(position = :rt)
f


f = Figure(size = (500, 400))
offs = [10; 0]
ax = Axis(f[1, 1]; xlabel = uppercase(nam),  ylabel = "Nb. observations", yticks = (offs, ["Train"; "Test"]))
hist!(ax, ytrain; offset = offs[1], bins = 50)
hist!(ax, ytest; offset = offs[2], bins = 50)
f


f = Figure(size = (400, 300))
ax = Axis(f[1, 1]; xlabel = uppercase(nam), ylabel = "Density")
bdw = .5 
density!(ax, ytrain; bandwidth = bdw, color = :blue, label = "Train")
density!(ax, ytest; bandwidth = bdw, color = (:red, .5), label = "Test")
axislegend(position = :rt)  
f


f = Figure(size = (500, 400))
offs = [.15; 0]
ax = Axis(f[1, 1]; xlabel = uppercase(nam), ylabel = "Density", yticks = (offs, ["Train"; "Test"]))
bdw = .5
density!(ax, ytrain; bandwidth = bdw, offset = offs[1], color = (:slategray, 0.5))
density!(ax, ytest; bandwidth = bdw, offset = offs[2], color = (:slategray, 0.5))
f


f = Figure(size = (400, 300))
ax = Axis(f[1, 1]; xticks = (0:1, ["Train", "Test"]), xlabel = "Group", ylabel = uppercase(nam))
boxplot!(ax, typ2, y; width = .3, show_notch = true)
f


lev = mlev(typ2)
nlev = length(lev)
tsp = .5
#colm = [(:blue, tsp), (:orange, tsp)]
colm = cgrad(:Dark2_5; categorical = true, alpha = .8)[1:nlev]
cols = colm[indexin(typ2, unique(typ2))]
#cols = (:red, .5)
f = Figure(size = (600, 300))
ax = Axis(f[1, 1]; xticks = (0:1, ["Train", "Test"]), ylabel = uppercase(nam))
rainclouds!(ax, typ2, y; clouds = hist, markersize = 5, color = cols, gap = .3)
f

