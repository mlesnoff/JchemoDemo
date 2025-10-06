
using Jchemo, JchemoData
using JLD2, DataFrames, CairoMakie


path_jdat = dirname(dirname(pathof(JchemoData)))
db = joinpath(path_jdat, "data/cassav.jld2")
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


year = Y.year
tab(year)


y = Y.tbc
summ(y).res


f = Figure(size = (400, 300))
ax = Axis(f[1, 1]; xlabel = "TBC", ylabel = "Nb. observations")
hist!(ax, y; bins = 30, label = "Train")
f


f = Figure(size = (400, 300))
ax = Axis(f[1, 1]; xlabel = "TBC", ylabel = "Density")
density!(ax, y; bandwidth = .2, color = (:red, .5))
f


y = Y.tbc
summ(y, year)


f = Figure(size = (400, 300))
ax = Axis(f[1, 1]; xlabel = "Year", ylabel = "TBC")
boxplot!(ax, year, y; width = .7, show_notch = true)
f


lev = mlev(year)
nlev = length(lev)
tsp = .5
colm = [(:blue, tsp), (:orange, tsp), (:green, tsp), (:red, tsp), (:purple, tsp)]
#colm = cgrad(:Dark2_5; categorical = true, alpha = .8)[1:nlev]
cols = colm[indexin(year, unique(year))]
#cols = (:red, .5)
f = Figure(size = (600, 250))
ax = Axis(f[1, 1]; xlabel = "Year", ylabel = "TBC") 
rainclouds!(ax, year, y; clouds = hist, jitter_width = .1, markersize = 10, color = cols)
f

